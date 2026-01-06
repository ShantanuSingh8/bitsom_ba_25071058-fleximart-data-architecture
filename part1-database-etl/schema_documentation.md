# Database Schema Documentation

## Entity-Relationship Description

The FlexiMart database follows a normalized relational design with four main entities: customers, products, orders, and order_items. The schema implements a one-to-many relationship pattern where customers can place multiple orders, and each order can contain multiple items.

---

## ENTITY: customers

**Purpose:** Stores customer information and personal details for the e-commerce platform.

**Attributes:**
- `customer_id` (INT, PRIMARY KEY, AUTO_INCREMENT): Unique identifier for each customer. Automatically generated sequential integer.
- `first_name` (VARCHAR(50), NOT NULL): Customer's first name. Required field.
- `last_name` (VARCHAR(50), NOT NULL): Customer's last name. Required field.
- `email` (VARCHAR(100), UNIQUE, NOT NULL): Customer's email address. Must be unique across all customers and is required.
- `phone` (VARCHAR(20), NULLABLE): Customer's phone number in standardized format (+91-XXXXXXXXXX). Optional field.
- `city` (VARCHAR(50), NULLABLE): City where the customer is located. Optional field.
- `registration_date` (DATE, NULLABLE): Date when the customer registered on the platform. Format: YYYY-MM-DD.

**Relationships:**
- One customer can place MANY orders (1:M relationship with orders table)
- The relationship is enforced through the `customer_id` foreign key in the orders table

**Sample Data:**
| customer_id | first_name | last_name | email | phone | city | registration_date |
|-------------|------------|-----------|-------|-------|------|-------------------|
| 1 | Rahul | Sharma | rahul.sharma@gmail.com | +91-9876543210 | Bangalore | 2023-01-15 |
| 2 | Priya | Patel | priya.patel@yahoo.com | +91-9988776655 | Mumbai | 2023-02-20 |
| 3 | Amit | Kumar | amit.kumar@example.com | +91-9765432109 | Delhi | 2023-03-10 |

---

## ENTITY: products

**Purpose:** Stores product catalog information including pricing and inventory details.

**Attributes:**
- `product_id` (INT, PRIMARY KEY, AUTO_INCREMENT): Unique identifier for each product. Automatically generated sequential integer.
- `product_name` (VARCHAR(100), NOT NULL): Name of the product. Required field.
- `category` (VARCHAR(50), NOT NULL): Product category (e.g., Electronics, Furniture, Stationery, Kitchen Appliances). Required field.
- `price` (DECIMAL(10,2), NOT NULL): Product price in Indian Rupees. Supports up to 10 digits with 2 decimal places. Required field.
- `stock_quantity` (INT, DEFAULT 0): Number of units available in inventory. Defaults to 0 if not specified.

**Relationships:**
- One product can appear in MANY order_items (1:M relationship with order_items table)
- The relationship is enforced through the `product_id` foreign key in the order_items table

**Sample Data:**
| product_id | product_name | category | price | stock_quantity |
|------------|--------------|----------|-------|----------------|
| 1 | Laptop | Electronics | 55000.00 | 10 |
| 2 | Smartphone | Electronics | 35000.00 | 15 |
| 3 | Office Chair | Furniture | 8000.00 | 5 |

---

## ENTITY: orders

**Purpose:** Stores order header information including customer, date, total amount, and status.

**Attributes:**
- `order_id` (INT, PRIMARY KEY, AUTO_INCREMENT): Unique identifier for each order. Automatically generated sequential integer.
- `customer_id` (INT, NOT NULL, FOREIGN KEY): References the customer who placed the order. Must exist in customers table.
- `order_date` (DATE, NOT NULL): Date when the order was placed. Format: YYYY-MM-DD. Required field.
- `total_amount` (DECIMAL(10,2), NOT NULL): Total value of the order in Indian Rupees. Calculated as sum of all order_items subtotals. Required field.
- `status` (VARCHAR(20), DEFAULT 'Pending'): Order status (e.g., Pending, Completed, Cancelled). Defaults to 'Pending' if not specified.

