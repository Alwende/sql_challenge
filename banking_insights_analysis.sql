-- ***********************************************************************************
-- Section 3: Data Exploration & Insight Generation Queries
-- (Run AFTER all tables are populated and conversions in Section 2 are complete)
-- ***********************************************************************************

USE banking_insights;

-- A. Basic Data Overview (from all tables)

-- 1. Total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- 2. Total number of accounts
SELECT COUNT(*) AS total_accounts
FROM accounts;

-- 3. Total number of transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- 4. Distribution of customers by gender
SELECT gender, COUNT(*) AS customer_count
FROM customers
GROUP BY gender
ORDER BY customer_count DESC;

-- 5. Distribution of customers by location
SELECT location, COUNT(*) AS customer_count
FROM customers
GROUP BY location
ORDER BY customer_count DESC;

-- 6. Age distribution of customers
SELECT
    CASE
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS customer_count
FROM customers
GROUP BY age_group
ORDER BY age_group;

-- 7. Distribution of account types
SELECT account_type, COUNT(*) AS number_of_accounts
FROM accounts
GROUP BY account_type
ORDER BY number_of_accounts DESC;

-- 8. Average balance across all accounts
SELECT AVG(balance) AS average_balance
FROM accounts;

-- 9. Number of active vs. inactive accounts
SELECT is_active, COUNT(*) AS count
FROM accounts
GROUP BY is_active;

-- 10. Distribution of transaction types
SELECT transaction_type, COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;

-- 11. Total transaction amount
SELECT SUM(amount) AS total_transaction_amount
FROM transactions;


-- B. Customer-Account Insights (Joining Customers and Accounts)

-- 1. Total balance per customer (sum of all their accounts)
SELECT
    c.customer_id,
    c.name,
    SUM(a.balance) AS total_balance
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id, c.name
ORDER BY
    total_balance DESC;

-- 2. Number of accounts per customer
SELECT
    c.customer_id,
    c.name,
    COUNT(a.account_id) AS number_of_accounts
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id, c.name
ORDER BY
    number_of_accounts DESC;

-- 3. Customers with multiple account types
SELECT
    c.customer_id,
    c.name,
    COUNT(DISTINCT a.account_type) AS distinct_account_types
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id, c.name
HAVING
    distinct_account_types > 1
ORDER BY
    distinct_account_types DESC;

-- 4. Customers with only inactive accounts (potential churn risk, assuming all accounts for them are inactive)
SELECT
    c.customer_id,
    c.name
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
GROUP BY
    c.customer_id, c.name
HAVING
    SUM(CASE WHEN a.is_active = TRUE THEN 1 ELSE 0 END) = 0;

-- 5. Average balance per customer location
SELECT
    c.location,
    AVG(a.balance) AS average_balance_per_location
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
GROUP BY
    c.location
ORDER BY
    average_balance_per_location DESC;


-- C. Transactional Insights (Joining Accounts and Transactions)

-- 1. Total deposits, withdrawals, and payments per account
SELECT
    a.account_id,
    SUM(CASE WHEN t.transaction_type = 'deposit' THEN t.amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN t.transaction_type = 'withdrawal' THEN t.amount ELSE 0 END) AS total_withdrawals,
    SUM(CASE WHEN t.transaction_type = 'payment' THEN t.amount ELSE 0 END) AS total_payments,
    SUM(CASE WHEN t.transaction_type = 'transfer' THEN t.amount ELSE 0 END) AS total_transfers
FROM
    accounts a
JOIN
    transactions t ON a.account_id = t.account_id
GROUP BY
    a.account_id
ORDER BY
    a.account_id;

-- 2. Monthly transaction volume (count and amount)
SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
    COUNT(*) AS total_transactions_count,
    SUM(amount) AS total_transaction_amount
FROM
    transactions
GROUP BY
    transaction_month
ORDER BY
    transaction_month;

-- 3. Average transaction amount per transaction type
SELECT
    transaction_type,
    AVG(amount) AS average_transaction_amount
FROM
    transactions
GROUP BY
    transaction_type
ORDER BY
    average_transaction_amount DESC;

-- 4. Accounts with highest transaction count
SELECT
    account_id,
    COUNT(transaction_id) AS transaction_count
FROM
    transactions
GROUP BY
    account_id
ORDER BY
    transaction_count DESC
LIMIT 10;

-- 5. Accounts with highest total transaction amount (excluding transfers as they might be internal)
SELECT
    account_id,
    SUM(amount) AS total_transaction_value
FROM
    transactions
WHERE
    transaction_type IN ('deposit', 'withdrawal', 'payment')
GROUP BY
    account_id
ORDER BY
    total_transaction_value DESC
LIMIT 10;


-- D. Cross-Table Insights (Joining Customers, Accounts, and Transactions)

-- 1. Customer transaction behavior by age group (e.g., average transaction amount)
SELECT
    CASE
        WHEN c.age BETWEEN 18 AND 24 THEN '18-24'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    t.transaction_type,
    AVG(t.amount) AS avg_transaction_amount,
    COUNT(t.transaction_id) AS transaction_count
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
JOIN
    transactions t ON a.account_id = t.account_id
GROUP BY
    age_group, t.transaction_type
ORDER BY
    age_group, t.transaction_type;

-- 2. Top locations by total transaction volume
SELECT
    c.location,
    SUM(t.amount) AS total_transaction_amount,
    COUNT(t.transaction_id) AS total_transaction_count
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
JOIN
    transactions t ON a.account_id = t.account_id
GROUP BY
    c.location
ORDER BY
    total_transaction_amount DESC
LIMIT 5;

-- 3. Account types most involved in 'transfer' transactions
SELECT
    a.account_type,
    COUNT(t.transaction_id) AS transfer_transaction_count,
    SUM(t.amount) AS total_transfer_amount
FROM
    accounts a
JOIN
    transactions t ON a.account_id = t.account_id
WHERE
    t.transaction_type = 'transfer'
GROUP BY
    a.account_type
ORDER BY
    transfer_transaction_count DESC;

-- 4. Customers who joined recently with high transaction activity (e.g., joined in 2022, >10 transactions)
SELECT
    c.customer_id,
    c.name,
    c.date_joined,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_transacted_amount
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
JOIN
    transactions t ON a.account_id = t.account_id
WHERE
    YEAR(c.date_joined) = 2022
GROUP BY
    c.customer_id, c.name, c.date_joined
HAVING
    COUNT(t.transaction_id) > 10
ORDER BY
    total_transacted_amount DESC;

-- 5. Identifying potential 'power users' (high balance + high transaction volume)
SELECT
    c.customer_id,
    c.name,
    SUM(a.balance) AS total_customer_balance,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_transaction_value
FROM
    customers c
JOIN
    accounts a ON c.customer_id = a.customer_id
JOIN
    transactions t ON a.account_id = t.account_id
GROUP BY
    c.customer_id, c.name
ORDER BY
    total_customer_balance DESC, total_transactions DESC
LIMIT 10;