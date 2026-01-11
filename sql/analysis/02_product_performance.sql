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
