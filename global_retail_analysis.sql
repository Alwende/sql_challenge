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
CREATE TABLE order_details (
    order_detail_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2), -- Cost of this specific unit for this order
    profit DECIMAL(10, 2),     -- Will be calculated from unit_price and cost_price
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);