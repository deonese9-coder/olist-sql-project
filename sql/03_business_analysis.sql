-- 03_business_analysis.sql
-- Бизнес-аналитика и KPI

-- 1. KPI витрина по месяцам
CREATE OR REPLACE VIEW olist.kpi_monthly_sales AS
WITH monthly_data AS (
    SELECT 
        DATE_TRUNC('month', order_purchase_timestamp) AS year_month,
        EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
        order_id,
        customer_id,
        order_status,
        revenue::numeric AS revenue_numeric,
        items_count
    FROM olist.fct_order_clean
    WHERE order_purchase_timestamp IS NOT NULL
)
SELECT 
    year_month,
    year,
    month,
    COUNT(DISTINCT order_id) AS orders_count,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(revenue_numeric) AS total_revenue,
    ROUND(AVG(revenue_numeric), 2) AS avg_order_value,
    SUM(items_count) AS total_items_sold,
    ROUND(AVG(items_count), 2) AS avg_items_per_order,
    COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) AS delivered_orders,
    COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) AS canceled_orders,
    ROUND(
        COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0), 
        2
    ) AS delivery_success_rate
FROM monthly_data
GROUP BY year_month, year, month
ORDER BY year_month;

-- 2. Топ-5 месяцев по выручке
SELECT 
    TO_CHAR(year_month, 'YYYY-MM') AS period,
    orders_count,
    ROUND(total_revenue, 2) AS revenue,
    ROUND(avg_order_value, 2) AS avg_order_value,
    delivery_success_rate || '%' AS delivery_rate
FROM olist.kpi_monthly_sales
ORDER BY total_revenue DESC
LIMIT 5;

-- 3. Динамика роста по месяцам
SELECT 
    TO_CHAR(year_month, 'YYYY-MM') AS period,
    orders_count,
    ROUND(total_revenue, 2) AS revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY year_month)) * 100.0 /
        NULLIF(LAG(total_revenue) OVER (ORDER BY year_month), 0),
        2
    ) AS revenue_growth_percent,
    delivery_success_rate || '%' AS delivery_rate
FROM olist.kpi_monthly_sales
ORDER BY year_month;

-- 4. Общая статистика по статусам заказов
SELECT 
    order_status,
    COUNT(*) AS orders_count,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    SUM(revenue) AS total_revenue
FROM olist.fct_order_clean
GROUP BY order_status
ORDER BY orders_count DESC;
