# Fraud_Detection_using_MySQL
Project Title: Fraud Detection using MySQL
=========================================

Overview
--------
This project implements a simple fraud detection system using MySQL. It simulates card transactions and uses SQL logic to analyze patterns such as:

- High-value transactions
- Repeated attempts (velocity fraud)
- Suspicious cross-border transactions (impossible travel)
- Risky merchants and customer behavior

The goal is to demonstrate how advanced SQL (joins, aggregations, window functions, and views) can be used for fraud analytics, suitable for a Data Analyst / Data Engineering portfolio project.

Tech Stack
----------
- Database: MySQL
- Language: SQL
- File: Fraud_Detection_using_MySQL.sql

Database Schema
---------------
The project uses four main tables:

1) customers
   - customer_id (PK)
   - customer_name
   - country
   - segment (Retail, Corporate, VIP)

2) cards
   - card_id (PK)
   - customer_id (FK -> customers.customer_id)
   - card_number
   - card_type (Credit/Debit)
   - status

3) merchants
   - merchant_id (PK)
   - merchant_name
   - category (Electronics, Travel, Clothing, etc.)
   - country

4) transactions
   - transaction_id (PK)
   - card_id (FK -> cards.card_id)
   - merchant_id (FK -> merchants.merchant_id)
   - txn_timestamp (DATETIME)
   - amount
   - currency
   - channel (POS, Online, ATM)
   - status (Approved, Declined)
   - is_fraud (0 = genuine, 1 = fraud)
   - remark

Dataset
-------
The SQL script inserts a small but meaningful sample dataset including:

- Genuine day-to-day transactions
- Very high-value suspicious transactions
- Multiple small declined attempts in a short time window
- Cross-country transactions in unrealistically short time (impossible travel pattern)

These patterns are used to illustrate how fraud can be detected using rule-based SQL logic.

How to Run the Project
----------------------
1) Open MySQL Workbench (or any MySQL client).

2) Create and use the database:
   - The script begins with:
       CREATE DATABASE fraud_detection_db;
       USE fraud_detection_db;

3) Execute the script:
   - Run the file: Fraud_Detection_using_MySQL.sql
   - This will:
       - Create all four tables
       - Insert sample data
       - Run analytical queries
       - Create a view for suspicious transactions

4) Verify tables:
   - You can run:
       SHOW TABLES;
       SELECT * FROM customers;
       SELECT * FROM transactions;

Key Analytical Queries
----------------------
The script includes multiple queries to analyze fraud patterns:

1) Full Transaction View
   - Joins transactions with customers, cards, and merchants to show full context of each transaction.

2) Overall Fraud Rate
   - Calculates:
       - total_transactions
       - fraud_transactions
       - fraud_rate_percent

3) Fraud by Channel
   - Groups by channel (POS, Online, etc.) to see which channel has higher fraud risk.

4) Risky Merchants
   - Lists merchants with:
       - total_txn
       - fraud_txn
       - fraud_rate_percent
   - Helps identify merchants that are frequently involved in fraud.

5) Customers Involved in Fraud
   - Shows which customers have fraud transactions linked to their cards.

6) High-Value Transaction Detection
   - Filters transactions where amount > 100000 to flag unusually large purchases.

7) Velocity Fraud (Multiple Attempts in 10 Minutes)
   - Detects cases where the same card and merchant appear multiple times in a short time window (e.g., 3 or more attempts in 10 minutes).

8) Impossible Travel / Cross-Border Anomaly
   - Uses window functions (LAG) to compare a card’s current transaction with the previous one.
   - Flags cases where:
       - Merchant country changes between transactions
       - Time difference between transactions is too small (e.g., <= 4 hours)

9) Daily Fraud Summary
   - Groups by transaction date to calculate daily:
       - total_txn
       - fraud_txn
       - fraud_rate_percent

10) Fraud by Merchant Category
    - Summarizes fraud by merchant category (Electronics, Travel, Jewellery, etc.).

Suspicious Transactions View
----------------------------
The script creates a view:

   suspicious_transactions

This view:
- Combines transactions with customers, cards, and merchants.
- Adds a risk_reason column using CASE:
   - 'High amount'
   - 'Cross-border risk'
   - 'Declined transaction'
   - 'Other'

You can query it with:

   SELECT * FROM suspicious_transactions
   ORDER BY txn_timestamp;

This view acts as a simple fraud monitoring layer that could be used by analysts or dashboards.

Use Cases / Learning Outcomes
-----------------------------
From this project you can demonstrate:

- Ability to design a relational schema for fraud detection
- Skill in writing complex SQL queries:
   - INNER JOIN, GROUP BY, HAVING
   - Window functions (LAG)
   - Date/time functions (TIMESTAMPDIFF)
   - CASE expressions
   - Views and reusable logic
- Understanding of basic fraud patterns:
   - High-value anomalies
   - Repeated attempts (velocity)
   - Cross-country impossible travel
   - Merchant and customer risk

How to Mention in Resume
------------------------
Example project line:

"Fraud Detection using MySQL – Designed a relational database and implemented SQL logic to identify high-risk transactions, velocity fraud, and cross-border anomalies using joins, aggregations, window functions, and views, along with fraud rate reporting by channel, merchant, and customer."

Repository Structure
--------------------
Suggested structure in GitHub:

  / (root)
  ├── Fraud_Detection_using_MySQL.sql   # Main SQL script (schema, inserts, queries, views)
  └── README.txt                        # This documentation file

Future Improvements
-------------------
- Add more realistic transaction volume (thousands of rows).
- Add additional rules: device ID, IP address, time-of-day risk.
- Connect MySQL to Python or Power BI for dashboards.
- Implement ML-based fraud scoring on top of this SQL foundation.

Author
------
- Name: Athesh Kumar
-Focus: SQL, Python, Excel, Power BI, Fraud Analytics
