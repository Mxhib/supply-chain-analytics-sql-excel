-- ============================================================
-- Category Performance Analysis
-- Summarizes sales, profit, margin, shipping cost efficiency,
-- and shipping speed by category and sub-category.
-- ============================================================

CREATE OR REPLACE VIEW category_performance AS
SELECT
    category,
    sub_category,

    -- Volume
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,
    ROUND(AVG(quantity)::numeric, 2) AS avg_units_per_order,

    -- Revenue + profit
    ROUND(SUM(sales)::numeric, 2)  AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS profit_margin_pct,

    -- Shipping cost efficiency
    ROUND(SUM(shipping_cost)::numeric, 2) AS total_shipping_cost,
    ROUND((SUM(shipping_cost) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS shipping_cost_pct,

    -- Operational (shipping speed)
    ROUND(AVG((ship_date_proper - order_date_proper))::numeric, 2) AS avg_shipping_days,
    ROUND(MIN(ship_date_proper - order_date_proper)::numeric, 0) AS min_shipping_days,
    ROUND(MAX(ship_date_proper - order_date_proper)::numeric, 0) AS max_shipping_days

FROM orders
WHERE order_date_proper IS NOT NULL
  AND ship_date_proper  IS NOT NULL
GROUP BY category, sub_category;

-- Top Subcategories by profit

SELECT *
FROM category_performance
ORDER BY total_profit DESC
LIMIT 15;
--Worst Margins
SELECT *
FROM category_performance
ORDER BY profit_margin_pct ASC
LIMIT 15;

-- High Shipping Cost %
SELECT *
FROM category_performance
WHERE total_sales >= 5000
ORDER BY shipping_cost_pct DESC
LIMIT 15;

-- Slowest Shipping Categories
SELECT *
FROM category_performance
ORDER BY avg_shipping_days DESC
LIMIT 15;

-- Fastest Shipping Categories
SELECT *
FROM category_performance
ORDER BY avg_shipping_days ASC
LIMIT 15;

-- Low Sales but High Profit
SELECT *
FROM category_performance
WHERE total_sales >= 20000
ORDER BY total_profit ASC
LIMIT 15;


