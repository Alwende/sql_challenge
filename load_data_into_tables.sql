-- ***********************************************************************************
-- Section 2: Data Loading
--
-- This section loads data from the provided CSV files into their respective tables.
-- It includes steps to handle potential issues like duplicate entries and
-- specific CSV formatting (e.g., line endings, delimiters).
--
-- IMPORTANT: Ensure all CSV files (stores.csv, products.csv, customer.csv,
-- orders.csv, order_details.csv) are placed in the MySQL secure file directory:
-- 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/'
-- ***********************************************************************************

-- Ensure you are using the correct database
USE retail_analysis;

-- Temporarily disable foreign key checks to allow truncation of parent tables.
-- This prevents errors when clearing data from tables that are referenced by other tables.
SET FOREIGN_KEY_CHECKS = 0;

-- Clear existing data from tables before loading new data.
-- Truncate tables in reverse order of dependency to prevent foreign key issues,
-- though with FOREIGN_KEY_CHECKS = 0, the order is less critical but still good practice.
TRUNCATE TABLE order_details;
TRUNCATE TABLE orders;
TRUNCATE TABLE customers;
TRUNCATE TABLE products;
TRUNCATE TABLE stores;

-- Re-enable foreign key checks after clearing tables.
SET FOREIGN_KEY_CHECKS = 1;

-- Load data into 'stores' table from stores.csv
-- Uses comma as a field terminator and expects Windows-style line endings.
-- Ignores the first row (header).
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load data into 'products' table from products.csv
-- Uses comma as a field terminator and expects Windows-style line endings.
-- Ignores the first row (header).
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load data into 'customers' table from customer.csv
-- Uses comma as a field terminator and expects Windows-style line endings.
-- Ignores the first row (header).
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load data into 'orders' table from orders.csv
-- Uses comma as a field terminator and expects Windows-style line endings.
-- Explicitly lists columns to load, excluding 'total_amount' as it's derived.
-- Ignores the first row (header).
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, customer_id, store_id, order_date); -- Columns present in orders.csv

-- Load data into 'order_details' table from order_details.csv
-- Assumes 'order_details.csv' has been manually saved as a standard comma-delimited CSV
-- (e.g., from Excel). Uses comma as field terminator and expects Windows-style line endings.
-- Explicitly lists columns to load, excluding 'order_detail_id' (auto-incremented)
-- and 'profit' (derived).
-- Ignores the first row (header).
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"' -- Re-added for standard CSV format
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, product_id, quantity, unit_price, cost_price); -- Columns present in order_details.csv

