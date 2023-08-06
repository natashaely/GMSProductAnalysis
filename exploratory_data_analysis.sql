-- View all event types

SELECT
  DISTINCT event_name
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`


-- Examining the overall distribution of event values for purchase events

SELECT
  MIN(event_value_in_usd) AS min_value,
  MAX(event_value_in_usd) AS max_value,
  AVG(event_value_in_usd) AS avg_value,
  STDDEV(event_value_in_usd) AS stddev_value
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  event_name = 'purchase'


-- Examining the overall distribution of purchase revenue in USD

SELECT
  MIN(ecommerce.purchase_revenue_in_usd) AS min_value,
  MAX(ecommerce.purchase_revenue_in_usd) AS max_value,
  AVG(ecommerce.purchase_revenue_in_usd) AS avg_value,
  STDDEV(ecommerce.purchase_revenue_in_usd) AS stddev_value
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`


-- Examining Price distribution

SELECT 
    MIN(item.price_in_usd) AS min_value,
    MAX(item.price_in_usd) AS max_value,
    AVG(item.price_in_usd) AS avg_value,
    STDDEV(item.price_in_usd) AS stddev_value
FROM 
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item


-- Examining the overall distribution of item revenue

SELECT
  MIN(item.item_revenue_in_usd) AS min_value,
  MAX(item.item_revenue_in_usd) AS max_value,
  AVG(item.item_revenue_in_usd) AS avg_value,
  STDDEV(item.item_revenue_in_usd) AS stddev_value
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item


-- Examining the overall distribution of  user lifetime revenue

SELECT
  MIN(user_ltv.revenue) AS min_value,
  MAX(user_ltv.revenue) AS max_value,
  AVG(user_ltv.revenue) AS avg_value,
  STDDEV(user_ltv.revenue) AS stddev_value
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

    
-- Distribution of categorical variables
-- Distribution of events

SELECT
  event_name,
  COUNT(*) AS event_count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY
  event_name
ORDER BY
  event_count DESC;


-- Distribution of product items

SELECT
  item.item_name,
  COUNT(*) AS item_count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
GROUP BY
  item.item_name
ORDER BY
  item_count DESC;


-- Distribution of item categories

SELECT
  item.item_category,
  COUNT(*) AS cat_count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
GROUP BY
  item.item_category
ORDER BY
  cat_count DESC;


-- Distribution of item brand 

SELECT
  item.item_brand,
  COUNT(*) AS brand_count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
GROUP BY
  item_brand
ORDER BY
  brand_count DESC;


-- Distribution of promotions

SELECT
  item.promotion_name,
  COUNT(*) AS promo_count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
GROUP BY
  item.promotion_name
ORDER BY
  promo_count DESC;


-- Analysing numeric values
-- Analysing event values

SELECT
  MIN(event_value_in_usd) AS min_value,
  MAX(event_value_in_usd) AS max_value,
  AVG(event_value_in_usd) AS avg_value,
  SUM(event_value_in_usd) AS total_value
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;


-- Analysing purchase revenue 

SELECT
  MIN(ecommerce.purchase_revenue_in_usd) AS min_value,
  MAX(ecommerce.purchase_revenue_in_usd) AS max_value,
  AVG(ecommerce.purchase_revenue_in_usd) AS avg_value,
  SUM(ecommerce.purchase_revenue_in_usd) AS total_value
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;


-- Analysing item revenue

SELECT
  MIN(item.item_revenue_in_usd) AS min_value,
  MAX(item.item_revenue_in_usd) AS max_value,
  AVG(item.item_revenue_in_usd) AS avg_value,
  SUM(item.item_revenue_in_usd) AS total_value
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;


-- Calculating the frequency of purchase events and an estimated average conversion rate 

