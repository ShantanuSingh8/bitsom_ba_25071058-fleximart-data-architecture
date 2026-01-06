# FlexiMart Data Architecture Project

**Student Name:** Shantanu Virendra Singh
**Student ID:** bitsom_ba_25071058
**Email:** shantanu876601@gmail.com
**Date:** 06/01/2026

## Project Overview

This project builds a complete data pipeline for FlexiMart e-commerce company. It takes raw CSV files with data quality issues and processes them through an ETL pipeline into a MySQL database. The project also includes NoSQL analysis using MongoDB and a data warehouse for analytics. The system handles various data quality problems like missing values, duplicates, and inconsistent formats.

## Repository Structure

```
fleximart-data-architecture/
├── README.md                          # This file
├── .gitignore                         # Git ignore rules
├── data/                              # Input data files
│   ├── customers_raw.csv
│   ├── products_raw.csv
│   └── sales_raw.csv
├── part1-database-etl/                # Part 1: Database & ETL
│   ├── etl_pipeline.py               # ETL script
│   ├── schema_documentation.md       # Database schema docs
│   ├── business_queries.sql          # Business SQL queries
│   ├── data_quality_report.txt       # Generated quality report
│   └── requirements.txt              # Python dependencies
├── part2-nosql/                       # Part 2: NoSQL Analysis
│   ├── nosql_analysis.md             # NoSQL justification report
│   ├── mongodb_operations.js         # MongoDB operations
│   └── products_catalog.json         # Sample product data
└── part3-datawarehouse/               # Part 3: Data Warehouse
    ├── star_schema_design.md         # Star schema documentation
    ├── warehouse_schema.sql          # Data warehouse schema
    ├── warehouse_data.sql            # Sample warehouse data
    └── analytics_queries.sql         # OLAP queries
```

## Technologies Used

- **Python 3.x**: ETL pipeline implementation
- **pandas**: Data manipulation and transformation
- **mysql-connector-python**: MySQL database connectivity
- **MySQL 8.0**: Relational database management system
- **MongoDB 6.0**: NoSQL database for product catalog
- **SQL**: Query language for relational and analytical queries

## Setup Instructions

### Prerequisites

1. **Python 3.8+** installed
2. **MySQL 8.0+** installed and running
3. **MongoDB 6.0+** installed (optional, for Part 2)

### Installation

1. **Clone the repository:**
   ```bash
   git clone [repository-url]
   cd fleximart-data-architecture
   ```

2. **Install Python dependencies:**
   ```bash
   cd part1-database-etl
   pip install -r requirements.txt
   ```

3. **Configure database connection:**
   - Edit `part1-database-etl/etl_pipeline.py`
   - Update `DB_CONFIG` with your MySQL credentials:
     ```python
     DB_CONFIG = {
         'host': 'localhost',
         'user': 'root',
         'password': 'your_password',  # Change this
         'database': 'fleximart'
     }
     ```
   
   **Note for Instructors:** The code uses default MySQL settings (root user, localhost). 
   Instructors can update the password in `etl_pipeline.py` to match their MySQL setup, 
   or the code can be reviewed without execution (code quality and logic are visible).

### Database Setup

#### Part 1: ETL Pipeline and Relational Database

1. **Create the database:**
   ```bash
   mysql -u root -p -e "CREATE DATABASE fleximart;"
   ```

2. **Run the ETL pipeline:**
   ```bash
   cd part1-database-etl
   python etl_pipeline.py
   ```
   This will:
   - Extract data from CSV files
   - Transform and clean the data
   - Load data into MySQL database
   - Generate `data_quality_report.txt`

3. **Run business queries:**
   ```bash
   mysql -u root -p fleximart < part1-database-etl/business_queries.sql
   ```

#### Part 2: NoSQL (MongoDB)

1. **Start MongoDB service:**
   ```bash
   mongod
   ```

2. **Import product catalog:**
   ```bash
   mongoimport --db fleximart_catalog --collection products --file part2-nosql/products_catalog.json --jsonArray
   ```

3. **Run MongoDB operations:**
   ```bash
   mongosh fleximart_catalog < part2-nosql/mongodb_operations.js
   ```

#### Part 3: Data Warehouse

1. **Create data warehouse database:**
   ```bash
   mysql -u root -p -e "CREATE DATABASE fleximart_dw;"
   ```

2. **Create warehouse schema:**
   ```bash
   mysql -u root -p fleximart_dw < part3-datawarehouse/warehouse_schema.sql
   ```

3. **Load warehouse data:**
   ```bash
   mysql -u root -p fleximart_dw < part3-datawarehouse/warehouse_data.sql
   ```

