import pandas as pd
import mysql.connector
from mysql.connector import Error
import re
from datetime import datetime
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('etl_pipeline.log'),
        logging.StreamHandler()
    ]
)

# MySQL connection - change password as needed
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'root',  # Change this to your MySQL password
    'database': 'fleximart'
}

# Data quality tracking
quality_metrics = {
    'customers': {
        'records_read': 0,
        'duplicates_removed': 0,
        'missing_values_handled': 0,
        'records_loaded': 0
    },
    'products': {
        'records_read': 0,
        'duplicates_removed': 0,
        'missing_values_handled': 0,
        'records_loaded': 0
    },
    'sales': {
        'records_read': 0,
        'duplicates_removed': 0,
        'missing_values_handled': 0,
        'records_loaded': 0
    }
}


def standardize_phone(phone):
    # Convert to +91-XXXXXXXXXX format
    if pd.isna(phone) or phone == '':
        return None
    
    phone_clean = re.sub(r'[^\d+]', '', str(phone))
    
    if phone_clean.startswith('91') and not phone_clean.startswith('+91'):
        phone_clean = phone_clean[2:]
    elif phone_clean.startswith('+91'):
        phone_clean = phone_clean[3:]
    elif phone_clean.startswith('0'):
        phone_clean = phone_clean[1:]
    
    if len(phone_clean) == 10:
        return f"+91-{phone_clean}"
    elif len(phone_clean) > 10:
        return f"+91-{phone_clean[-10:]}"
    else:
        return None


def standardize_category(category):
    # Fix inconsistent category names
    if pd.isna(category) or category == '':
        return None
    
    category = str(category).strip()
    
    category_map = {
        'electronics': 'Electronics',
        'ELECTRONICS': 'Electronics',
        'furniture': 'Furniture',
        'furnitures': 'Furniture',
        'FURNITURE': 'Furniture',
        'stationery': 'Stationery',
        'Stationery ': 'Stationery',
        ' STATIONERY': 'Stationery',
        'kitchen': 'Kitchen Appliances',
        'kitchen appliances': 'Kitchen Appliances',
        'Kitchen Appliances': 'Kitchen Appliances',
        'KITCHEN': 'Kitchen Appliances'
    }
    
    for key, value in category_map.items():
        if category.lower() == key.lower():
            return value
    
    return category.title()


def parse_date(date_str):
    # Convert to YYYY-MM-DD format
    if pd.isna(date_str) or date_str == '':
        return None
    
    date_str = str(date_str).strip()
    
    date_formats = [
        '%Y-%m-%d',
        '%d/%m/%Y',
        '%m-%d-%Y',
        '%d-%m-%Y',
        '%Y/%m/%d',
        '%m/%d/%Y'
    ]
    
    for fmt in date_formats:
        try:
            return datetime.strptime(date_str, fmt).strftime('%Y-%m-%d')
        except ValueError:
            continue
    
    logging.warning(f"Could not parse date: {date_str}")
    return None


def extract_customers():
    try:
        df = pd.read_csv('data/customers_raw.csv')
        quality_metrics['customers']['records_read'] = len(df)
        logging.info(f"Read {len(df)} customer records from CSV")
        return df
    except Exception as e:
        logging.error(f"Failed to read customers file: {e}")
        raise


def transform_customers(df):
    original_count = len(df)
    
    df['old_customer_id'] = df['customer_id'].copy()
    
    df = df.drop_duplicates(subset=['customer_id'], keep='first')
    duplicates_removed = original_count - len(df)
    quality_metrics['customers']['duplicates_removed'] = duplicates_removed
    logging.info(f"Removed {duplicates_removed} duplicate records")
    
    missing_emails = df['email'].isna().sum() + (df['email'] == '').sum()
    df = df.dropna(subset=['email'])
    df = df[df['email'] != '']
    quality_metrics['customers']['missing_values_handled'] += missing_emails
    if missing_emails > 0:
        logging.info(f"Dropped {missing_emails} records with missing emails")
    
    df['phone'] = df['phone'].apply(standardize_phone)
    df['registration_date'] = df['registration_date'].apply(parse_date)
    
    invalid_dates = df['registration_date'].isna().sum()
    if invalid_dates > 0:
        df = df.dropna(subset=['registration_date'])
        quality_metrics['customers']['missing_values_handled'] += invalid_dates
        logging.info(f"Dropped {invalid_dates} records with bad dates")
    
    df['first_name'] = df['first_name'].str.strip()
    df['last_name'] = df['last_name'].str.strip()
    df['email'] = df['email'].str.strip().str.lower()
    df['city'] = df['city'].str.strip()
    
    logging.info(f"After transformation: {len(df)} customer records")
    return df


