-- ***********************************************************************************
-- Project Name: Banking on Insights
-- SQL Code for Submission
-- Date: June 17, 2025
--
-- This script performs the following actions:
-- 1. Creates the 'banking_insights' database and three tables: 'customers', 'accounts', 'transactions'.
-- 2. Includes post-import data conversion for the 'is_active' column in 'accounts'.
-- 3. Provides a comprehensive set of SQL queries for data exploration and insight generation.
--
-- IMPORTANT:
-- Data for 'customers', 'accounts', and 'transactions' tables must be imported manually
-- using MySQL Workbench's Table Data Import Wizard AFTER running Section 1.
-- The order of import is crucial due to foreign key relationships:
-- 1. customers-_data.csv into 'customers' table
-- 2. accounts_data.csv into 'accounts' table
-- 3. transactions_data.csv into 'transactions' table
-- ***********************************************************************************

-- ***********************************************************************************
-- Section 1: Database and Table Schemas
-- ***********************************************************************************

-- Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS banking_insights;

-- Use the newly created or existing database
USE banking_insights;

-- Drop tables if they exist to ensure a clean start for recreation
-- Drop in order due to foreign key dependencies (transactions -> accounts -> customers)
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;

-- 1. Create 'customers' table from customers-_data.csv
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255),
    gender VARCHAR(10),
    age INT,
    location VARCHAR(100),
    date_joined DATETIME
);

-- 2. Create 'accounts' table from accounts_data.csv
-- 'is_active' is VARCHAR initially for flexible import, converted to BOOLEAN in Section 2.
CREATE TABLE accounts (
    account_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    account_type VARCHAR(50),
    balance DECIMAL(15, 2),
    is_active VARCHAR(10),
    -- Foreign key constraint to link accounts to customers
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 3. Create 'transactions' table from transactions_data.csv
CREATE TABLE transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50),
    transaction_type VARCHAR(50),
    amount DECIMAL(15, 2),
    transaction_date DATETIME,
    -- Foreign key constraint to link transactions to accounts
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);