-- ***********************************************************************************
-- Section 3: SQL Analysis Queries
-- ***********************************************************************************

USE retail_analysis;

-- Step 0: Calculate and Update Derived Columns
-- These operations are crucial as 'total_amount' and 'profit' were not directly loaded.
-- Run these BEFORE any analysis queries that depend on these calculated values.

-- 0.1. Update 'total_amount' in the 'orders' table
-- This calculates the sum of (quantity * unit_price) for each order from order_details
-- and updates the corresponding 'total_amount' in the 'orders' table.
UPDATE orders o
JOIN (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS calculated_total_amount
    FROM
        order_details
    GROUP BY
        order_id
) AS od_sums ON o.order_id = od_sums.order_id
SET o.total_amount = od_sums.calculated_total_amount
WHERE o.total_amount IS NULL OR o.total_amount = 0; -- Only update if not already set

-- 0.2. Calculate 'profit' for each line item in 'order_details'
-- Profit = (unit_price - cost_price) * quantity
UPDATE order_details
SET profit = (unit_price - cost_price) * quantity
WHERE profit IS NULL OR profit = 0; -- Only update if profit is not set or zero


-- A. Regions/Products with declining performance

-- A.1. Top 10 Products by Total Profit
SELECT
    p.product_name,
    p.category,
    SUM(od.profit) AS total_profit
FROM
    order_details od
JOIN
    products p ON od.product_id = p.product_id
GROUP BY
    p.product_name, p.category
ORDER BY
    total_profit DESC
LIMIT 10;

-- A.2. Products with Lowest Average Profit Margin (per unit sold)
-- Note: Using (unit_price - cost_price) from order_details for margin calculation
SELECT
    p.product_name,
    p.category,
    AVG(od.unit_price - od.cost_price) AS average_profit_per_unit
FROM
    order_details od
JOIN
    products p ON od.product_id = p.product_id
GROUP BY
    p.product_name, p.category
ORDER BY
    average_profit_per_unit ASC
LIMIT 10;

-- A.3. Stores with Lowest Total Profit
SELECT
    s.store_name,
    s.location,
    SUM(od.profit) AS total_profit
FROM
    order_details od
JOIN
    orders o ON od.order_id = o.order_id
JOIN
    stores s ON o.store_id = s.store_id
GROUP BY
    s.store_name, s.location
ORDER BY
    total_profit ASC
LIMIT 10;

-- A.4. Profit by Product Category and Location
SELECT
    p.category,
    s.location,
    SUM(od.profit) AS total_profit
FROM
    order_details od
JOIN
    products p ON od.product_id = p.product_id
JOIN
    orders o ON od.order_id = o.order_id
JOIN
    stores s ON o.store_id = s.store_id
GROUP BY
    p.category, s.location
ORDER BY
    s.location, total_profit DESC;


-- B. Profitability trends over time

-- B.1. Monthly Total Revenue and Profit Trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(o.total_amount) AS monthly_revenue,
    SUM(od.profit) AS monthly_profit
FROM
    orders o
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY
    order_month
ORDER BY
    order_month;

-- B.2. Quarterly Total Profit and Number of Orders
SELECT
    DATE_FORMAT(o.order_date, '%Y-Q%q') AS order_quarter,
    SUM(od.profit) AS quarterly_profit,
    COUNT(DISTINCT o.order_id) AS quarterly_orders_count
FROM
    orders o
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY
    order_quarter
ORDER BY
    order_quarter;

-- B.3. Average Order Value (AOV) Trend Over Time (Monthly)
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    AVG(total_amount) AS average_order_value
FROM
    orders
GROUP BY
    order_month
ORDER BY
    order_month;


-- C. Customer behavior anomalies

-- C.1. Top 10 Customers by Total Spending
SELECT
    c.customer_name,
    -- Removed email as it's not in the 'customers' table based on the schema
    SUM(o.total_amount) AS total_spending
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_name -- Removed email
ORDER BY
    total_spending DESC
LIMIT 10;

-- C.2. Customers with High Purchase Frequency (e.g., > 5 orders)
SELECT
    c.customer_name,
    -- Removed email as it's not in the 'customers' table based on the schema
    COUNT(o.order_id) AS total_orders,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_name -- Removed email
HAVING
    total_orders > 5
ORDER BY
    total_orders DESC
