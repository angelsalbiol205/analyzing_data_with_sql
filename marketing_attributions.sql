--How many campaigns and sources does CoolTShirts use? Which source is used for each campaign?
SELECT DISTINCT utm_source,
  utm_campaign
FROM page_visits;

--What pages are on the CoolTShirts website?
SELECT DISTINCT page_name
FROM page_visits;

--How many first touches is each campaign responsible for?
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (
  SELECT ft.user_id,
         ft.first_touch,
         pv.utm_source,
         pv.utm_campaign
  FROM first_touch ft
  JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch = pv.timestamp
)
SELECT ft_attr.utm_source,
       ft_attr.utm_campaign,
       COUNT(*)
FROM ft_attr
GROUP BY 2
ORDER BY 3 DESC;

--How many last touches is each campaign responsible for?
WITH last_touch AS (
    SELECT user_id,
        MAX(timestamp) as last_touch
    FROM page_visits
    GROUP BY user_id),
lt_attr AS (
  SELECT lt.user_id,
         lt.last_touch,
         pv.utm_source,
         pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch = pv.timestamp
)
SELECT lt_attr.utm_source,
       lt_attr.utm_campaign,
       COUNT(*) AS count
FROM lt_attr
GROUP BY 2
ORDER BY 3 DESC;

--How many visitors make a purchase?
SELECT page_name,
  COUNT (DISTINCT user_id) as 'users'
FROM page_visits
WHERE page_name = '4 - purchase';

--How many last touches on the purchase page is each campaign responsible for?
WITH last_touch AS(
  SELECT user_id,
    MAX(timestamp) AS last_touch
  FROM page_visits
  WHERE page_name = '4 - purchase'
  GROUP BY 1),
lt_attr AS(
  SELECT lt.user_id,
    lt.last_touch,
    pv.utm_campaign,
    pv.utm_source
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
      AND lt.last_touch = pv.timestamp)
SELECT utm_source as source,
  utm_campaign as campaign,
  COUNT(*) AS last_touch
FROM lt_attr
GROUP BY 2
ORDER BY 3 DESC;

