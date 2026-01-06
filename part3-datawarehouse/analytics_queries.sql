USE fleximart_dw;

-- Query 1: Monthly Sales Drill-Down
-- Sales by year, quarter, month for 2024

SELECT 
    dd.year,
    dd.quarter,
    dd.month_name,
    COUNT(DISTINCT fs.sale_key) AS total_orders,
    SUM(fs.quantity_sold) AS total_quantity,
    SUM(fs.total_amount) AS total_sales
FROM 
    fact_sales fs
    INNER JOIN dim_date dd ON fs.date_key = dd.date_key
WHERE 
    dd.year = 2024
GROUP BY 
    dd.year, dd.quarter, dd.month, dd.month_name
ORDER BY 
    dd.year, dd.quarter, dd.month;

-- Query 2: Product Performance Analysis
-- Top 10 products by revenue

SELECT 
    dp.product_name,
    dp.category,
    SUM(fs.quantity_sold) AS units_sold,
    SUM(fs.total_amount) AS revenue,
    ROUND(
        (SUM(fs.total_amount) / (SELECT SUM(total_amount) FROM fact_sales)) * 100, 
        2
    ) AS revenue_percentage
FROM 
    fact_sales fs
    INNER JOIN dim_product dp ON fs.product_key = dp.product_key
GROUP BY 
    dp.product_key, dp.product_name, dp.category
ORDER BY 
    revenue DESC
LIMIT 10;

-- Query 3: Customer Segmentation
-- High/Medium/Low value customers

WITH customer_totals AS (
    SELECT 
        dc.customer_key,
        dc.customer_name,
        SUM(fs.total_amount) AS total_spent
    FROM 
        fact_sales fs
        INNER JOIN dim_customer dc ON fs.customer_key = dc.customer_key
    GROUP BY 
        dc.customer_key, dc.customer_name
),
customer_segments AS (
    SELECT 
        customer_key,
        customer_name,
        total_spent,
        CASE 
            WHEN total_spent > 50000 THEN 'High Value'
            WHEN total_spent >= 20000 AND total_spent <= 50000 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS customer_segment
    FROM 
        customer_totals
)
SELECT 
    cs.customer_segment,
    COUNT(DISTINCT cs.customer_key) AS customer_count,
    SUM(ct.total_spent) AS total_revenue,
    ROUND(AVG(ct.total_spent), 2) AS avg_revenue
FROM 
    customer_segments cs
    INNER JOIN customer_totals ct ON cs.customer_key = ct.customer_key
GROUP BY 
    cs.customer_segment
ORDER BY 
    CASE cs.customer_segment
        WHEN 'High Value' THEN 1
        WHEN 'Medium Value' THEN 2
        WHEN 'Low Value' THEN 3
    END;