LIMIT 10;

-- C.3. Products frequently purchased together (e.g., in the same order) - Requires more complex self-join, example for 2 products
-- This query identifies pairs of products that appear together in orders.
SELECT
    p1.product_name AS product1,
    p2.product_name AS product2,
    COUNT(DISTINCT od1.order_id) AS common_orders_count
FROM
    order_details od1
JOIN
    order_details od2 ON od1.order_id = od2.order_id AND od1.product_id < od2.product_id
JOIN
    products p1 ON od1.product_id = p1.product_id
JOIN
    products p2 ON od2.product_id = p2.product_id
GROUP BY
    p1.product_name, p2.product_name
ORDER BY
    common_orders_count DESC
LIMIT 10;


-- D. Sales staff or store-level performance

-- D.1. Total Revenue and Profit by Store
SELECT
    s.store_name,
    s.location,
    SUM(o.total_amount) AS total_revenue,
    SUM(od.profit) AS total_profit
FROM
    stores s
JOIN
    orders o ON s.store_id = o.store_id
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY
    s.store_name, s.location
ORDER BY
    total_profit DESC;

-- D.2. Average Order Value by Store
SELECT
    s.store_name,
    s.location,
    AVG(o.total_amount) AS average_order_value
FROM
    stores s
JOIN
    orders o ON s.store_id = o.store_id
GROUP BY
    s.store_name, s.location
ORDER BY
    average_order_value DESC;

-- D.3. Manager Performance (Total Profit under their management)
SELECT
    s.manager,
    SUM(od.profit) AS total_profit_managed
FROM
    stores s
JOIN
    orders o ON s.store_id = o.store_id
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY
    s.manager
ORDER BY
    total_profit_managed DESC;

-- D.4. Store Performance by Product Category Profit
SELECT
    s.store_name,
    p.category,
    SUM(od.profit) AS category_profit
FROM
    stores s
JOIN
    orders o ON s.store_id = o.store_id
JOIN
    order_details od ON o.order_id = od.order_id
JOIN
    products p ON od.product_id = p.product_id
GROUP BY
    s.store_name, p.category
ORDER BY
    s.store_name, category_profit DESC;


-- E. Additional Insights (Bonus Challenge / Deeper Dive)

-- E.1. Profitability Trend by Product Category (Monthly)
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    p.category,
    SUM(od.profit) AS monthly_profit
FROM
    orders o
JOIN
    order_details od ON o.order_id = od.order_id
JOIN
    products p ON od.product_id = p.product_id
GROUP BY
    order_month, p.category
ORDER BY
    order_month, p.category;

-- E.2. Customer Loyalty by Location (e.g., average orders per customer per city)
-- Changed c.city to c.region as per the customer table schema
SELECT
    c.region,
    COUNT(DISTINCT o.customer_id) AS distinct_customers,
    COUNT(o.order_id) AS total_orders,
    COUNT(o.order_id) / COUNT(DISTINCT o.customer_id) AS avg_orders_per_customer
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.region
ORDER BY
    avg_orders_per_customer DESC;

-- E.3. Products with High Sales Volume but Low Profit (potential pricing issue)
SELECT
    p.product_name,
    p.category,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.profit) AS total_profit,
    -- Calculate profit_margin_percentage based on unit_price * quantity
    (SUM(od.profit) / SUM(od.unit_price * od.quantity)) * 100 AS profit_margin_percentage
FROM
    order_details od
JOIN
    products p ON od.product_id = p.product_id
GROUP BY
    p.product_name, p.category
HAVING
    SUM(od.quantity) > 100 -- Example threshold for high sales volume
ORDER BY
    profit_margin_percentage ASC
LIMIT 10;

-- E.4. Stores with High Revenue but Low Profit Margin
SELECT
    s.store_name,
    s.location,
    SUM(o.total_amount) AS total_revenue,
    SUM(od.profit) AS total_profit,
    -- Calculate profit_margin_percentage based on total_amount from orders and profit from order_details
    (SUM(od.profit) / SUM(o.total_amount)) * 100 AS profit_margin_percentage
FROM
    stores s
JOIN
    orders o ON s.store_id = o.store_id
JOIN
    order_details od ON o.order_id = od.order_id
GROUP BY
    s.store_name, s.location
ORDER BY
    profit_margin_percentage ASC
LIMIT 10;