def extract_products():
    try:
        df = pd.read_csv('data/products_raw.csv')
        quality_metrics['products']['records_read'] = len(df)
        logging.info(f"Extracted {len(df)} product records")
        return df
    except Exception as e:
        logging.error(f"Error extracting products: {e}")
        raise


def transform_products(df):
    original_count = len(df)
    
    df['old_product_id'] = df['product_id'].copy()
    
    df = df.drop_duplicates(subset=['product_id'], keep='first')
    duplicates_removed = original_count - len(df)
    quality_metrics['products']['duplicates_removed'] = duplicates_removed
    if duplicates_removed > 0:
        logging.info(f"Removed {duplicates_removed} duplicate products")
    
    missing_prices = df['price'].isna().sum() + (df['price'] == '').sum()
    df['price'] = pd.to_numeric(df['price'], errors='coerce')
    
    df['price'] = df.groupby('category')['price'].transform(
        lambda x: x.fillna(x.median())
    )
    
    if df['price'].isna().any():
        overall_median = df['price'].median()
        df['price'] = df['price'].fillna(overall_median)
    
    quality_metrics['products']['missing_values_handled'] += missing_prices
    if missing_prices > 0:
        logging.info(f"Fixed {missing_prices} missing prices")
    
    df['category'] = df['category'].apply(standardize_category)
    
    null_categories = df['category'].isna().sum()
    if null_categories > 0:
        df = df.dropna(subset=['category'])
        quality_metrics['products']['missing_values_handled'] += null_categories
        logging.info(f"Dropped {null_categories} products with no category")
    
    missing_stock = df['stock'].isna().sum()
    df['stock'] = df['stock'].fillna(0)
    quality_metrics['products']['missing_values_handled'] += missing_stock
    if missing_stock > 0:
        logging.info(f"Set {missing_stock} missing stock values to 0")
    
    df['product_name'] = df['product_name'].str.strip()
    df['category'] = df['category'].str.strip()
    df['stock'] = df['stock'].astype(int)
    
    logging.info(f"Transformed {len(df)} products")
    return df


def extract_sales():
    try:
        df = pd.read_csv('data/sales_raw.csv')
        quality_metrics['sales']['records_read'] = len(df)
        logging.info(f"Extracted {len(df)} sales records")
        return df
    except Exception as e:
        logging.error(f"Error extracting sales: {e}")
        raise


def transform_sales(df):
    original_count = len(df)
    
    df = df.drop_duplicates(subset=['transaction_id'], keep='first')
    duplicates_removed = original_count - len(df)
    quality_metrics['sales']['duplicates_removed'] = duplicates_removed
    logging.info(f"Removed {duplicates_removed} duplicate sales records")
    
    missing_customer_ids = df['customer_id'].isna().sum() + (df['customer_id'] == '').sum()
    df = df.dropna(subset=['customer_id'])
    df = df[df['customer_id'] != '']
    quality_metrics['sales']['missing_values_handled'] += missing_customer_ids
    logging.info(f"Dropped {missing_customer_ids} records with missing customer_id")
    
    missing_product_ids = df['product_id'].isna().sum() + (df['product_id'] == '').sum()
    df = df.dropna(subset=['product_id'])
    df = df[df['product_id'] != '']
    quality_metrics['sales']['missing_values_handled'] += missing_product_ids
    logging.info(f"Dropped {missing_product_ids} records with missing product_id")
    
    df['transaction_date'] = df['transaction_date'].apply(parse_date)
    
    invalid_dates = df['transaction_date'].isna().sum()
    if invalid_dates > 0:
        df = df.dropna(subset=['transaction_date'])
        quality_metrics['sales']['missing_values_handled'] += invalid_dates
        logging.info(f"Dropped {invalid_dates} records with invalid dates")
    
    df['quantity'] = pd.to_numeric(df['quantity'], errors='coerce')
    df['unit_price'] = pd.to_numeric(df['unit_price'], errors='coerce')
    
    invalid_numeric = df['quantity'].isna().sum() + df['unit_price'].isna().sum()
    if invalid_numeric > 0:
        df = df.dropna(subset=['quantity', 'unit_price'])
        quality_metrics['sales']['missing_values_handled'] += invalid_numeric
        logging.info(f"Dropped {invalid_numeric} records with invalid numeric values")
    
    df['subtotal'] = df['quantity'] * df['unit_price']
    df['status'] = df['status'].str.strip().str.title()
    
    logging.info(f"Transformed {len(df)} sales records")
    return df


