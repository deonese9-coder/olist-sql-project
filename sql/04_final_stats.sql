-- 04_final_stats.sql

-- 1. Распределение по флагам качества
SELECT 
    data_quality_flag,
    COUNT(*) AS orders_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist.fct_order_enhanced), 2) AS percent,
    ROUND(SUM(total_paid), 2) AS total_revenue
FROM olist.fct_order_enhanced
GROUP BY data_quality_flag
ORDER BY orders_count DESC;

-- 2. Финальная сводка проекта (главный результат)
SELECT '📊 Заказов в анализе' AS metric, COUNT(*)::text AS value FROM olist.fct_order_clean
UNION ALL
SELECT '📊 Период анализа', 
       MIN(order_purchase_timestamp)::date || ' - ' || MAX(order_purchase_timestamp)::date
FROM olist.fct_order_clean
UNION ALL
SELECT '💰 Общая выручка', 'R$ ' || ROUND(CAST(SUM(revenue) AS numeric), 2)::text
FROM olist.fct_order_clean
UNION ALL
SELECT '💰 Средний чек', 'R$ ' || ROUND(CAST(AVG(revenue) AS numeric), 2)::text
FROM olist.fct_order_clean
UNION ALL
SELECT '⚠️ Аномальных заказов', 
       COUNT(*)::text || ' (' || 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist.fct_order_enhanced), 2)::text || '%)'
FROM olist.fct_order_anomalies
UNION ALL
SELECT '⚠️ Выручка в аномалиях',
       'R$ ' || ROUND(CAST(SUM(total_paid) AS numeric), 2)::text || ' (' ||
       ROUND(CAST(SUM(total_paid) AS numeric) * 100.0 / 
             (SELECT CAST(SUM(total_paid) AS numeric) FROM olist.fct_order_enhanced), 2)::text || '%)'
FROM olist.fct_order_anomalies
ORDER BY 
    CASE metric
        WHEN '📊 Заказов в анализе' THEN 1
        WHEN '📊 Период анализа' THEN 2
        WHEN '💰 Общая выручка' THEN 3
        WHEN '💰 Средний чек' THEN 4
        WHEN '⚠️ Аномальных заказов' THEN 5
        WHEN '⚠️ Выручка в аномалиях' THEN 6
        ELSE 7
    END;
