-- ============================================================
-- Data Warehouse Sample Data for FlexiMart
-- Part 3.2: Star Schema Data Population
-- ============================================================

USE fleximart_dw;

-- ============================================================
-- Insert Date Dimension Data (30 dates: January-February 2024)
-- ============================================================
INSERT INTO dim_date (date_key, full_date, day_of_week, day_of_month, month, month_name, quarter, year, is_weekend) VALUES
(20240101, '2024-01-01', 'Monday', 1, 1, 'January', 'Q1', 2024, false),
(20240102, '2024-01-02', 'Tuesday', 2, 1, 'January', 'Q1', 2024, false),
(20240103, '2024-01-03', 'Wednesday', 3, 1, 'January', 'Q1', 2024, false),
(20240104, '2024-01-04', 'Thursday', 4, 1, 'January', 'Q1', 2024, false),
(20240105, '2024-01-05', 'Friday', 5, 1, 'January', 'Q1', 2024, false),
(20240106, '2024-01-06', 'Saturday', 6, 1, 'January', 'Q1', 2024, true),
(20240107, '2024-01-07', 'Sunday', 7, 1, 'January', 'Q1', 2024, true),
(20240108, '2024-01-08', 'Monday', 8, 1, 'January', 'Q1', 2024, false),
(20240109, '2024-01-09', 'Tuesday', 9, 1, 'January', 'Q1', 2024, false),
(20240110, '2024-01-10', 'Wednesday', 10, 1, 'January', 'Q1', 2024, false),
(20240111, '2024-01-11', 'Thursday', 11, 1, 'January', 'Q1', 2024, false),
(20240112, '2024-01-12', 'Friday', 12, 1, 'January', 'Q1', 2024, false),
(20240113, '2024-01-13', 'Saturday', 13, 1, 'January', 'Q1', 2024, true),
(20240114, '2024-01-14', 'Sunday', 14, 1, 'January', 'Q1', 2024, true),
(20240115, '2024-01-15', 'Monday', 15, 1, 'January', 'Q1', 2024, false),
(20240116, '2024-01-16', 'Tuesday', 16, 1, 'January', 'Q1', 2024, false),
(20240117, '2024-01-17', 'Wednesday', 17, 1, 'January', 'Q1', 2024, false),
(20240118, '2024-01-18', 'Thursday', 18, 1, 'January', 'Q1', 2024, false),
(20240119, '2024-01-19', 'Friday', 19, 1, 'January', 'Q1', 2024, false),
(20240120, '2024-01-20', 'Saturday', 20, 1, 'January', 'Q1', 2024, true),
(20240121, '2024-01-21', 'Sunday', 21, 1, 'January', 'Q1', 2024, true),
(20240122, '2024-01-22', 'Monday', 22, 1, 'January', 'Q1', 2024, false),
(20240123, '2024-01-23', 'Tuesday', 23, 1, 'January', 'Q1', 2024, false),
(20240124, '2024-01-24', 'Wednesday', 24, 1, 'January', 'Q1', 2024, false),
(20240125, '2024-01-25', 'Thursday', 25, 1, 'January', 'Q1', 2024, false),
(20240126, '2024-01-26', 'Friday', 26, 1, 'January', 'Q1', 2024, false),
(20240127, '2024-01-27', 'Saturday', 27, 1, 'January', 'Q1', 2024, true),
(20240128, '2024-01-28', 'Sunday', 28, 1, 'January', 'Q1', 2024, true),
(20240129, '2024-01-29', 'Monday', 29, 1, 'January', 'Q1', 2024, false),
(20240130, '2024-01-30', 'Tuesday', 30, 1, 'January', 'Q1', 2024, false),
(20240131, '2024-01-31', 'Wednesday', 31, 1, 'January', 'Q1', 2024, false),
(20240201, '2024-02-01', 'Thursday', 1, 2, 'February', 'Q1', 2024, false),
(20240202, '2024-02-02', 'Friday', 2, 2, 'February', 'Q1', 2024, false),
(20240203, '2024-02-03', 'Saturday', 3, 2, 'February', 'Q1', 2024, true),
(20240204, '2024-02-04', 'Sunday', 4, 2, 'February', 'Q1', 2024, true),
(20240205, '2024-02-05', 'Monday', 5, 2, 'February', 'Q1', 2024, false),
(20240206, '2024-02-06', 'Tuesday', 6, 2, 'February', 'Q1', 2024, false),
(20240207, '2024-02-07', 'Wednesday', 7, 2, 'February', 'Q1', 2024, false),
(20240208, '2024-02-08', 'Thursday', 8, 2, 'February', 'Q1', 2024, false),
(20240209, '2024-02-09', 'Friday', 9, 2, 'February', 'Q1', 2024, false),
(20240210, '2024-02-10', 'Saturday', 10, 2, 'February', 'Q1', 2024, true),
(20240211, '2024-02-11', 'Sunday', 11, 2, 'February', 'Q1', 2024, true),
(20240212, '2024-02-12', 'Monday', 12, 2, 'February', 'Q1', 2024, false),
(20240213, '2024-02-13', 'Tuesday', 13, 2, 'February', 'Q1', 2024, false),
(20240214, '2024-02-14', 'Wednesday', 14, 2, 'February', 'Q1', 2024, false),
(20240215, '2024-02-15', 'Thursday', 15, 2, 'February', 'Q1', 2024, false),
(20240216, '2024-02-16', 'Friday', 16, 2, 'February', 'Q1', 2024, false),
(20240217, '2024-02-17', 'Saturday', 17, 2, 'February', 'Q1', 2024, true),
(20240218, '2024-02-18', 'Sunday', 18, 2, 'February', 'Q1', 2024, true),
(20240219, '2024-02-19', 'Monday', 19, 2, 'February', 'Q1', 2024, false),
(20240220, '2024-02-20', 'Tuesday', 20, 2, 'February', 'Q1', 2024, false),
(20240221, '2024-02-21', 'Wednesday', 21, 2, 'February', 'Q1', 2024, false),
(20240222, '2024-02-22', 'Thursday', 22, 2, 'February', 'Q1', 2024, false),
(20240223, '2024-02-23', 'Friday', 23, 2, 'February', 'Q1', 2024, false),
(20240224, '2024-02-24', 'Saturday', 24, 2, 'February', 'Q1', 2024, true),
(20240225, '2024-02-25', 'Sunday', 25, 2, 'February', 'Q1', 2024, true),
(20240226, '2024-02-26', 'Monday', 26, 2, 'February', 'Q1', 2024, false),
(20240227, '2024-02-27', 'Tuesday', 27, 2, 'February', 'Q1', 2024, false),
(20240228, '2024-02-28', 'Wednesday', 28, 2, 'February', 'Q1', 2024, false),
(20240229, '2024-02-29', 'Thursday', 29, 2, 'February', 'Q1', 2024, false);