WITH
  EventCounts AS (
  SELECT
    SUM(CASE
        WHEN event_name = 'add_to_cart' THEN 1
      ELSE
      0
    END
      ) AS addToCartCount,
    SUM(CASE
        WHEN event_name = 'purchase' THEN 1
      ELSE
      0
    END
      ) AS purchaseCount
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` )
SELECT
  purchaseCount,
  addToCartCount,
  (purchaseCount / addToCartCount) * 100 AS conversionRate
FROM
  EventCounts;


-- Top 10 items added to cart by most users

SELECT
  item.item_id,
  item.item_name,
  COUNT(DISTINCT user_pseudo_id) AS user_count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
WHERE
  event_name = 'add_to_cart'
GROUP BY
  1,
  2
ORDER BY
  user_count DESC
LIMIT
  10;


-- Calculating the average price of the best-selling products

WITH
  TopItems AS (
  SELECT
    item.item_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item
  WHERE
    event_name = 'purchase'
  GROUP BY
    item.item_id
  ORDER BY
    COUNT(*) DESC
  LIMIT
    10 )
SELECT
  AVG(item.price) AS avg_price
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
WHERE
  item.item_id IN (
  SELECT
    item_id
  FROM
    TopItems);


-- Distribution of best-selling products by category

SELECT
  item.item_category,
  COUNT(*) AS count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
WHERE
  item.item_id IN (
  SELECT
    item.item_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item
  WHERE
    event_name = 'purchase'
  GROUP BY
    item.item_id
  ORDER BY
    COUNT(*) DESC
  LIMIT
    10)
GROUP BY
  item.item_category;


-- Common shared characteristics of best-sellers (category)

SELECT
  item.item_category,
  COUNT(*) AS count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
WHERE
  item.item_id IN (
  SELECT
    item.item_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item
  WHERE
    event_name = 'purchase'
  GROUP BY
    item.item_id
  ORDER BY
    COUNT(*) DESC
  LIMIT
    10 )
  AND item.item_category <> '(not set)'
GROUP BY
  item.item_category
ORDER BY
  count DESC;


-- Common shared characteristics of best-sellers (price). 

SELECT
  item.price_in_usd,
  COUNT(*) AS count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
WHERE
  item.item_id IN (
  SELECT
    item.item_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item
  WHERE
    event_name = 'purchase'
  GROUP BY
    item.item_id
  ORDER BY
    COUNT(*) DESC
  LIMIT
    10 )
  AND item.price_in_usd IS NOT NULL
GROUP BY
  item.price_in_usd
ORDER BY
  count DESC;


-- Geographic distribution of buyers for best-sellers

SELECT
  geo.country,
  COUNT(*) AS count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
WHERE
  item.item_id IN (
  SELECT
    item.item_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item
  WHERE
    event_name = 'purchase'
  GROUP BY
    item.item_id
  ORDER BY
    COUNT(*) DESC
  LIMIT
    10 )
GROUP BY
  geo.country
ORDER BY
  count DESC;


-- Device category of buyers for best-sellers

SELECT
  device.category,
  COUNT(*) AS count
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
WHERE
  item.item_id IN (
  SELECT
    item.item_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item
  WHERE
    event_name = 'purchase'
  GROUP BY
    item.item_id
  ORDER BY
    COUNT(*) DESC
  LIMIT
    10 )
GROUP BY
  device.category
ORDER BY
  count DESC;


-- Price and sales correlation: Analysing how price impacts sales

SELECT
  price_range,
  COUNT(*) AS total_sales,
  AVG(item_revenue_in_usd) AS avg_sales
FROM (
  SELECT
    item.item_id,
    item.item_name,
    CASE
      WHEN item.price_in_usd < 50 THEN '0-50'
      WHEN item.price_in_usd BETWEEN 50
    AND 100 THEN '50-100'
    ELSE
    '100+'
  END
    AS price_range,
    item.item_revenue_in_usd
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item )
GROUP BY
  price_range
ORDER BY
  total_sales DESC;


-- Price over time: Examining the average price per month or per quarter

SELECT
  FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP_MICROS(event_timestamp)) AS month,
  AVG(item.price_in_usd) AS avg_price
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
GROUP BY
  month
ORDER BY
  month ASC;


-- Price and geography: Exploring geographic trends in pricing

SELECT
  geo.country,
  AVG(item.price_in_usd) AS avg_price
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS item
GROUP BY
  geo.country
ORDER BY
  avg_price DESC;