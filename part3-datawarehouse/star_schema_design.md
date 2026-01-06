# Star Schema Design Documentation

## Section 1: Schema Overview

### FACT TABLE: fact_sales

**Grain:** One row per product per order line item

**Business Process:** Sales transactions

**Measures (Numeric Facts):**
- `quantity_sold` (INT, NOT NULL): Number of units sold in this transaction line item
- `unit_price` (DECIMAL(10,2), NOT NULL): Price per unit at the time of sale. This captures the historical price, which may differ from current product prices.
- `discount_amount` (DECIMAL(10,2), DEFAULT 0): Discount applied to this line item. Defaults to 0 if no discount.
- `total_amount` (DECIMAL(10,2), NOT NULL): Final amount for this line item, calculated as (quantity_sold × unit_price - discount_amount)

**Foreign Keys:**
- `date_key` (INT, NOT NULL) → References `dim_date.date_key`
- `product_key` (INT, NOT NULL) → References `dim_product.product_key`
- `customer_key` (INT, NOT NULL) → References `dim_customer.customer_key`

**Primary Key:** `sale_key` (INT, AUTO_INCREMENT) - Surrogate key for unique identification of each fact record

**Characteristics:**
- Contains only foreign keys and measures (facts)
- No descriptive attributes (those are in dimension tables)
- High volume table (grows with each transaction)
- Optimized for aggregation and analysis queries

---

### DIMENSION TABLE: dim_date

**Purpose:** Date dimension for time-based analysis. Enables time-series analysis, trend identification, and temporal drill-down operations.

**Type:** Conformed dimension (can be shared across multiple fact tables)

**Attributes:**
- `date_key` (INT, PRIMARY KEY): Surrogate key in integer format YYYYMMDD (e.g., 20240115 for January 15, 2024). This format enables efficient date range queries and sorting.
- `full_date` (DATE, NOT NULL): Actual date value in standard DATE format (YYYY-MM-DD)
- `day_of_week` (VARCHAR(10)): Day name (Monday, Tuesday, Wednesday, etc.)
- `day_of_month` (INT): Day number within the month (1-31)
- `month` (INT): Month number (1-12)
- `month_name` (VARCHAR(10)): Month name (January, February, March, etc.)
- `quarter` (VARCHAR(2)): Quarter identifier (Q1, Q2, Q3, Q4)
- `year` (INT): Year (e.g., 2023, 2024)
- `is_weekend` (BOOLEAN): Indicates if the date falls on a weekend (true) or weekday (false)