-- ============================================================
-- Insert Product Dimension Data (15 products across 3 categories)
-- ============================================================
INSERT INTO dim_product (product_id, product_name, category, subcategory, unit_price) VALUES
('P001', 'Laptop Pro', 'Electronics', 'Laptops', 55000.00),
('P002', 'Smartphone', 'Electronics', 'Mobile Phones', 35000.00),
('P003', 'Headphones', 'Electronics', 'Audio', 5000.00),
('P004', 'Office Chair', 'Furniture', 'Seating', 8000.00),
('P005', 'Table', 'Furniture', 'Tables', 12000.00),
('P006', 'Pen', 'Stationery', 'Writing', 50.00),
('P007', 'Notebook', 'Stationery', 'Paper Products', 200.00),
('P008', 'Water Bottle', 'Kitchen Appliances', 'Storage', 250.00),
('P009', 'Coffee Maker', 'Kitchen Appliances', 'Beverage', 4500.00),
('P010', 'Microwave Oven', 'Kitchen Appliances', 'Cooking', 8000.00),
('P011', 'Sofa', 'Furniture', 'Seating', 30000.00),
('P012', 'Bed', 'Furniture', 'Bedroom', 45000.00),
('P013', 'Refrigerator', 'Electronics', 'Appliances', 55000.00),
('P014', 'Blender', 'Kitchen Appliances', 'Cooking', 3000.00),
('P015', 'Printer', 'Electronics', 'Office Equipment', 15000.00);

-- ============================================================
-- Insert Customer Dimension Data (12 customers across 4 cities)
-- ============================================================
INSERT INTO dim_customer (customer_id, customer_name, city, state, customer_segment) VALUES
('C001', 'Rahul Sharma', 'Bangalore', 'Karnataka', 'High Value'),
('C002', 'Priya Patel', 'Mumbai', 'Maharashtra', 'Medium Value'),
('C003', 'Amit Kumar', 'Delhi', 'Delhi', 'Low Value'),
('C004', 'Sneha Reddy', 'Hyderabad', 'Telangana', 'High Value'),
('C005', 'Vikram Singh', 'Chennai', 'Tamil Nadu', 'Medium Value'),
('C006', 'Anjali Mehta', 'Bangalore', 'Karnataka', 'High Value'),
('C007', 'Ravi Verma', 'Pune', 'Maharashtra', 'Low Value'),
('C008', 'Pooja Iyer', 'Bangalore', 'Karnataka', 'Medium Value'),
('C009', 'Karthik Nair', 'Kochi', 'Kerala', 'High Value'),
('C010', 'Deepa Gupta', 'Delhi', 'Delhi', 'Medium Value'),
('C011', 'Arjun Rao', 'Hyderabad', 'Telangana', 'Low Value'),
('C012', 'Lakshmi Krishnan', 'Chennai', 'Tamil Nadu', 'High Value');

