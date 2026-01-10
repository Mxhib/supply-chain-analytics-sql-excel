

-- Create the orders table
-- Drop existing table if it exists
DROP TABLE IF EXISTS orders;

-- Create table with TEXT date columns (temporarily)
CREATE TABLE orders (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(50),
    order_date TEXT,
    ship_date TEXT,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    market VARCHAR(50),
    region VARCHAR(100),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2),
    shipping_cost DECIMAL(10,2),
    order_priority VARCHAR(20)
);

--Import the CSV
COPY orders
FROM '/Users/mohibabbas/Data Analyst Projects/supply-chain-analytics-sql-excel/data/raw/global_superstore.csv'
WITH (FORMAT csv, HEADER true, ENCODING 'LATIN1');

-- Add proper DATE columns
ALTER TABLE orders ADD COLUMN order_date_proper DATE;
ALTER TABLE orders ADD COLUMN ship_date_proper DATE;

-- Convert text dates to proper dates
UPDATE orders 
SET order_date_proper = TO_DATE(order_date, 'DD-MM-YYYY'),
    ship_date_proper = TO_DATE(ship_date, 'DD-MM-YYYY');

--  Verify it worked
SELECT COUNT(*) FROM orders;
SELECT order_date, order_date_proper, ship_date, ship_date_proper FROM orders LIMIT 5;