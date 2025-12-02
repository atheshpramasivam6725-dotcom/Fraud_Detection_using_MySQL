CREATE DATABASE fraud_detection_db;

USE fraud_detection_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    segment VARCHAR(50) -- Retail, Corporate, VIP
);

show tables;

CREATE TABLE cards (
    card_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    card_number VARCHAR(20) UNIQUE NOT NULL,
    card_type VARCHAR(20),      -- Credit / Debit
    status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

show tables;

CREATE TABLE merchants (
    merchant_id INT PRIMARY KEY AUTO_INCREMENT,
    merchant_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),       -- Electronics, Travel, etc.
    country VARCHAR(50)
);

CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    card_id INT NOT NULL,
    merchant_id INT NOT NULL,
    txn_timestamp DATETIME NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'INR',
    channel VARCHAR(20),        -- POS, Online, ATM
    status VARCHAR(20),         -- Approved, Declined
    is_fraud TINYINT(1) DEFAULT 0,  -- 0 = genuine, 1 = fraud
    remark VARCHAR(255),
    FOREIGN KEY (card_id) REFERENCES cards(card_id),
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
);

INSERT INTO customers (customer_name, country, segment) VALUES
('Arjun Kumar', 'India', 'Retail'),
('Priya Sharma', 'India', 'Retail'),
('Vikram Singh', 'India', 'VIP'),
('Sneha Rao', 'Australia', 'Corporate'),
('Rahul Menon', 'India', 'Retail');

INSERT INTO cards (customer_id, card_number, card_type, status) VALUES
(1, '4111111111111111', 'Credit', 'Active'),
(1, '5500000000000004', 'Debit',  'Active'),
(2, '4111111111111112', 'Credit', 'Active'),
(3, '4111111111111113', 'Credit', 'Active'),
(4, '5500000000000005', 'Credit', 'Active'),
(5, '5500000000000006', 'Debit',  'Active');

INSERT INTO merchants (merchant_name, category, country) VALUES
('TechWorld Electronics', 'Electronics', 'India'),
('Global Travels',        'Travel',      'UAE'),
('Daily SuperMart',       'Grocery',     'India'),
('Online Fashion Hub',    'Clothing',    'UK'),
('Coffee Corner',         'Food',        'India'),
('Luxury Watches',        'Jewellery',   'Singapore');

INSERT INTO transactions
(card_id, merchant_id, txn_timestamp, amount, currency, channel, status, is_fraud, remark)
VALUES
-- Normal
(1, 1, '2025-11-20 10:05:00',  2500.00, 'INR', 'POS',    'Approved', 0, NULL),
(1, 3, '2025-11-20 18:30:00',   800.00, 'INR', 'POS',    'Approved', 0, NULL),
(2, 3, '2025-11-21 09:15:00',   600.00, 'INR', 'POS',    'Approved', 0, NULL),
(3, 5, '2025-11-21 11:45:00',   300.00, 'INR', 'POS',    'Approved', 0, NULL),
(4, 2, '2025-11-21 14:10:00',  5000.00, 'AUD', 'Online', 'Approved', 0, NULL),

-- High amount fraud
(1, 6, '2025-11-22 02:15:00', 250000.00, 'INR', 'Online', 'Approved', 1, 'Unusual high amount'),
(3, 6, '2025-11-22 02:20:00', 450000.00, 'INR', 'Online', 'Approved', 1, 'High amount luxury purchase'),

-- Velocity fraud (many small attempts)
(2, 4, '2025-11-22 03:00:00',   999.99, 'INR', 'Online', 'Declined', 1, 'Multiple attempts'),
(2, 4, '2025-11-22 03:02:00',   999.99, 'INR', 'Online', 'Declined', 1, 'Multiple attempts'),
(2, 4, '2025-11-22 03:04:00',   999.99, 'INR', 'Online', 'Declined', 1, 'Multiple attempts'),

-- Impossible travel pattern
(5, 3, '2025-11-23 09:00:00',   700.00, 'INR', 'POS',    'Approved', 0, NULL),                    -- India
(5, 2, '2025-11-23 11:00:00', 20000.00, 'AED', 'POS',    'Approved', 1, 'Very short travel gap'), -- UAE
(5, 4, '2025-11-23 13:00:00', 15000.00, 'GBP', 'Online', 'Approved', 1, 'Unrealistic locations'),

-- Normal again
(1, 5, '2025-11-24 08:30:00',   150.00, 'INR', 'POS',    'Approved', 0, NULL),
(1, 5, '2025-11-24 08:35:00',   170.00, 'INR', 'POS',    'Approved', 0, 'Coffee + snack'),
(3, 1, '2025-11-24 21:45:00',   999.00, 'INR', 'Online', 'Approved', 0, NULL);

select * from customers;

SELECT 
    t.transaction_id,
    t.txn_timestamp,
    c.customer_name,
    cd.card_number,
    m.merchant_name,
    m.category AS merchant_category,
    m.country AS merchant_country,
    t.amount,
    t.currency,
    t.channel,
    t.status,
    t.is_fraud
FROM transactions t
JOIN cards cd      ON t.card_id = cd.card_id
JOIN customers c   ON cd.customer_id = c.customer_id
JOIN merchants m   ON t.merchant_id = m.merchant_id
ORDER BY t.txn_timestamp;