**Relationships:**
- Many orders belong to ONE customer (M:1 relationship with customers table)
- One order can contain MANY order_items (1:M relationship with order_items table)
- Foreign key constraint ensures referential integrity with customers table

**Sample Data:**
| order_id | customer_id | order_date | total_amount | status |
|----------|-------------|------------|--------------|--------|
| 1 | 1 | 2024-01-15 | 45999.00 | Completed |
| 2 | 2 | 2024-01-16 | 5998.00 | Completed |
| 3 | 3 | 2024-01-18 | 52999.00 | Completed |

---

## ENTITY: order_items

**Purpose:** Stores individual line items within each order, linking products to orders with quantity and pricing details.

**Attributes:**
- `order_item_id` (INT, PRIMARY KEY, AUTO_INCREMENT): Unique identifier for each order item. Automatically generated sequential integer.
- `order_id` (INT, NOT NULL, FOREIGN KEY): References the parent order. Must exist in orders table.
- `product_id` (INT, NOT NULL, FOREIGN KEY): References the product being ordered. Must exist in products table.
- `quantity` (INT, NOT NULL): Number of units of the product ordered. Required field, must be positive.
- `unit_price` (DECIMAL(10,2), NOT NULL): Price per unit at the time of order. Required field.
- `subtotal` (DECIMAL(10,2), NOT NULL): Calculated value (quantity × unit_price). Required field.

**Relationships:**
- Many order_items belong to ONE order (M:1 relationship with orders table)
- Many order_items reference ONE product (M:1 relationship with products table)
- Foreign key constraints ensure referential integrity with both orders and products tables

**Sample Data:**
| order_item_id | order_id | product_id | quantity | unit_price | subtotal |
|---------------|----------|------------|----------|------------|----------|
| 1 | 1 | 1 | 1 | 45999.00 | 45999.00 |
| 2 | 2 | 4 | 2 | 2999.00 | 5998.00 |
| 3 | 3 | 7 | 1 | 52999.00 | 52999.00 |

---

## Normalization Explanation

This database design is in **Third Normal Form (3NF)**, which ensures data integrity and eliminates redundancy. The design satisfies 3NF requirements because:

### Functional Dependencies Identified:

1. **customers table:**
   - `customer_id` → `first_name`, `last_name`, `email`, `phone`, `city`, `registration_date`
   - `email` → `customer_id` (unique constraint)

2. **products table:**
   - `product_id` → `product_name`, `category`, `price`, `stock_quantity`

3. **orders table:**
   - `order_id` → `customer_id`, `order_date`, `total_amount`, `status`
   - `order_id`, `customer_id` → `order_date`, `total_amount`, `status`

4. **order_items table:**
   - `order_item_id` → `order_id`, `product_id`, `quantity`, `unit_price`, `subtotal`
   - `order_id`, `product_id` → `quantity`, `unit_price`, `subtotal`

### 3NF Compliance:

The design is in 3NF because:
1. **It satisfies 2NF:** All non-key attributes are fully functionally dependent on the primary key (no partial dependencies).
2. **No transitive dependencies:** No non-key attribute depends on another non-key attribute. For example, in the customers table, `city` does not depend on `email`; both depend directly on `customer_id`.

### Anomaly Prevention:

**Update Anomalies Avoided:**
- Product price changes only require updating one record in the products table, not multiple order_items records (price is stored at time of order in order_items.unit_price).
- Customer information updates (e.g., phone number) only affect the customers table.

**Insert Anomalies Avoided:**
- New products can be added without requiring an order to exist.
- New customers can be registered without requiring an order to exist.
- Orders can be created with proper foreign key references.

**Delete Anomalies Avoided:**
- Deleting an order does not delete customer or product information (cascade rules can be configured separately).
- Deleting a product does not automatically delete historical order_items (preserves order history).

### Design Benefits:

The normalized structure ensures data consistency, reduces storage requirements, and maintains referential integrity through foreign key constraints. The separation of orders and order_items allows for flexible order management where one order can contain multiple products, and the total_amount in orders can be calculated from the sum of order_items subtotals.

