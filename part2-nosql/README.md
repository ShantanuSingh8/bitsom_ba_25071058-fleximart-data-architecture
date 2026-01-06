# Part 2: NoSQL Database Analysis

## Overview

This part analyzes the suitability of MongoDB for FlexiMart's product catalog and implements basic MongoDB operations. The solution includes theoretical analysis comparing RDBMS and NoSQL approaches, along with practical MongoDB queries and operations.

## Components

### 1. NoSQL Analysis Report (`nosql_analysis.md`)

A comprehensive theoretical analysis covering:

**Section A: Limitations of RDBMS (150 words)**
- Explains why relational databases struggle with:
  - Products having different attributes (laptops vs shoes)
  - Frequent schema changes when adding new product types
  - Storing customer reviews as nested data

**Section B: NoSQL Benefits (150 words)**
- Explains how MongoDB solves these problems using:
  - Flexible schema (document structure)
  - Embedded documents (reviews within products)
  - Horizontal scalability

**Section C: Trade-offs (100 words)**
- Identifies two disadvantages of MongoDB vs MySQL:
  - Lack of ACID transaction guarantees across documents
  - Potential data quality issues without enforced schemas

### 2. MongoDB Operations (`mongodb_operations.js`)

Five MongoDB operations demonstrating:

**Operation 1: Load Data**
- Imports product catalog JSON into MongoDB collection
- Uses `insertMany()` or `mongoimport` command

**Operation 2: Basic Query**
- Finds Electronics products with price < ₹50,000
- Returns only: name, price, stock
- Uses `find()` with projection

**Operation 3: Review Analysis**
- Finds products with average rating >= 4.0
- Uses aggregation pipeline with `$avg` operator
- Calculates average from embedded reviews array

**Operation 4: Update Operation**
- Adds new review to product "ELEC001"
- Uses `updateOne()` with `$push` operator
- Includes user, rating, comment, and date

**Operation 5: Complex Aggregation**
- Calculates average price by category
- Groups by category, calculates avg_price and product_count
- Sorts by avg_price descending
- Uses `$group`, `$project`, and `$sort` stages

### 3. Product Catalog (`products_catalog.json`)

Sample JSON data with 10 products across 2 categories:
- **Electronics**: 5 products (phones, laptops, headphones, tablets, cameras)
- **Footwear**: 5 products (various shoe brands)

Each product includes:
- Basic info: product_id, name, category, price, stock
- Specs: Category-specific attributes (RAM, storage, size, color, etc.)
- Reviews: Embedded array with user, rating, comment, date

## MongoDB Schema Design

### Product Document Structure

```json
{
  "product_id": "ELEC001",
  "name": "Samsung Galaxy S21",
  "category": "Electronics",
  "price": 799.99,
  "stock": 150,
  "specs": {
    "ram": "8GB",
    "storage": "128GB",
    "screen_size": "6.2 inches"
  },
  "reviews": [
    {
      "user": "U001",
      "rating": 5,
      "comment": "Great phone!",
      "date": ISODate("2024-01-15")
    }
  ]
}
```

**Key Design Decisions:**
- Embedded reviews for fast retrieval
- Flexible specs object for category-specific attributes
- No fixed schema - each product can have different attributes

## Setup Instructions

### Prerequisites

- MongoDB 6.0+ installed
- MongoDB shell (mongosh) or MongoDB Compass

### Installation

1. **Start MongoDB service:**
   ```bash
   mongod
   ```

2. **Import product catalog:**
   ```bash
   mongoimport --db fleximart_catalog --collection products --file products_catalog.json --jsonArray
   ```

   Or use MongoDB Compass to import the JSON file.

3. **Run MongoDB operations:**
   ```bash
   mongosh fleximart_catalog < mongodb_operations.js
   ```

   Or copy-paste operations into MongoDB shell interactively.

### Alternative: Run Operations Individually

```bash
# Connect to MongoDB
mongosh fleximart_catalog

# Then run each operation from mongodb_operations.js
```

## File Structure

```
part2-nosql/
├── README.md                    # This file
├── nosql_analysis.md           # Theoretical analysis
├── mongodb_operations.js       # MongoDB operations
└── products_catalog.json        # Sample product data
```

## MongoDB Operations Explained

### Operation 1: Load Data
```javascript
db.products.insertMany([...])
```
Loads product documents into the collection.

### Operation 2: Basic Query
```javascript
db.products.find(
  { category: "Electronics", price: { $lt: 50000 } },
  { _id: 0, name: 1, price: 1, stock: 1 }
)
```
Filters and projects specific fields.

### Operation 3: Review Analysis
```javascript
db.products.aggregate([
  { $project: { avg_rating: { $avg: "$reviews.rating" } } },
  { $match: { avg_rating: { $gte: 4.0 } } }
])
```
Uses aggregation to calculate average rating from array.

### Operation 4: Update Operation
```javascript
db.products.updateOne(
  { product_id: "ELEC001" },
  { $push: { reviews: { user: "U999", rating: 4, ... } } }
)
```
Adds new review to embedded array.

### Operation 5: Complex Aggregation
```javascript
db.products.aggregate([
  { $group: { _id: "$category", avg_price: { $avg: "$price" } } },
  { $sort: { avg_price: -1 } }
])
```
Groups by category and calculates statistics.

## Testing

Verify MongoDB setup:

```bash
# Connect to MongoDB
mongosh fleximart_catalog

# Count documents
db.products.countDocuments()

# View sample document
db.products.findOne()

# Test Operation 2
db.products.find(
  { category: "Electronics", price: { $lt: 50000 } },
  { _id: 0, name: 1, price: 1, stock: 1 }
)
```

## Key Concepts

### Flexible Schema
- Each product document can have different attributes
- Electronics have RAM, storage; Shoes have size, color
- No need for NULL values or separate tables

### Embedded Documents
- Reviews stored within product documents
- Single query retrieves product with all reviews
- No JOIN operations needed

### Aggregation Pipeline
- Powerful framework for data transformation
- Stages: $match, $project, $group, $sort
- Enables complex analytical queries

## Advantages of MongoDB for Product Catalog

1. **Schema Flexibility**: Easy to add new product types without ALTER TABLE
2. **Performance**: Embedded documents reduce JOIN overhead
3. **Scalability**: Horizontal scaling through sharding
4. **Developer Experience**: JSON-like documents match application data structures

## Trade-offs

1. **ACID Transactions**: Limited to single document operations
2. **Data Consistency**: Requires application-level validation
3. **Query Complexity**: Complex relationships harder than SQL JOINs
4. **Learning Curve**: Different query language and concepts

## Evaluation Criteria

- ✅ RDBMS limitations: Clear understanding of relational constraints
- ✅ NoSQL benefits: Correct application of MongoDB features
- ✅ Trade-offs: Realistic disadvantages identified
- ✅ MongoDB operations: Correct syntax, proper aggregation, comments
- ✅ Word limits: All sections within specified limits

## Troubleshooting

**Error: "MongoServerError: not authorized"**
- Ensure MongoDB authentication is configured
- Check user permissions for database

**Error: "collection already exists"**
- Drop existing collection: `db.products.drop()`
- Or use `insertMany()` which handles existing data

**Aggregation returns empty results**
- Check that reviews array exists and has data
- Verify field names match document structure
- Use `$ifNull` to handle missing arrays

## Additional Resources

- [MongoDB Documentation](https://docs.mongodb.com/)
- [MongoDB Aggregation Framework](https://docs.mongodb.com/manual/aggregation/)
- [MongoDB Query Operators](https://docs.mongodb.com/manual/reference/operator/query/)