def create_database_schema(connection):
    try:
        cursor = connection.cursor()
        
        cursor.execute("CREATE DATABASE IF NOT EXISTS fleximart")
        cursor.execute("USE fleximart")
        
        cursor.execute("DROP TABLE IF EXISTS order_items")
        cursor.execute("DROP TABLE IF EXISTS orders")
        cursor.execute("DROP TABLE IF EXISTS products")
        cursor.execute("DROP TABLE IF EXISTS customers")
        cursor.execute("""
            CREATE TABLE customers (
                customer_id INT PRIMARY KEY AUTO_INCREMENT,
                first_name VARCHAR(50) NOT NULL,
                last_name VARCHAR(50) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                phone VARCHAR(20),
                city VARCHAR(50),
                registration_date DATE
            )
        """)
        
        cursor.execute("""
            CREATE TABLE products (
                product_id INT PRIMARY KEY AUTO_INCREMENT,
                product_name VARCHAR(100) NOT NULL,
                category VARCHAR(50) NOT NULL,
                price DECIMAL(10,2) NOT NULL,
                stock_quantity INT DEFAULT 0
            )
        """)
        
        cursor.execute("""
            CREATE TABLE orders (
                order_id INT PRIMARY KEY AUTO_INCREMENT,
                customer_id INT NOT NULL,
                order_date DATE NOT NULL,
                total_amount DECIMAL(10,2) NOT NULL,
                status VARCHAR(20) DEFAULT 'Pending',
                FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
            )
        """)
        cursor.execute("""
            CREATE TABLE order_items (
                order_item_id INT PRIMARY KEY AUTO_INCREMENT,
                order_id INT NOT NULL,
                product_id INT NOT NULL,
                quantity INT NOT NULL,
                unit_price DECIMAL(10,2) NOT NULL,
                subtotal DECIMAL(10,2) NOT NULL,
                FOREIGN KEY (order_id) REFERENCES orders(order_id),
                FOREIGN KEY (product_id) REFERENCES products(product_id)
            )
        """)
        
        connection.commit()
        logging.info("Database schema created successfully")
        
    except Error as e:
        logging.error(f"Error creating database schema: {e}")
        raise
    finally:
        if cursor:
            cursor.close()


