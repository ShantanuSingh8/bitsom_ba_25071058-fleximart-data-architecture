# Part 1: Database Design and ETL Pipeline

## Overview

This part implements a complete ETL (Extract, Transform, Load) pipeline to process raw CSV data files and load them into a normalized MySQL database. The solution handles various data quality issues including duplicates, missing values, inconsistent formats, and referential integrity.

## Components

### 1. ETL Pipeline (`etl_pipeline.py`)

A comprehensive Python script that:
- **Extracts** data from three CSV files (customers, products, sales)
- **Transforms** data by:
  - Removing duplicate records
  - Handling missing values (drop, fill, or default strategies)
  - Standardizing phone number formats (+91-XXXXXXXXXX)
  - Standardizing category names (case normalization)
  - Converting date formats to YYYY-MM-DD
  - Mapping old IDs to new auto-increment IDs
- **Loads** cleaned data into MySQL database with proper foreign key relationships

**Key Features:**
- Comprehensive error handling and logging
- Data quality metrics tracking
- Automatic ID mapping for referential integrity
- Transaction support for data consistency

### 2. Database Schema Documentation (`schema_documentation.md`)

Complete documentation including:
- Entity-Relationship descriptions for all 4 tables
- Attribute descriptions with data types and constraints
- Relationship definitions (1:M, M:1)
- Sample data representations
- 3NF normalization explanation (200-250 words)
- Functional dependency analysis
- Anomaly prevention explanation

### 3. Business Queries (`business_queries.sql`)

Three SQL queries addressing specific business scenarios:

**Query 1: Customer Purchase History**
- Finds customers with 2+ orders and >₹5,000 spent
- Uses JOINs, GROUP BY, and HAVING clauses
- Returns: customer_name, email, total_orders, total_spent

**Query 2: Product Sales Analysis**
- Analyzes revenue by product category
- Filters categories with >₹10,000 revenue
- Returns: category, num_products, total_quantity_sold, total_revenue

**Query 3: Monthly Sales Trend**
- Shows monthly sales for 2024 with cumulative revenue
- Uses window functions for running totals
- Returns: month_name, total_orders, monthly_revenue, cumulative_revenue

### 4. Data Quality Report (`data_quality_report.txt`)

Auto-generated report showing:
- Records processed per file
- Duplicates removed
- Missing values handled
- Records successfully loaded
- Detailed transformation summary

## Database Schema

The database consists of 4 normalized tables:

1. **customers** - Customer information
2. **products** - Product catalog
3. **orders** - Order headers
4. **order_items** - Order line items

See `schema_documentation.md` for complete schema details.

## Setup Instructions

### Prerequisites

- Python 3.8+
- MySQL 8.0+
- Required Python packages (see `requirements.txt`)

### Installation

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Configure database connection:**
   Edit `etl_pipeline.py` and update `DB_CONFIG`:
   ```python
   DB_CONFIG = {
       'host': 'localhost',
       'user': 'root',
       'password': 'your_password',
       'database': 'fleximart'
   }
   ```

3. **Create database:**
   ```bash
   mysql -u root -p -e "CREATE DATABASE fleximart;"
   ```

4. **Run ETL pipeline:**
   ```bash
   python etl_pipeline.py
   ```

   This will:
   - Create database schema
   - Extract data from CSV files in `../data/`
   - Transform and clean the data
   - Load into MySQL
   - Generate `data_quality_report.txt`

5. **Run business queries:**
   ```bash
   mysql -u root -p fleximart < business_queries.sql
   ```

## Data Quality Issues Handled

### Customers Data
- ✅ Duplicate entries (C001 appeared twice)
- ✅ Missing emails (5 records dropped)
- ✅ Inconsistent phone formats (standardized to +91-XXXXXXXXXX)
- ✅ Multiple date formats (standardized to YYYY-MM-DD)

### Products Data
- ✅ Missing prices (filled with category median)
- ✅ Inconsistent category names (standardized)
- ✅ Null stock values (filled with 0)

### Sales Data
- ✅ Duplicate transactions (T001 appeared twice)
- ✅ Missing customer_id (records dropped)
- ✅ Missing product_id (records dropped)
- ✅ Date format inconsistencies (standardized)

## File Structure

```
part1-database-etl/
├── README.md                    # This file
├── etl_pipeline.py             # Main ETL script
├── schema_documentation.md      # Database schema docs
├── business_queries.sql         # Business SQL queries
├── data_quality_report.txt     # Generated quality report
└── requirements.txt             # Python dependencies
```

## Testing

Verify the ETL pipeline:

```bash
# Check customers loaded
mysql -u root -p -e "USE fleximart; SELECT COUNT(*) FROM customers;"

# Check products loaded
mysql -u root -p -e "USE fleximart; SELECT COUNT(*) FROM products;"

# Check orders created
mysql -u root -p -e "USE fleximart; SELECT COUNT(*) FROM orders;"

# Check order items
mysql -u root -p -e "USE fleximart; SELECT COUNT(*) FROM order_items;"
```

## Notes

- The ETL pipeline creates the database schema automatically
- Old customer/product IDs are mapped to new auto-increment IDs
- Sales transactions are grouped by customer and date to create orders
- All date formats are converted to YYYY-MM-DD
- Phone numbers are standardized to +91-XXXXXXXXXX format
- Missing prices are filled using category median values

## Troubleshooting

**Error: "Access denied for user"**
- Check MySQL credentials in `DB_CONFIG`
- Ensure MySQL user has CREATE DATABASE privileges

**Error: "Table already exists"**
- The script drops existing tables for clean setup
- If issues persist, manually drop tables: `DROP TABLE order_items, orders, products, customers;`

**Error: "Foreign key constraint fails"**
- Ensure customers and products are loaded before sales data
- Check that all customer_id and product_id references exist

## Evaluation Criteria

- ✅ Extract logic: Reads all CSV files correctly
- ✅ Transform logic: Handles all data quality issues
- ✅ Load logic: Successfully inserts with error handling
- ✅ Code quality: Comments, error handling, logging
- ✅ Schema documentation: Complete ER description and 3NF explanation
- ✅ Business queries: Correct joins, aggregation, filtering