-- ============================================================
-- Insert Fact Sales Data (40 sales transactions)
-- ============================================================
-- Note: Higher sales on weekends (Saturdays and Sundays)
INSERT INTO fact_sales (date_key, product_key, customer_key, quantity_sold, unit_price, discount_amount, total_amount) VALUES
-- January 2024 Sales (Weekdays and Weekends)
(20240101, 1, 1, 1, 55000.00, 0.00, 55000.00),
(20240106, 2, 2, 2, 35000.00, 1000.00, 69000.00),  -- Weekend
(20240107, 3, 3, 1, 5000.00, 0.00, 5000.00),  -- Weekend
(20240108, 4, 4, 1, 8000.00, 0.00, 8000.00),
(20240113, 5, 5, 1, 12000.00, 500.00, 11500.00),  -- Weekend
(20240114, 6, 6, 10, 50.00, 0.00, 500.00),  -- Weekend
(20240115, 7, 7, 5, 200.00, 0.00, 1000.00),
(20240120, 8, 8, 3, 250.00, 0.00, 750.00),  -- Weekend
(20240121, 9, 9, 1, 4500.00, 200.00, 4300.00),  -- Weekend
(20240122, 10, 10, 1, 8000.00, 0.00, 8000.00),
(20240127, 11, 11, 1, 30000.00, 1500.00, 28500.00),  -- Weekend
(20240128, 12, 12, 1, 45000.00, 2000.00, 43000.00),  -- Weekend
(20240129, 13, 1, 1, 55000.00, 0.00, 55000.00),
(20240130, 14, 2, 2, 3000.00, 0.00, 6000.00),
-- February 2024 Sales
(20240203, 15, 3, 1, 15000.00, 500.00, 14500.00),  -- Weekend
(20240204, 1, 4, 1, 55000.00, 2500.00, 52500.00),  -- Weekend
(20240205, 2, 5, 1, 35000.00, 0.00, 35000.00),
(20240210, 3, 6, 2, 5000.00, 200.00, 9800.00),  -- Weekend
(20240211, 4, 7, 1, 8000.00, 0.00, 8000.00),  -- Weekend
(20240212, 5, 8, 1, 12000.00, 0.00, 12000.00),
(20240217, 6, 9, 20, 50.00, 0.00, 1000.00),  -- Weekend
(20240218, 7, 10, 8, 200.00, 0.00, 1600.00),  -- Weekend
(20240219, 8, 11, 5, 250.00, 0.00, 1250.00),
(20240224, 9, 12, 1, 4500.00, 0.00, 4500.00),  -- Weekend
(20240225, 10, 1, 1, 8000.00, 300.00, 7700.00),  -- Weekend
(20240226, 11, 2, 1, 30000.00, 0.00, 30000.00),
(20240227, 12, 3, 1, 45000.00, 1500.00, 43500.00),
(20240228, 13, 4, 1, 55000.00, 0.00, 55000.00),
(20240229, 14, 5, 3, 3000.00, 100.00, 8900.00),
-- Additional sales for realistic patterns
(20240102, 15, 6, 1, 15000.00, 0.00, 15000.00),
(20240109, 1, 7, 1, 55000.00, 2000.00, 53000.00),
(20240116, 2, 8, 1, 35000.00, 0.00, 35000.00),
(20240123, 3, 9, 1, 5000.00, 0.00, 5000.00),
(20240124, 4, 10, 2, 8000.00, 400.00, 15600.00),
(20240131, 5, 11, 1, 12000.00, 0.00, 12000.00),
(20240206, 6, 12, 15, 50.00, 0.00, 750.00),
(20240207, 7, 1, 6, 200.00, 0.00, 1200.00),
(20240213, 8, 2, 4, 250.00, 0.00, 1000.00),
(20240214, 9, 3, 1, 4500.00, 0.00, 4500.00),
(20240220, 10, 4, 1, 8000.00, 0.00, 8000.00),
(20240221, 11, 5, 1, 30000.00, 1000.00, 29000.00);

