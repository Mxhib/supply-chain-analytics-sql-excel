-- ============================================================
-- Regional Performance Analysis
-- Evaluates shipping efficiency, cost, and profitability by region and market
-- ============================================================

CREATE OR REPLACE VIEW regional_performance AS
SELECT
    region,
    market,

    -- Order volume
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_units,

    -- Revenue & profit
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS profit_margin_pct,

    -- Shipping cost efficiency
    ROUND(SUM(shipping_cost)::numeric, 2) AS total_shipping_cost,
    ROUND((SUM(shipping_cost) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS shipping_cost_pct,

    -- Shipping speed
    ROUND(AVG((ship_date_proper - order_date_proper))::numeric, 2) AS avg_shipping_days,
    MIN(ship_date_proper - order_date_proper) AS min_shipping_days,
    MAX(ship_date_proper - order_date_proper) AS max_shipping_days,

    -- Delivery speed mix
    COUNT(*) FILTER (WHERE (ship_date_proper - order_date_proper) <= 2) AS express_orders,
    COUNT(*) FILTER (WHERE (ship_date_proper - order_date_proper) > 10) AS slow_orders,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE (ship_date_proper - order_date_proper) > 10) / COUNT(*)::numeric,
        2
    ) AS slow_delivery_pct

FROM orders
WHERE order_date_proper IS NOT NULL
  AND ship_date_proper  IS NOT NULL
GROUP BY region, market;


-- Analysis Queries

-- Regions with slowest average shipping times
SELECT *
FROM regional_performance
ORDER BY avg_shipping_days DESC;

--Regions with highest shipping cost %
SELECT *
FROM regional_performance
ORDER BY shipping_cost_pct DESC;

-- Regions with high sales but weak profit margins
SELECT *
FROM regional_performance
WHERE total_sales >= 50000
ORDER BY profit_margin_pct ASC;

-- Regions with most slow deliveries
SELECT *
FROM regional_performance
ORDER BY slow_delivery_pct DESC;

-- Export regional_performance to CSV
COPY (
    SELECT * FROM regional_performance
) TO '/Users/mohibabbas/Desktop/regional_performance.csv'
WITH CSV HEADER;

