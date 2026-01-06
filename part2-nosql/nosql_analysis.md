# NoSQL Database Analysis for FlexiMart

## Section A: Limitations of RDBMS (150 words)

Relational database management systems (RDBMS) face significant challenges when handling diverse product catalogs with varying attributes. First, products have fundamentally different attribute structures—laptops require specifications like RAM, processor, and storage capacity, while shoes need size, color, and material. In a relational model, this forces either creating sparse tables with many NULL values or maintaining separate tables for each product type, both of which are inefficient and difficult to query.

Second, frequent schema changes become problematic. Adding a new product category with unique attributes (e.g., books requiring ISBN, author, publisher) requires ALTER TABLE statements, which can lock tables and disrupt operations. This rigidity makes it difficult to adapt quickly to market demands.

Third, storing customer reviews as nested data is unnatural in RDBMS. Reviews are best represented as arrays of documents containing user, rating, comment, and date. In relational databases, this requires a separate reviews table with foreign keys, leading to complex JOIN operations for simple queries like "show all reviews for a product." The normalized structure, while ensuring data integrity, creates performance overhead and query complexity that doesn't align with how product and review data is naturally accessed.

## Section B: NoSQL Benefits (150 words)

MongoDB addresses these RDBMS limitations through its flexible document-based architecture. The flexible schema allows each product document to have different attributes without requiring NULL placeholders or multiple tables. A laptop document can contain `{ram: "8GB", processor: "Intel i7"}` while a shoe document has `{size: 10, color: "Black"}`, all within the same collection. This eliminates the need for schema migrations when adding new product types.

Embedded documents solve the review storage problem elegantly. Reviews can be stored directly within the product document as an array: `reviews: [{user: "U001", rating: 5, comment: "Great!", date: ISODate()}]`. This enables single-query retrieval of products with their reviews, eliminating expensive JOIN operations. Queries like finding products with average rating >= 4.0 become straightforward aggregation operations on embedded arrays.

Horizontal scalability allows MongoDB to distribute data across multiple servers, handling growing product catalogs and increasing query loads. Sharding partitions data by category or region, enabling linear performance scaling that RDBMS struggles to achieve with its ACID constraints and complex JOIN operations.

## Section C: Trade-offs (100 words)

Using MongoDB instead of MySQL for the product catalog introduces two significant disadvantages. First, MongoDB lacks ACID transaction guarantees across multiple documents. While single-document operations are atomic, complex operations spanning multiple products (e.g., updating inventory across related items) cannot guarantee all-or-nothing execution, potentially leading to data inconsistencies.

Second, MongoDB's flexible schema, while advantageous for diverse products, can lead to data quality issues. Without enforced schemas, inconsistent field names (e.g., "price" vs "Price" vs "product_price") can emerge, making queries and application logic more complex. MySQL's rigid schema enforces consistency, preventing such issues at the database level, whereas MongoDB requires application-level validation and discipline to maintain data quality.

