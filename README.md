# Анализ E-commerce данных Olist (Бразилия)

## 📋 О проекте
Анализ данных бразильского маркетплейса Olist за период 2016-2018 гг. Проект демонстрирует полный цикл работы с данными: от проверки качества до построения аналитических витрин и расчета бизнес-метрик.

## 📊 Ключевые результаты
| Метрика | Значение |
|---------|----------|
| 📦 Заказов в анализе | 98,100 |
| 📅 Период анализа | 2016-09-04 — 2018-09-03 |
| 💰 Общая выручка | R$ 15,717,700 |
| 💳 Средний чек | R$ 160.22 |
| ⚠️ Аномальных заказов | 872 (0.88%) |
| ⚠️ Выручка в аномалиях | R$ 183,404 (1.15%) |

## 🛠 Используемые технологии
- **PostgreSQL** — хранение и обработка данных
- **DBeaver** — SQL-клиент
- **SQL** — CTE, агрегатные функции, оконные функции, работа с типами данных

## 📁 Структура проекта

sql/
├── 01_data_quality.sql # Проверка качества данных и приведение типов
├── 02_create_fact_tables.sql # Создание аналитических витрин
├── 03_business_analysis.sql # Бизнес-аналитика и KPI
└── 04_final_stats.sql # Финальная статистика
results/
└── final_stats.txt # Итоговые результаты проекта


## 🔍 Основные этапы работы

### 1. Проверка качества данных
- Приведение `shipping_limit_date` к типу TIMESTAMP
- Сверка сумм из `order_items` и `payments`
- Выявление расхождений

### 2. Создание витрин
- `fct_order` — базовая витрина на уровне заказа
- `fct_order_enhanced` — с флагами качества данных
- `fct_order_clean` — очищенная версия для анализа
- `fct_order_anomalies` — аномальные заказы
- `kpi_monthly_sales` — ключевые метрики по месяцам

### 3. Классификация аномалий
```sql
CASE 
    WHEN total_items_value = 0 AND total_paid > 0 THEN 'critical_anomaly'
    WHEN total_paid = 0 AND total_items_value > 0 THEN 'warning_anomaly'
    WHEN ABS(items_minus_pay) > 10 THEN 'large_discrepancy'
    WHEN ABS(items_minus_pay) > 0.05 THEN 'small_discrepancy'
    ELSE 'ok'
END AS data_quality_flag


4. Бизнес-аналитика
Динамика выручки по месяцам

Топ-5 месяцев по продажам

Средний чек и успешность доставки

📈 Примеры запросов
Динамика выручки по месяцам
SELECT 
    TO_CHAR(year_month, 'YYYY-MM') AS month,
    orders_count,
    ROUND(total_revenue, 2) AS revenue,
    ROUND(avg_order_value, 2) AS avg_order_value
FROM olist.kpi_monthly_sales
ORDER BY year_month;

Топ-5 месяцев по выручке
SELECT 
    TO_CHAR(year_month, 'YYYY-MM') AS month,
    orders_count,
    ROUND(total_revenue, 2) AS revenue,
    delivery_success_rate || '%' AS delivery_rate
FROM olist.kpi_monthly_sales
ORDER BY total_revenue DESC
LIMIT 5;

🎯 Выводы
Качество данных высокое — 99.12% заказов не имеют критических аномалий

Аномалии требуют внимания — 0.88% заказов содержат расхождения, но на них приходится 1.15% выручки (средний чек выше на 31%)

Методология — разработан подход от сырых данных до бизнес-метрик с контролем качества на каждом этапе

🔗 Ссылки
[Источник данных на Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

[Мой GitHub](https://github.com/deonese9-coder) 

📬 Контакты
Telegram: @Y0GER
Email: deonese9@gmail.com
