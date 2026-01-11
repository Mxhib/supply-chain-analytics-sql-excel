-- ============================================================
-- VIEW: shipping_performance
-- Purpose: Row-level shipping performance + profitability metrics
-- ============================================================

CREATE OR REPLACE VIEW shipping_performance AS
SELECT
    -- Identifiers / dimensions
    order_id,
    product_name,
    category,
    sub_category,
    ship_mode,
    order_priority,
    region,
    market,

    -- Dates
    order_date_proper AS order_date,
    ship_date_proper  AS ship_date,

    -- Shipping time (days)
    (ship_date_proper - order_date_proper) AS actual_shipping_days,

    -- Delivery speed bucket based on shipping days
    CASE
        WHEN (ship_date_proper - order_date_proper) <= 2  THEN 'Express'
        WHEN (ship_date_proper - order_date_proper) <= 5  THEN 'Standard'
        WHEN (ship_date_proper - order_date_proper) <= 10 THEN 'Slow'
        ELSE 'Very Slow'
    END AS delivery_speed,

    -- Financial metrics
    sales,
    quantity,
    profit,
    shipping_cost,

    -- Profit margin (%)
    ROUND((profit / NULLIF(sales, 0) * 100)::numeric, 2) AS profit_margin_pct
FROM orders
WHERE order_date_proper IS NOT NULL
  AND ship_date_proper  IS NOT NULL;


-- ============================================================
-- VIEW: shipping_summary
-- Purpose: Aggregated shipping KPIs by category/subcategory/ship_mode/region
-- ============================================================

CREATE OR REPLACE VIEW shipping_summary AS
SELECT
    category,
    sub_category,
    ship_mode,
    region,

    -- Order volume metrics
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_units,
    ROUND(AVG(quantity)::numeric, 2) AS avg_units_per_order,

    -- Shipping time metrics
    ROUND(AVG((ship_date_proper - order_date_proper))::numeric, 2) AS avg_shipping_days,
    MIN(ship_date_proper - order_date_proper) AS min_shipping_days,
    MAX(ship_date_proper - order_date_proper) AS max_shipping_days,

    -- Delivery speed distribution
    COUNT(*) FILTER (WHERE (ship_date_proper - order_date_proper) <= 2)  AS express_deliveries,
    COUNT(*) FILTER (WHERE (ship_date_proper - order_date_proper) > 10)  AS slow_deliveries,

    -- Delivery speed percentages
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE (ship_date_proper - order_date_proper) <= 2) / COUNT(*)::numeric,
        2
    ) AS express_delivery_pct,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE (ship_date_proper - order_date_proper) > 10) / COUNT(*)::numeric,
        2
    ) AS slow_delivery_pct,

    -- Financial metrics
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND(SUM(shipping_cost)::numeric, 2) AS total_shipping_cost,
    ROUND(AVG(profit / NULLIF(sales, 0) * 100)::numeric, 2) AS avg_profit_margin_pct
FROM orders
WHERE order_date_proper IS NOT NULL
  AND ship_date_proper  IS NOT NULL
GROUP BY category, sub_category, ship_mode, region;

-- worst average shipping time 
SELECT *
FROM shipping_summary
ORDER BY avg_shipping_days DESC
LIMIT 15;

-- highest slow delivery percentage
SELECT *
FROM shipping_summary
ORDER BY slow_delivery_pct DESC, total_orders DESC
LIMIT 15;

-- best express delivery percentage and profit margin
SELECT *
FROM shipping_summary
ORDER BY express_delivery_pct DESC, avg_profit_margin_pct DESC
LIMIT 15;


-- OVERALL SHIPPING PERFORMANCE SUMMARY
SELECT
  COUNT(*) AS total_orders,
  ROUND(AVG(actual_shipping_days)::numeric, 2) AS avg_shipping_days,
  ROUND(AVG(profit_margin_pct)::numeric, 2) AS avg_profit_margin_pct
FROM shipping_performance;


-- ============================================================
-- Product Performance Analysis
-- Identifies top products by sales/profit and flags margin + shipping cost issues
-- ============================================================

CREATE OR REPLACE VIEW product_performance AS
SELECT
    product_id,
    product_name,
    category,
    sub_category,

    -- Volume + revenue
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,

    -- Profitability
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS profit_margin_pct,

    -- Shipping cost efficiency
    ROUND(SUM(shipping_cost)::numeric, 2) AS total_shipping_cost,
    ROUND((SUM(shipping_cost) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS shipping_cost_pct,

    -- Shipping speed (operational)
    ROUND(AVG(ship_date_proper - order_date_proper)::numeric, 2) AS avg_shipping_days

FROM orders
WHERE order_date_proper IS NOT NULL
  AND ship_date_proper IS NOT NULL
GROUP BY product_id, product_name, category, sub_category;


-- Top 15 products by profit
SELECT *
FROM product_performance
ORDER BY total_profit DESC
LIMIT 15;

-- Top 15 products by sales
SELECT *
FROM product_performance
ORDER BY total_sales DESC
LIMIT 15;

-- Products that sell a lot but have weak margins (watch-outs)
SELECT *
FROM product_performance
WHERE total_sales >= 5000
ORDER BY profit_margin_pct ASC
LIMIT 15;

-- Shipping is eating revenue (high shipping cost %)
SELECT *
FROM product_performance
WHERE total_sales >= 2000
ORDER BY shipping_cost_pct DESC
LIMIT 15;