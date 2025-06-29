-- ***********************************************************************************
-- Section 1: Database and Table Schemas (REVISED for `products` and `order_details` tables)
-- ***********************************************************************************

-- Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS retail_analysis;

-- Use the newly created or existing database
USE retail_analysis;

-- Drop tables in reverse order of dependency to avoid foreign key constraints errors
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products; -- This table's schema will be updated
DROP TABLE IF EXISTS stores;

-- 1. Create 'stores' table
CREATE TABLE stores (
    store_id VARCHAR(50) PRIMARY KEY,
    store_name VARCHAR(255),
    location VARCHAR(100),
    manager VARCHAR(100)
);

-- 2. Create 'products' table (UPDATED - removed 'cost' column)
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2) -- General retail price
);

-- 3. Create 'customers' table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(255),
    region VARCHAR(100),
    join_date DATETIME
);

-- 4. Create 'orders' table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    store_id VARCHAR(50),
    order_date DATETIME,
    total_amount DECIMAL(15, 2), -- Will be derived from order_details
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- 5. Create 'order_details' table (UPDATED - added 'cost_price' column)
-- Modified order_detail_id to be INT and AUTO_INCREMENT
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT, -- Changed to INT AUTO_INCREMENT
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2), -- Cost of this specific unit for this order
    profit DECIMAL(10, 2),      -- Will be calculated from unit_price and cost_price
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ***********************************************************************************
-- Section 2: Data Loading
-- ***********************************************************************************

-- Ensure you are using the correct database
USE retail_analysis;

-- Temporarily disable foreign key checks to allow truncation of parent tables
SET FOREIGN_KEY_CHECKS = 0;

-- Clear existing data before loading to prevent duplicate entry errors
-- Truncate tables in reverse order of dependency (or simply clear all while checks are off)
TRUNCATE TABLE order_details;
TRUNCATE TABLE orders;
TRUNCATE TABLE customers;
TRUNCATE TABLE products;
TRUNCATE TABLE stores;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Load data into 'stores' table
-- IMPORTANT: Make sure your 'stores.csv' file is located at the specified path
-- Removed ENCLOSED BY '"'
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
-- ENCLOSED BY '"' -- Removed this line
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load data into 'products' table
-- IMPORTANT: Make sure your 'products.csv' file is located at the specified path
-- Removed ENCLOSED BY '"'
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
-- ENCLOSED BY '"' -- Removed this line
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load data into 'customers' table
-- IMPORTANT: Make sure your 'customer.csv' file is located at the specified path
-- Removed ENCLOSED BY '"'
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customer.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
-- ENCLOSED BY '"' -- Removed this line
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load data into 'orders' table
-- IMPORTANT: Make sure your 'orders.csv' file is located at the specified path
-- Removed ENCLOSED BY '"'
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
-- ENCLOSED BY '"' -- Removed this line
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, customer_id, store_id, order_date);

-- Load data into 'order_details' table
-- IMPORTANT: After saving 'order_details.csv' as a standard CSV (comma-delimited) in Excel/Sheets,
-- Make sure the file is located at the specified path.
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' -- Changed from '\t' to ',' to match standard CSV
ENCLOSED BY '"' -- Added back ENCLOSED BY for standard CSV format
LINES TERMINATED BY '\r\n' -- Changed to '\r\n' for standard Windows CSV
IGNORE 1 ROWS
(order_id, product_id, quantity, unit_price, cost_price); -- Removed profit, as it will be calculated
