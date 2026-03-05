-- 01_data_quality.sql
-- Проверка качества данных и приведение типов

-- 1. Проверка типа shipping_limit_date
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'olist' 
  AND table_name = 'order_items'
  AND column_name = 'shipping_limit_date';

-- 2. Проверка парсинга без потерь
SELECT 
    COUNT(*) AS total_rows,
    COUNT(shipping_limit_date::TIMESTAMP) AS non_null_after_cast,
    COUNT(*) - COUNT(shipping_limit_date::TIMESTAMP) AS failed_conversions
FROM olist.order_items;

-- 3. Изменение типа колонки (выполнено)
ALTER TABLE olist.order_items
ALTER COLUMN shipping_limit_date TYPE TIMESTAMP
USING shipping_limit_date::TIMESTAMP;

-- 4. Проверка сверки order_items vs payments
WITH order_items_totals AS (
    SELECT 
        order_id,
        SUM(price + freight_value) AS total_order_value
    FROM olist.order_items
    GROUP BY order_id
),
payment_totals AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_paid
    FROM olist.payments
    GROUP BY order_id
)
SELECT 
    COUNT(*) AS orders_compared,
    SUM(CASE WHEN ABS(total_order_value - total_paid) < 0.01 THEN 1 ELSE 0 END) AS equal_orders,
    SUM(CASE WHEN ABS(total_order_value - total_paid) >= 0.01 THEN 1 ELSE 0 END) AS diff_orders,
    AVG(total_order_value - total_paid) AS avg_diff,
    MAX(ABS(total_order_value - total_paid)) AS max_abs_diff
FROM order_items_totals oit
JOIN payment_totals pt ON oit.order_id = pt.order_id;