**Characteristics:**
- Pre-populated table (typically contains dates for multiple years)
- Relatively static (dates don't change)
- Enables efficient time-based filtering and grouping
- Supports drill-down from year → quarter → month → day

**Sample Records:**
| date_key | full_date | day_of_week | day_of_month | month | month_name | quarter | year | is_weekend |
|----------|-----------|------------|--------------|-------|------------|---------|------|------------|
| 20240115 | 2024-01-15 | Monday | 15 | 1 | January | Q1 | 2024 | false |
| 20240120 | 2024-01-20 | Saturday | 20 | 1 | January | Q1 | 2024 | true |

---

### DIMENSION TABLE: dim_product

**Purpose:** Product dimension containing descriptive attributes about products. Enables product-based analysis, category comparisons, and product performance tracking.

**Type:** Slowly Changing Dimension (SCD) - Type 2 if tracking historical changes, Type 1 for current snapshot

**Attributes:**
- `product_key` (INT, PRIMARY KEY, AUTO_INCREMENT): Surrogate key for unique product identification in the data warehouse
- `product_id` (VARCHAR(20)): Natural key from source system (e.g., "P001", "ELEC001")
- `product_name` (VARCHAR(100)): Name of the product (e.g., "Laptop Pro", "Samsung Galaxy S21")
- `category` (VARCHAR(50)): Product category (e.g., "Electronics", "Furniture", "Stationery")
- `subcategory` (VARCHAR(50)): More specific product classification (e.g., "Laptops", "Smartphones", "Office Chairs")
- `unit_price` (DECIMAL(10,2)): Current unit price of the product. Note: Historical prices are stored in fact_sales.unit_price

**Characteristics:**
- Contains descriptive attributes about products
- Relatively stable (products don't change frequently)
- Enables product-level and category-level analysis
- Supports filtering and grouping by category/subcategory

**Sample Records:**
| product_key | product_id | product_name | category | subcategory | unit_price |
|-------------|------------|--------------|----------|-------------|------------|
| 1 | P001 | Laptop Pro | Electronics | Laptops | 55000.00 |
| 2 | P002 | Smartphone | Electronics | Mobile Phones | 35000.00 |
| 3 | P004 | Office Chair | Furniture | Seating | 8000.00 |

---

### DIMENSION TABLE: dim_customer

**Purpose:** Customer dimension containing customer demographic and segmentation information. Enables customer-based analysis, segmentation, and customer lifetime value calculations.

**Type:** Slowly Changing Dimension - can be Type 1 (overwrite) or Type 2 (historical tracking) depending on business requirements

**Attributes:**
- `customer_key` (INT, PRIMARY KEY, AUTO_INCREMENT): Surrogate key for unique customer identification in the data warehouse
- `customer_id` (VARCHAR(20)): Natural key from source system (e.g., "C001", "CUST123")
- `customer_name` (VARCHAR(100)): Full name of the customer (e.g., "John Doe", "Rahul Sharma")
- `city` (VARCHAR(50)): City where the customer is located (e.g., "Mumbai", "Bangalore", "Delhi")
- `state` (VARCHAR(50)): State or province where the customer is located (e.g., "Maharashtra", "Karnataka")
- `customer_segment` (VARCHAR(20)): Customer segmentation classification (e.g., "High Value", "Medium Value", "Low Value", "VIP", "Regular")

**Characteristics:**
- Contains descriptive attributes about customers
- Enables geographic and segmentation analysis
- Supports customer lifetime value and behavior analysis
- Can be extended with additional demographic attributes (age, gender, etc.)

**Sample Records:**
| customer_key | customer_id | customer_name | city | state | customer_segment |
|--------------|-------------|---------------|------|-------|------------------|
| 1 | C001 | Rahul Sharma | Bangalore | Karnataka | High Value |
| 2 | C002 | Priya Patel | Mumbai | Maharashtra | Medium Value |
| 3 | C003 | Amit Kumar | Delhi | Delhi | Low Value |

---

## Section 2: Design Decisions (150 words)

**Granularity Choice (Transaction Line-Item Level):**

The fact table grain is set at the transaction line-item level (one row per product per order) rather than order-level aggregation. This granularity provides maximum analytical flexibility. Analysts can aggregate to order totals, product totals, or customer totals as needed. It preserves the ability to analyze which products were purchased together, product mix within orders, and individual product performance. While this increases fact table size, modern databases handle millions of rows efficiently, and the analytical benefits far outweigh storage costs.

**Surrogate Keys Instead of Natural Keys:**

Surrogate keys (integer auto-increment) are used instead of natural keys (like "C001", "P001") for several reasons. First, they provide consistent integer-based joins, which are faster than string comparisons. Second, they handle cases where natural keys might change in source systems. Third, they enable efficient indexing and foreign key relationships. Natural keys are preserved in dimension tables for reference, but surrogate keys ensure data warehouse stability and performance.

**Drill-Down and Roll-Up Support:**

The star schema design inherently supports OLAP operations. Drill-down from year → quarter → month is enabled through the date dimension's hierarchical attributes. Roll-up from product → category is supported by the product dimension's category grouping. The fact table's granularity allows aggregation at any level, while dimension tables provide the descriptive context needed for meaningful analysis.

---

## Section 3: Sample Data Flow

### Source Transaction:

**Order #101**
- Customer: "John Doe" (Customer ID: C012 in source system)
- Product: "Laptop" (Product ID: P001 in source system)
- Quantity: 2
- Unit Price: ₹50,000
- Order Date: 2024-01-15
- Discount: ₹0
- Total: ₹100,000

### Transformation to Data Warehouse:

**Step 1: Lookup Dimension Keys**

- **Date Dimension Lookup:**
  - Query: `SELECT date_key FROM dim_date WHERE full_date = '2024-01-15'`
  - Result: `date_key = 20240115`

- **Product Dimension Lookup:**
  - Query: `SELECT product_key FROM dim_product WHERE product_id = 'P001'`
  - Result: `product_key = 5`

- **Customer Dimension Lookup:**
  - Query: `SELECT customer_key FROM dim_customer WHERE customer_id = 'C012'`
  - Result: `customer_key = 12`

**Step 2: Insert into Fact Table**

```sql
INSERT INTO fact_sales (
    date_key, 
    product_key, 
    customer_key, 
    quantity_sold, 
    unit_price, 
    discount_amount, 
    total_amount
) VALUES (
    20240115,  -- date_key from dim_date
    5,         -- product_key from dim_product
    12,        -- customer_key from dim_customer
    2,         -- quantity_sold
    50000.00,  -- unit_price (historical price at time of sale)
    0.00,      -- discount_amount
    100000.00  -- total_amount (2 × 50000 - 0)
);
```

### Resulting Data Warehouse Records:

**fact_sales:**
```json
{
  "sale_key": 1,
  "date_key": 20240115,
  "product_key": 5,
  "customer_key": 12,
  "quantity_sold": 2,
  "unit_price": 50000.00,
  "discount_amount": 0.00,
  "total_amount": 100000.00
}
```

**dim_date (referenced by date_key = 20240115):**
```json
{
  "date_key": 20240115,
  "full_date": "2024-01-15",
  "day_of_week": "Monday",
  "day_of_month": 15,
  "month": 1,
  "month_name": "January",
  "quarter": "Q1",
  "year": 2024,
  "is_weekend": false
}
```

**dim_product (referenced by product_key = 5):**
```json
{
  "product_key": 5,
  "product_id": "P001",
  "product_name": "Laptop",
  "category": "Electronics",
  "subcategory": "Laptops",
  "unit_price": 55000.00  // Current price (may differ from historical)
}
```

**dim_customer (referenced by customer_key = 12):**
```json
{
  "customer_key": 12,
  "customer_id": "C012",
  "customer_name": "John Doe",
  "city": "Mumbai",
  "state": "Maharashtra",
  "customer_segment": "High Value"
}
```

### Analytical Query Example:

To analyze this transaction, a typical query would join all tables:

```sql
SELECT 
    dd.month_name,
    dp.category,
    dc.customer_segment,
    SUM(fs.total_amount) AS revenue
FROM 
    fact_sales fs
    JOIN dim_date dd ON fs.date_key = dd.date_key
    JOIN dim_product dp ON fs.product_key = dp.product_key
    JOIN dim_customer dc ON fs.customer_key = dc.customer_key
WHERE 
    fs.sale_key = 1
GROUP BY 
    dd.month_name, dp.category, dc.customer_segment;
```

This demonstrates how the star schema enables multi-dimensional analysis by joining the fact table with relevant dimension tables, allowing analysts to slice and dice data by time, product, customer, or any combination of dimensions.

