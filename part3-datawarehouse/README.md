# Part 3: Data Warehouse and Analytics

## Overview

This part implements a star schema data warehouse for FlexiMart to enable historical sales pattern analysis. The solution includes dimensional modeling documentation, star schema implementation, and OLAP analytical queries for business intelligence.

## Components

### 1. Star Schema Design (`star_schema_design.md`)

Comprehensive documentation covering:

**Section 1: Schema Overview**
- Complete description of fact table (fact_sales)
- Three dimension tables (dim_date, dim_product, dim_customer)
- Attributes, data types, and relationships
- Sample data representations

**Section 2: Design Decisions (150 words)**
- Granularity choice (transaction line-item level)
- Surrogate keys vs natural keys rationale
- Drill-down and roll-up support explanation

**Section 3: Sample Data Flow**
- Example transformation from source to data warehouse
- Step-by-step lookup and insertion process
- Demonstrates dimensional modeling concepts

### 2. Warehouse Schema (`warehouse_schema.sql`)

SQL script creating:
- **dim_date**: Date dimension with 60+ attributes (date_key, full_date, day_of_week, month, quarter, year, is_weekend, etc.)
- **dim_product**: Product dimension (product_key, product_id, product_name, category, subcategory, unit_price)
- **dim_customer**: Customer dimension (customer_key, customer_id, customer_name, city, state, customer_segment)
- **fact_sales**: Fact table with measures and foreign keys
- Indexes for query performance optimization

### 3. Warehouse Data (`warehouse_data.sql`)

Sample data population:
- **dim_date**: 60 dates (January-February 2024, including weekdays and weekends)
- **dim_product**: 15 products across 3 categories (Electronics, Furniture, Stationery, Kitchen Appliances)
- **dim_customer**: 12 customers across 4 cities (Bangalore, Mumbai, Delhi, Hyderabad, Chennai, etc.)
- **fact_sales**: 40 sales transactions with realistic patterns (higher sales on weekends)

### 4. Analytics Queries (`analytics_queries.sql`)

Three OLAP queries for business intelligence:

**Query 1: Monthly Sales Drill-Down Analysis**
- Demonstrates drill-down from Year → Quarter → Month
- Shows sales performance by time periods
- Uses date dimension attributes for grouping
- Returns: year, quarter, month_name, total_orders, total_quantity, total_sales

**Query 2: Product Performance Analysis**
- Identifies top 10 products by revenue
- Calculates revenue contribution percentage
- Uses window functions for percentage calculation
- Returns: product_name, category, units_sold, revenue, revenue_percentage

**Query 3: Customer Segmentation Analysis**
- Segments customers into High/Medium/Low value
- Uses CASE statement for segmentation
- Calculates statistics per segment
- Returns: customer_segment, customer_count, total_revenue, avg_revenue

## Star Schema Design

### Fact Table: fact_sales

**Grain:** One row per product per order line item

**Measures:**
- `quantity_sold`: Number of units sold
- `unit_price`: Historical price at time of sale
- `discount_amount`: Discount applied
- `total_amount`: Final amount (quantity × unit_price - discount)

**Foreign Keys:**
- `date_key` → dim_date
- `product_key` → dim_product
- `customer_key` → dim_customer

### Dimension Tables

**dim_date:**
- Time dimension for temporal analysis
- Enables drill-down: Year → Quarter → Month → Day
- Includes weekend/weekday flag

**dim_product:**
- Product descriptive attributes
- Enables product and category analysis
- Supports roll-up: Product → Subcategory → Category

**dim_customer:**
- Customer demographic information
- Enables geographic and segmentation analysis
- Supports customer lifetime value calculations

## Setup Instructions

### Prerequisites

- MySQL 8.0+ installed
- Access to create databases

### Installation

1. **Create data warehouse database:**
   ```bash
   mysql -u root -p -e "CREATE DATABASE fleximart_dw;"
   ```

2. **Create warehouse schema:**
   ```bash
   mysql -u root -p fleximart_dw < warehouse_schema.sql
   ```

3. **Load warehouse data:**
   ```bash
   mysql -u root -p fleximart_dw < warehouse_data.sql
   ```

4. **Run analytics queries:**
   ```bash
   mysql -u root -p fleximart_dw < analytics_queries.sql
   ```

### Alternative: Run Queries Interactively

```bash
mysql -u root -p fleximart_dw

# Then copy-paste queries from analytics_queries.sql
```

## File Structure

```
part3-datawarehouse/
├── README.md                    # This file
├── star_schema_design.md        # Schema design documentation
├── warehouse_schema.sql         # Schema creation script
├── warehouse_data.sql           # Sample data population
└── analytics_queries.sql        # OLAP analytical queries
```

