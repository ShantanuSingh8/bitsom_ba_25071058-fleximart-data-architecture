USE fleximart;

-- Query 1: Customer Purchase History
-- Customers with at least 2 orders and spent more than 5000

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.subtotal) AS total_spent
FROM 
    customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE 
    o.status = 'Completed'
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email
HAVING 
    COUNT(DISTINCT o.order_id) >= 2 
    AND SUM(oi.subtotal) > 5000
ORDER BY 
    total_spent DESC;

-- Query 2: Product Sales Analysis
-- Categories with revenue > 10000

SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS num_products,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue
FROM 
    products p
    INNER JOIN order_items oi ON p.product_id = oi.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
WHERE 
    o.status = 'Completed'
GROUP BY 
    p.category
HAVING 
    SUM(oi.subtotal) > 10000
ORDER BY 
    total_revenue DESC;

-- Query 3: Monthly Sales Trend for 2024

SELECT 
    MONTHNAME(o.order_date) AS month_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.subtotal) AS monthly_revenue,
    SUM(SUM(oi.subtotal)) OVER (
        ORDER BY MONTH(o.order_date) 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM 
    orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE 
    YEAR(o.order_date) = 2024
    AND o.status = 'Completed'
GROUP BY 
    MONTH(o.order_date), MONTHNAME(o.order_date)
ORDER BY 
    MONTH(o.order_date);

