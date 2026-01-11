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