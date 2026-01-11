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


-- Data Quality Checks

--Check for NULL values in key columns
SELECT 
    COUNT(*) as total_rows,
    COUNT(*) - COUNT(order_id) as missing_order_id,
    COUNT(*) - COUNT(product_name) as missing_product,
    COUNT(*) - COUNT(sales) as missing_sales,
    COUNT(*) - COUNT(quantity) as missing_quantity,
    COUNT(*) - COUNT(order_date_proper) as missing_order_date,
    COUNT(*) - COUNT(ship_date_proper) as missing_ship_date
FROM orders;

-- Check for any weird values
SELECT 
    MIN(sales) as min_sales,
    MAX(sales) as max_sales,
    MIN(quantity) as min_quantity,
    MAX(quantity) as max_quantity,
    MIN(profit) as min_profit,
    MAX(profit) as max_profit,
    MIN(order_date_proper) as earliest_order,
    MAX(order_date_proper) as latest_order
FROM orders;

-- Check unique values for categorical fields
SELECT 
    COUNT(DISTINCT category) as num_categories,
    COUNT(DISTINCT sub_category) as num_subcategories,
    COUNT(DISTINCT ship_mode) as num_ship_modes,
    COUNT(DISTINCT segment) as num_segments,
    COUNT(DISTINCT region) as num_regions
FROM orders;

-- Check for duplicate Row IDs (shouldn't be any since it's PRIMARY KEY)
SELECT row_id, COUNT(*) 
FROM orders 
GROUP BY row_id 
HAVING COUNT(*) > 1;