SELECT 
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS fraud_transactions,
    ROUND(100 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_percent
FROM transactions;

SELECT 
    channel,
    COUNT(*) AS total_txn,
    SUM(is_fraud) AS fraud_txn,
    ROUND(100 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_percent
FROM transactions
GROUP BY channel
ORDER BY fraud_rate_percent DESC;

SELECT 
    m.merchant_name,
    m.category,
    m.country,
    COUNT(*) AS total_txn,
    SUM(t.is_fraud) AS fraud_txn,
    ROUND(100 * SUM(t.is_fraud) / COUNT(*), 2) AS fraud_rate_percent
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_name, m.category, m.country
HAVING fraud_txn > 0
ORDER BY fraud_txn DESC, fraud_rate_percent DESC;

SELECT 
    c.customer_name,
    COUNT(*) AS total_txn,
    SUM(t.is_fraud) AS fraud_txn
FROM customers c
JOIN cards cd       ON c.customer_id = cd.customer_id
JOIN transactions t ON cd.card_id = t.card_id
GROUP BY c.customer_name
HAVING fraud_txn > 0
ORDER BY fraud_txn DESC;

SELECT 
    t.transaction_id,
    t.txn_timestamp,
    c.customer_name,
    m.merchant_name,
    t.amount,
    t.currency,
    t.is_fraud
FROM transactions t
JOIN cards cd ON t.card_id = cd.card_id
JOIN customers c ON cd.customer_id = c.customer_id
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.amount > 100000.00
ORDER BY t.amount DESC;

SELECT 
    t.transaction_id,
    t.txn_timestamp,
    c.customer_name,
    m.merchant_name,
    t.amount,
    t.currency,
    t.is_fraud
FROM transactions t
JOIN cards cd ON t.card_id = cd.card_id
JOIN customers c ON cd.customer_id = c.customer_id
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.amount > 100000.00
ORDER BY t.amount DESC;

SELECT 
    t1.transaction_id,
    t1.card_id,
    t1.merchant_id,
    t1.txn_timestamp,
    t1.amount,
    COUNT(*) AS attempts_in_10_min
FROM transactions t1
JOIN transactions t2
      ON t1.card_id = t2.card_id
     AND t1.merchant_id = t2.merchant_id
     AND t2.txn_timestamp BETWEEN DATE_SUB(t1.txn_timestamp, INTERVAL 10 MINUTE)
                              AND DATE_ADD(t1.txn_timestamp, INTERVAL 10 MINUTE)
GROUP BY t1.transaction_id, t1.card_id, t1.merchant_id, t1.txn_timestamp, t1.amount
HAVING attempts_in_10_min >= 3
ORDER BY attempts_in_10_min DESC, t1.txn_timestamp;
WITH ordered_txn AS (
    SELECT 
        t.transaction_id,
        t.card_id,
        t.txn_timestamp,
        m.country AS merchant_country,
        LAG(t.txn_timestamp) OVER (PARTITION BY t.card_id ORDER BY t.txn_timestamp) AS prev_txn_time,
        LAG(m.country)        OVER (PARTITION BY t.card_id ORDER BY t.txn_timestamp) AS prev_country
    FROM transactions t
    JOIN merchants m ON t.merchant_id = m.merchant_id
)

SELECT 
    transaction_id,
    card_id,
    prev_country,
    merchant_country,
    prev_txn_time,
    txn_timestamp,
    TIMESTAMPDIFF(HOUR, prev_txn_time, txn_timestamp) AS hours_diff
FROM ordered_txn
WHERE prev_country IS NOT NULL
  AND merchant_country <> prev_country
  AND TIMESTAMPDIFF(HOUR, prev_txn_time, txn_timestamp) <= 4   -- rule
ORDER BY txn_timestamp;

SELECT 
    DATE(txn_timestamp) AS txn_date,
    COUNT(*) AS total_txn,
    SUM(is_fraud) AS fraud_txn,
    ROUND(100 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_percent
FROM transactions
GROUP BY DATE(txn_timestamp)
ORDER BY txn_date;

SELECT 
    m.category,
    COUNT(*) AS total_txn,
    SUM(t.is_fraud) AS fraud_txn,
    ROUND(100 * SUM(t.is_fraud) / COUNT(*), 2) AS fraud_rate_percent
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.category
ORDER BY fraud_rate_percent DESC;

CREATE OR REPLACE VIEW suspicious_transactions AS
SELECT 
    t.transaction_id,
    t.txn_timestamp,
    c.customer_name,
    cd.card_number,
    m.merchant_name,
    m.country AS merchant_country,
    c.country AS customer_country,
    t.amount,
    t.status,
    t.is_fraud,
    CASE
        WHEN t.amount > 100000 THEN 'High amount'
        WHEN m.country <> c.country THEN 'Cross-border risk'
        WHEN t.status = 'Declined' THEN 'Declined transaction'
        ELSE 'Other'
    END AS risk_reason
FROM transactions t
JOIN cards cd ON t.card_id = cd.card_id
JOIN customers c ON cd.customer_id = c.customer_id
JOIN merchants m ON t.merchant_id = m.merchant_id;

SELECT * FROM suspicious_transactions
ORDER BY txn_timestamp;


