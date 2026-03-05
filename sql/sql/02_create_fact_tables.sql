-- 02_create_fact_tables.sql
-- Создание аналитических витрин

-- 1. Базовая витрина fct_order
CREATE OR REPLACE VIEW olist.fct_order AS
WITH items_agg AS (
    SELECT 
        order_id,
        COUNT(*) AS items_count,
        SUM(price) AS total_price,
        SUM(freight_value) AS total_freight,
        SUM(price + freight_value) AS total_items_value
    FROM olist.order_items
    GROUP BY order_id
),
pay_agg AS (
    SELECT 
        order_id,
        COUNT(*) AS payments_count,
        SUM(payment_value) AS total_paid
    FROM olist.payments
    GROUP BY order_id
)
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    COALESCE(ia.items_count, 0) AS items_count,
    COALESCE(ia.total_price, 0) AS total_price,
    COALESCE(ia.total_freight, 0) AS total_freight,
    COALESCE(ia.total_items_value, 0) AS total_items_value,
    COALESCE(pa.payments_count, 0) AS payments_count,
    COALESCE(pa.total_paid, 0) AS total_paid,
    COALESCE(ia.total_items_value, 0) - COALESCE(pa.total_paid, 0) AS items_minus_pay
FROM olist.orders o
LEFT JOIN items_agg ia ON o.order_id = ia.order_id
LEFT JOIN pay_agg pa ON o.order_id = pa.order_id;

-- 2. Витрина с флагами качества fct_order_enhanced
CREATE OR REPLACE VIEW olist.fct_order_enhanced AS
SELECT 
    *,
    CASE 
        WHEN total_items_value = 0 AND total_paid > 0 THEN 'critical_anomaly'
        WHEN total_paid = 0 AND total_items_value > 0 THEN 'warning_anomaly'
        WHEN ABS(items_minus_pay) > 10 THEN 'large_discrepancy'
        WHEN ABS(items_minus_pay) > 0.05 THEN 'small_discrepancy'
        ELSE 'ok'
    END AS data_quality_flag
FROM olist.fct_order;

-- 3. Очищенная витрина fct_order_clean
CREATE OR REPLACE VIEW olist.fct_order_clean AS
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    items_count,
    total_price,
    total_freight,
    total_items_value,
    payments_count,
    total_paid AS revenue,
    items_minus_pay,
    data_quality_flag
FROM olist.fct_order_enhanced
WHERE data_quality_flag IN ('ok', 'small_discrepancy')
  AND order_status NOT IN ('canceled', 'unavailable')
  AND total_paid > 0
  AND total_items_value > 0;

-- 4. Витрина аномалий fct_order_anomalies
CREATE OR REPLACE VIEW olist.fct_order_anomalies AS
SELECT *
FROM olist.fct_order_enhanced
WHERE data_quality_flag IN ('critical_anomaly', 'large_discrepancy', 'warning_anomaly');

-- 5. Проверка создания
SELECT 'Все витрины созданы' AS status;
SELECT COUNT(*) AS rows_in_clean FROM olist.fct_order_clean;
