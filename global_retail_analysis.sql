-- ***********************************************************************************
-- SQL CHALLENGE PROJECT 4: Retail Profit Leak Analysis
--
-- This script contains the complete SQL code for setting up the 'retail_analysis'
-- database, loading data from CSV files, performing necessary data transformations,
-- and executing analytical queries to identify potential profit leaks within a
-- global retail company.
--
-- Submitted by: Dan Alwende
-- Date: June 29, 2025
-- ***********************************************************************************


-- ***********************************************************************************
-- Section 1: Database and Table Schema Creation
--
-- This section defines the 'retail_analysis' database and creates all necessary
-- tables: stores, products, customers, orders, and order_details.
-- Foreign key constraints are established to ensure data integrity.
-- ***********************************************************************************

-- Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS retail_analysis;

-- Use the newly created or existing database
USE retail_analysis;

-- Drop tables in reverse order of dependency to avoid foreign key constraint errors
-- This ensures a clean slate if the script is run multiple times for testing.
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS stores;

-- 1. Create 'stores' table
-- Stores information about individual retail locations.
CREATE TABLE stores (
    store_id VARCHAR(50) PRIMARY KEY,
    store_name VARCHAR(255),
    location VARCHAR(100),
    manager VARCHAR(100)
);

-- 2. Create 'products' table
-- Stores information about products sold, including general price and category.
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(100),
    price DECIMAL(10, 2) -- General retail price
);

-- 3. Create 'customers' table
-- Stores customer details, including their region and join date.
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_name VARCHAR(255),
    region VARCHAR(100),
    join_date DATETIME
);

-- 4. Create 'orders' table
-- Records overall order information, linking to customers and stores.
-- 'total_amount' will be derived/calculated from 'order_details'.
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    store_id VARCHAR(50),
    order_date DATETIME,
    total_amount DECIMAL(15, 2), -- Will be derived from order_details
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- 5. Create 'order_details' table
-- Contains detailed information for each item within an order.
-- 'order_detail_id' is auto-incremented as it's not present in the source CSV.
-- 'profit' will be derived/calculated from 'unit_price' and 'cost_price'.
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT, -- Automatically generated unique ID for each detail line
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2), -- Cost of this specific unit for this order
    profit DECIMAL(10, 2),      -- Will be calculated as (unit_price - cost_price) * quantity
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