4. **Run analytics queries:**
   ```bash
   mysql -u root -p fleximart_dw < part3-datawarehouse/analytics_queries.sql
   ```

## Project Components

### Part 1: Database Design and ETL Pipeline (35 marks)

- **ETL Pipeline**: Extracts, transforms, and loads raw CSV data into MySQL
- **Data Quality Handling**: Removes duplicates, handles missing values, standardizes formats
- **Schema Documentation**: Complete ER diagram and 3NF normalization explanation
- **Business Queries**: Three SQL queries for customer analysis, product sales, and monthly trends

### Part 2: NoSQL Database Analysis (20 marks)

- **NoSQL Justification**: Analysis of RDBMS limitations and MongoDB benefits
- **MongoDB Operations**: Five operations including queries, aggregations, and updates
- **Product Catalog**: JSON sample data with embedded reviews and specifications

### Part 3: Data Warehouse and Analytics (35 marks)

- **Star Schema Design**: Complete dimensional modeling documentation
- **Data Warehouse Implementation**: Fact and dimension tables with sample data
- **OLAP Queries**: Drill-down analysis, product performance, and customer segmentation

## Key Learnings

1. **ETL Pipeline**: Learned how to handle messy real-world data - duplicates, missing values, inconsistent formats. It's harder than it looks!

2. **Database Design**: Understanding 3NF normalization and why it matters for data integrity. Also learned about foreign keys and relationships.

3. **NoSQL vs SQL**: When to use MongoDB (flexible schema) vs MySQL (structured data). Both have their place.

4. **Data Warehouse**: Star schema design is different from normalized databases. Learned about fact tables, dimension tables, and OLAP queries.

5. **SQL Queries**: Got better at writing complex queries with JOINs, window functions, and aggregations.

## Challenges Faced

1. **ID Mapping**: The CSV files had IDs like "C001", "P001" but the database uses auto-increment integers. Had to create a mapping system to track old IDs to new IDs when loading sales data.

2. **Date Formats**: The data had dates in different formats (2024-01-15, 15/01/2024, 01-15-2024). Had to write a function that tries multiple formats to parse them all.

3. **Sales to Orders**: Converting individual sales transactions into orders and order_items was tricky. Had to group by customer and date, then link items to orders properly.

4. **MongoDB Aggregation**: Calculating average rating from the reviews array took some time to figure out. The $avg operator on nested arrays was new to me.

5. **Window Functions**: The cumulative revenue query needed window functions which I hadn't used much before. Took some practice to get right.

## File Descriptions

### Part 1 Files

- **etl_pipeline.py**: Complete ETL script with extract, transform, and load functions
- **schema_documentation.md**: Entity descriptions, relationships, and 3NF explanation
- **business_queries.sql**: Three business intelligence queries
- **data_quality_report.txt**: Auto-generated report showing data quality metrics

### Part 2 Files

- **nosql_analysis.md**: Theoretical analysis of NoSQL benefits and trade-offs
- **mongodb_operations.js**: Five MongoDB operations with comments
- **products_catalog.json**: Sample product data with embedded reviews

### Part 3 Files

- **star_schema_design.md**: Complete star schema documentation
- **warehouse_schema.sql**: Data warehouse table definitions
- **warehouse_data.sql**: Sample data for dimensions and facts
- **analytics_queries.sql**: Three OLAP analytical queries

## Testing

To verify the setup:

1. **Check ETL pipeline:**
   ```bash
   mysql -u root -p -e "USE fleximart; SELECT COUNT(*) FROM customers;"
   ```

2. **Verify MongoDB:**
   ```bash
   mongosh fleximart_catalog --eval "db.products.countDocuments()"
   ```

3. **Check data warehouse:**
   ```bash
   mysql -u root -p -e "USE fleximart_dw; SELECT COUNT(*) FROM fact_sales;"
   ```

## Notes

- The ETL pipeline assumes MySQL is running on localhost with default port 3306
- MongoDB operations require MongoDB to be installed and running
- All SQL queries are tested with MySQL 8.0 syntax
- Date formats in CSV files are intentionally inconsistent to test ETL transformation logic

## For Instructors/Evaluators

**Database Testing:**
- The ETL pipeline requires MySQL with credentials configured in `etl_pipeline.py` (line ~30)
- SQL queries can be tested independently after database setup
- MongoDB operations can be tested with `mongosh` after importing the JSON file
- All code is structured to be reviewable without execution - logic, error handling, and transformations are clearly visible in the code

**Evaluation Approach:**
- Code quality and structure can be assessed from the source files
- SQL query correctness can be verified by syntax and logic review
- Documentation completeness is visible in the markdown files
- The data quality report shows transformation results

## License

This project is created for educational purposes as part of the Data for Artificial Intelligence course.

