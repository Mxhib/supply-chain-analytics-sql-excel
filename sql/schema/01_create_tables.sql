-- Active: 1766788582550@@127.0.0.1@5432@supply_chain_analytics@public
-- 01_create_tables.sql
-- Creates schema and tables for Supply Chain Analytics project

CREATE SCHEMA IF NOT EXISTS sc;
SET search_path TO sc, public;

-- Main supply chain dataset
CREATE TABLE IF NOT EXISTS dataco_orders (
  row_id BIGSERIAL PRIMARY KEY,

  type TEXT,
  days_for_shipping_real INT,
  days_for_shipment_scheduled INT,
  benefit_per_order NUMERIC,
  sales_per_customer NUMERIC,
  delivery_status TEXT,
  late_delivery_risk INT,

  category_id INT,
  category_name TEXT,

  customer_city TEXT,
  customer_country TEXT,
  customer_email TEXT,
  customer_fname TEXT,
  customer_id INT,
  customer_lname TEXT,
  customer_password TEXT,
  customer_segment TEXT,
  customer_state TEXT,
  customer_street TEXT,
  customer_zipcode TEXT,

  department_id INT,
  department_name TEXT,

  latitude NUMERIC,
  longitude NUMERIC,
  market TEXT,

  order_city TEXT,
  order_country TEXT,
  order_customer_id INT,
  order_date TIMESTAMP,
  order_id INT,

  order_item_cardprod_id INT,
  order_item_discount NUMERIC,
  order_item_discount_rate NUMERIC,
  order_item_id INT,
  order_item_product_price NUMERIC,
  order_item_profit_ratio NUMERIC,
  order_item_quantity INT,
  sales NUMERIC,
  order_item_total NUMERIC,
  order_profit_per_order NUMERIC,

  order_region TEXT,
  order_state TEXT,
  order_status TEXT,

  product_card_id INT,
  product_category_id INT,
  product_description TEXT,
  product_image TEXT,
  product_name TEXT,
  product_price NUMERIC,
  product_status INT,

  SHIPPING_DATE TIMESTAMP,
  SHIPPING_MODE TEXT
);


--access logs table

CREATE TABLE IF NOT EXISTS access_logs (
  product TEXT,
  category TEXT,
  access_date DATE,
  month INT,
  hour INT,
  department TEXT,
  ip TEXT,
  url TEXT
);