def load_customers(connection, df):
    try:
        cursor = connection.cursor()
        
        insert_query = """
            INSERT INTO customers (first_name, last_name, email, phone, city, registration_date)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        
        customer_map = {}
        
        for _, row in df.iterrows():
            cursor.execute(insert_query, (
                row['first_name'],
                row['last_name'],
                row['email'],
                row['phone'],
                row['city'],
                row['registration_date']
            ))
            new_id = cursor.lastrowid
            old_id = row['old_customer_id']
            customer_map[old_id] = new_id
        
        connection.commit()
        
        quality_metrics['customers']['records_loaded'] = len(customer_map)
        logging.info(f"Loaded {len(customer_map)} customers into database")
        
        return customer_map
        
    except Error as e:
        logging.error(f"Error loading customers: {e}")
        connection.rollback()
        raise
    finally:
        if cursor:
            cursor.close()


def load_products(connection, df):
    try:
        cursor = connection.cursor()
        
        insert_query = """
            INSERT INTO products (product_name, category, price, stock_quantity)
            VALUES (%s, %s, %s, %s)
        """
        
        product_map = {}
        
        for _, row in df.iterrows():
            cursor.execute(insert_query, (
                row['product_name'],
                row['category'],
                float(row['price']),
                int(row['stock'])
            ))
            new_product_id = cursor.lastrowid
            old_product_id = row['old_product_id']
            product_map[old_product_id] = new_product_id
        
        connection.commit()
        
        quality_metrics['products']['records_loaded'] = len(product_map)
        logging.info(f"Loaded {len(product_map)} product records")
        
        return product_map
        
    except Error as e:
        logging.error(f"Error loading products: {e}")
        connection.rollback()
        raise
    finally:
        if cursor:
            cursor.close()


def load_sales(connection, df, customer_map, product_map):
    try:
        cursor = connection.cursor()
        
        df['new_customer_id'] = df['customer_id'].map(customer_map)
        df['new_product_id'] = df['product_id'].map(product_map)
        
        invalid_mappings = df['new_customer_id'].isna().sum() + df['new_product_id'].isna().sum()
        df = df.dropna(subset=['new_customer_id', 'new_product_id'])
        quality_metrics['sales']['missing_values_handled'] += invalid_mappings
        if invalid_mappings > 0:
            logging.info(f"Dropped {invalid_mappings} sales with invalid IDs")
        
        orders_df = df.groupby(['new_customer_id', 'transaction_date', 'status']).agg({
            'subtotal': 'sum'
        }).reset_index()
        orders_df.columns = ['customer_id', 'order_date', 'status', 'total_amount']
        
        order_id_map = {}
        insert_order_query = """
            INSERT INTO orders (customer_id, order_date, total_amount, status)
            VALUES (%s, %s, %s, %s)
        """
        
        for _, order_row in orders_df.iterrows():
            cursor.execute(insert_order_query, (
                int(order_row['customer_id']),
                order_row['order_date'],
                float(order_row['total_amount']),
                order_row['status']
            ))
            new_order_id = cursor.lastrowid
            key = (int(order_row['customer_id']), order_row['order_date'], order_row['status'])
            order_id_map[key] = new_order_id
        
        connection.commit()
        logging.info(f"Created {len(order_id_map)} orders")
        
        insert_item_query = """
            INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal)
            VALUES (%s, %s, %s, %s, %s)
        """
        
        item_records = []
        for _, row in df.iterrows():
            key = (int(row['new_customer_id']), row['transaction_date'], row['status'])
            if key in order_id_map:
                order_id = order_id_map[key]
                item_records.append((
                    order_id,
                    int(row['new_product_id']),
                    int(row['quantity']),
                    float(row['unit_price']),
                    float(row['subtotal'])
                ))
        
        if item_records:
            cursor.executemany(insert_item_query, item_records)
            connection.commit()
        
        quality_metrics['sales']['records_loaded'] = len(item_records)
        logging.info(f"Loaded {len(item_records)} order items")
        
    except Error as e:
        logging.error(f"Error loading sales: {e}")
        connection.rollback()
        raise
    finally:
        if cursor:
            cursor.close()


def generate_quality_report():
    report = []
    report.append("=" * 60)
    report.append("DATA QUALITY REPORT")
    report.append("=" * 60)
    report.append("")
    
    for table_name, metrics in quality_metrics.items():
        report.append(f"Table: {table_name.upper()}")
        report.append("-" * 60)
        report.append(f"  Records Read:           {metrics['records_read']}")
        report.append(f"  Duplicates Removed:     {metrics['duplicates_removed']}")
        report.append(f"  Missing Values Handled: {metrics['missing_values_handled']}")
        report.append(f"  Records Loaded:         {metrics['records_loaded']}")
        report.append("")
    
    report.append("=" * 60)
    report.append("END OF REPORT")
    report.append("=" * 60)
    
    report_text = "\n".join(report)
    
    with open('data_quality_report.txt', 'w') as f:
        f.write(report_text)
    
    logging.info("Data quality report generated")
    print(report_text)


def main():
    connection = None
    try:
        logging.info("Starting ETL Pipeline...")
        
        connection = mysql.connector.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password']
        )
        
        if connection.is_connected():
            logging.info("Connected to MySQL")
        
        create_database_schema(connection)
        
        logging.info("=" * 60)
        logging.info("EXTRACT PHASE")
        logging.info("=" * 60)
        customers_df = extract_customers()
        products_df = extract_products()
        sales_df = extract_sales()
        
        logging.info("=" * 60)
        logging.info("TRANSFORM PHASE")
        logging.info("=" * 60)
        customers_df = transform_customers(customers_df)
        products_df = transform_products(products_df)
        
        logging.info("=" * 60)
        logging.info("LOAD PHASE")
        logging.info("=" * 60)
        customer_map = load_customers(connection, customers_df)
        product_map = load_products(connection, products_df)
        
        sales_df = transform_sales(sales_df)
        load_sales(connection, sales_df, customer_map, product_map)
        
        generate_quality_report()
        
        logging.info("ETL Pipeline completed successfully!")
        
    except Error as e:
        logging.error(f"Database error: {e}")
    except Exception as e:
        logging.error(f"Error: {e}")
    finally:
        if connection and connection.is_connected():
            connection.close()
            logging.info("Closed database connection")


if __name__ == "__main__":
    main()