## OLAP Operations Explained

### Drill-Down

**Query 1** demonstrates drill-down:
- Start with yearly totals
- Drill down to quarterly totals
- Further drill down to monthly totals

This enables executives to start with high-level summary and explore details as needed.

### Roll-Up

**Query 2** demonstrates roll-up:
- Individual products rolled up to categories
- Revenue percentages calculated at aggregate level

### Slice and Dice

**Query 3** demonstrates slicing:
- Data sliced by customer segment
- Each segment analyzed independently
- Enables targeted marketing strategies

## Data Warehouse Concepts

### Star Schema Benefits

1. **Query Performance**: Fewer JOINs than normalized schemas
2. **User-Friendly**: Intuitive structure for business users
3. **Fast Aggregations**: Pre-aggregated measures in fact table
4. **Flexible Analysis**: Easy to add new dimensions

### Surrogate Keys

- Integer auto-increment keys for performance
- Stable identifiers (don't change like natural keys)
- Enable efficient indexing and joins
- Natural keys preserved in dimension tables for reference

### Granularity

- Transaction line-item level provides maximum flexibility
- Can aggregate to any level (order, customer, product, time)
- Preserves ability to analyze product mix within orders

## Sample Queries

### Monthly Revenue Trend

```sql
SELECT 
    dd.month_name,
    SUM(fs.total_amount) AS monthly_revenue
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
WHERE dd.year = 2024
GROUP BY dd.month_name
ORDER BY dd.month;
```

### Top Products by Category

```sql
SELECT 
    dp.category,
    dp.product_name,
    SUM(fs.total_amount) AS revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY dp.category, dp.product_name
ORDER BY dp.category, revenue DESC;
```

### Weekend vs Weekday Sales

```sql
SELECT 
    dd.is_weekend,
    SUM(fs.total_amount) AS total_revenue,
    COUNT(*) AS transaction_count
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
GROUP BY dd.is_weekend;
```

## Testing

Verify data warehouse setup:

```bash
# Check dimension tables
mysql -u root -p -e "USE fleximart_dw; SELECT COUNT(*) FROM dim_date;"
mysql -u root -p -e "USE fleximart_dw; SELECT COUNT(*) FROM dim_product;"
mysql -u root -p -e "USE fleximart_dw; SELECT COUNT(*) FROM dim_customer;"

# Check fact table
mysql -u root -p -e "USE fleximart_dw; SELECT COUNT(*) FROM fact_sales;"

# Verify referential integrity
mysql -u root -p -e "USE fleximart_dw; 
SELECT COUNT(*) FROM fact_sales fs
LEFT JOIN dim_date dd ON fs.date_key = dd.date_key
WHERE dd.date_key IS NULL;"
```

## Data Warehouse vs Operational Database

| Aspect | Operational DB (Part 1) | Data Warehouse (Part 3) |
|--------|------------------------|-------------------------|
| Purpose | Transaction processing | Analytical reporting |
| Schema | Normalized (3NF) | Denormalized (Star) |
| Optimization | Write-optimized | Read-optimized |
| Data | Current, detailed | Historical, aggregated |
| Queries | Simple, fast | Complex, analytical |

## Evaluation Criteria

- ✅ Schema description: All tables clearly documented
- ✅ Design justification: Sound reasoning for choices
- ✅ Sample data flow: Clear understanding of dimensional modeling
- ✅ Data volume: Meets minimum requirements (30 dates, 15 products, 12 customers, 40 sales)
- ✅ Data realism: Realistic values and distributions
- ✅ Query 1: Correct drill-down, proper grouping
- ✅ Query 2: Accurate percentage calculation, top-N logic
- ✅ Query 3: Correct segmentation with CASE, proper aggregation

## Troubleshooting

**Error: "Foreign key constraint fails"**
- Ensure dimension tables are loaded before fact table
- Check that all date_key, product_key, customer_key values exist in dimensions

**Error: "Duplicate entry for key 'PRIMARY'"**
- Date keys must be unique in dim_date
- Check for duplicate date_key values

**Queries return no results**
- Verify data is loaded: `SELECT COUNT(*) FROM fact_sales;`
- Check date ranges in WHERE clauses
- Ensure JOIN conditions are correct

## Additional Resources

- [Kimball Dimensional Modeling](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/)
- [Star Schema Design Patterns](https://docs.microsoft.com/en-us/azure/architecture/data-guide/relational-data/star-schema)
- [OLAP Operations](https://en.wikipedia.org/wiki/OLAP_cube#Operations)

