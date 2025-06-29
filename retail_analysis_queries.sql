-- ***********************************************************************************
-- Section 3: Data Preparation and Derived Column Calculations
--
-- This section calculates and populates the 'total_amount' in the 'orders' table
-- and the 'profit' in the 'order_details' table, as these were not directly
-- loaded from the CSV files. These steps are crucial before running analysis queries.
-- ***********************************************************************************

-- 3.1. Update 'total_amount' in the 'orders' table
-- Calculates the sum of (quantity * unit_price) for each order from 'order_details'
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
WHERE o.total_amount IS NULL OR o.total_amount = 0; -- Only update if the field is not already populated

-- 3.2. Calculate 'profit' for each line item in 'order_details'
-- Profit is calculated as (unit_price - cost_price) * quantity for each order detail.
UPDATE order_details
SET profit = (unit_price - cost_price) * quantity
WHERE profit IS NULL OR profit = 0; -- Only update if the field is not already populated


-- ***********************************************************************************
-- Section 4: SQL Analysis Queries
--
-- This section contains the core analytical queries to investigate profit leaks
-- across different dimensions as per the assignment requirements.
-- ***********************************************************************************

-- A. Regions/Products with declining performance

-- A.1. Top 10 Products by Total Profit
-- Identifies the products that have generated the most overall profit.
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
-- Highlights products that, despite sales, yield low profit per unit.
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
-- Pinpoints store locations that are contributing least to overall profit.
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
-- Provides a granular view of category performance within different geographical locations.
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
-- Shows the monthly progression of overall revenue and profit.
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
-- Provides a quarterly overview of profit and order volume.
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
-- Tracks changes in the average value of each order over months.
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
-- Identifies the most valuable customers based on their total expenditure.
SELECT
    c.customer_name,
    SUM(o.total_amount) AS total_spending
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_name
ORDER BY
    total_spending DESC
LIMIT 10;

-- C.2. Customers with High Purchase Frequency (e.g., > 5 orders)
-- Identifies loyal customers who frequently place orders.
SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM
    customers c
JOIN
    orders o ON c.customer_id = o.customer_id
GROUP BY
    c.customer_name
HAVING
    total_orders > 5 -- Threshold for high frequency
ORDER BY
    total_orders DESC
LIMIT 10;

-- C.3. Products frequently purchased together (e.g., in the same order)
-- Identifies product pairings that often occur in the same order, useful for bundling.
SELECT
    p1.product_name AS product1,
    p2.product_name AS product2,
    COUNT(DISTINCT od1.order_id) AS common_orders_count
FROM
    order_details od1
JOIN
    order_details od2 ON od1.order_id = od2.order_id AND od1.product_id < od2.product_id -- Avoids duplicate pairs (A,B and B,A) and self-joins
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
-- Provides an overview of the financial contribution of each store.
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
-- Shows the average transaction size at each store.
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
-- Assesses the profitability associated with each store manager.
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
-- Breaks down store profitability by the product categories sold within them.
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
-- Provides a time-series analysis of profit for each product category.
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

-- E.2. Customer Loyalty by Region (Average Orders per Customer)
-- Measures customer engagement and loyalty across different regions.
SELECT
    c.region, -- Using 'region' as per the schema (instead of a non-existent 'city' column)
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
-- Identifies products that sell well but yield low profit margins, indicating potential pricing or cost issues.
SELECT
    p.product_name,
    p.category,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.profit) AS total_profit,
    (SUM(od.profit) / SUM(od.unit_price * od.quantity)) * 100 AS profit_margin_percentage
FROM
    order_details od
JOIN
    products p ON od.product_id = p.product_id
GROUP BY
    p.product_name, p.category
HAVING
    SUM(od.quantity) > 50 -- Adjusted threshold for high sales volume based on previous interaction
ORDER BY
    profit_margin_percentage ASC
LIMIT 10;

-- E.4. Stores with High Revenue but Low Profit Margin
-- Pinpoints stores that generate significant revenue but struggle with profitability.
SELECT
    s.store_name,
    s.location,
    SUM(o.total_amount) AS total_revenue,
    SUM(od.profit) AS total_profit,
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