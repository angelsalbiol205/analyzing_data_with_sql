--Take a look at the first 100 rows of data in the subscriptions table. How many different segments do you see? Two, 87 and 30
SELECT*
FROM subscriptions
LIMIT 100;

--Determine the range of months of data provided. Which months will you be able to calculate churn for? January, February and March
SELECT MIN(subscription_end),
  MAX(subscription_end)
FROM subscriptions;

--You’ll be calculating the churn rate for both segments (87 and 30) over the first 3 months of 2017 (you can’t calculate it for December, 
--since there are no subscription_end values yet). To get started, create a temporary table of months
WITH months AS (
  SELECT
    '2017-01-01' as 'first_day',
    '2017-01-31' as 'last_day'
  UNION
  SELECT
    '2017-02-01' as 'first_day',
    '2017-02-28' as 'last_day'
  UNION
  SELECT
    '2017-03-01' as 'first_day',
    '2017-03-31' as 'last_day'
)

--Create a temporary table, cross_join, from subscriptions and your months. Be sure to SELECT every column.
WITH months AS (
  SELECT
    '2017-01-01' as 'first_day'.
    '2017-01-31' as 'last_day'
  UNION
  SELECT
    '2017-02-01' as 'first_day',
    '2017-02-28' as 'last_day'
  UNION
  SELECT
    '2017-03-01' as 'first_day',
    '2017-03-31' as 'last_day'
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
);


--Create a temporary table, status, from the cross_join table you created. This table should contain:
---id selected from cross_join
---month as an alias of first_day
---is_active_87 created using a CASE WHEN to find any users from segment 87 who existed prior to the beginning of the month. This is 1 if true and 0 otherwise.
---is_active_30 created using a CASE WHEN to find any users from segment 30 who existed prior to the beginning of the month. This is 1 if true and 0 otherwise.
WITH months AS (
  SELECT
    '2017-01-01' as 'first_day',
    '2017-01-31' as 'last_day'
  UNION
  SELECT
    '2017-02-01' as 'first_day',
    '2017-02-28' as 'last_day'
  UNION
  SELECT
    '2017-03-01' as 'first_day',
    '2017-03-31' as 'last_day'
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
  SELECT id,
  first_day AS month,
  CASE
    WHEN (segment = 87)
      AND (subscription_start < first_day)
      AND (subscription_end > first_day
        OR subscription_end IS NULL)
    THEN 1
    ELSE 0
  END AS is_active_87,
  CASE
    WHEN (segment = 30)
      AND (subscription_start < first_day)
      AND (subscription_end > first_day
        OR subscription_end IS NULL)
    THEN 1
    ELSE 0
  END AS is_active_30
FROM cross_join
)
SELECT *
FROM status
LIMIT 10;

--Add an is_canceled_87 and an is_canceled_30 column to the status temporary table. This should be 1 if the subscription is canceled during the month and 0 otherwise.
WITH months AS (
  SELECT
    '2017-01-01' as 'first_day',
    '2017-01-31' as 'last_day'
  UNION
  SELECT
    '2017-02-01' as 'first_day',
    '2017-02-28' as 'last_day'
  UNION
  SELECT
    '2017-03-01' as 'first_day',
    '2017-03-31' as 'last_day'
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
  SELECT id,
  first_day AS month,
  CASE
    WHEN (segment = 87)
      AND (subscription_start < first_day)
      AND (subscription_end > first_day
        OR subscription_end IS NULL) THEN 1
    ELSE 0
  END AS is_active_87,
  CASE
    WHEN (segment = 30)
      AND (subscription_start < first_day)
      AND (subscription_end > first_day
        OR subscription_end IS NULL) THEN 1
    ELSE 0
  END AS is_active_30,
  CASE
    WHEN (subscription_end BETWEEN first_day AND last_day)
      AND (segment = 87) THEN 1
    ELSE 0
  END AS is_canceled_87,
  CASE
    WHEN (subscription_end BETWEEN first_day AND last_day)
      AND (segment = 30) THEN 1
    ELSE 0
  END AS is_canceled_30
FROM cross_join
)
SELECT *
FROM status
LIMIT 10;

--Create a status_aggregate temporary table that is a SUM of the active and canceled subscriptions for each segment, for each month. The resulting columns should be:
---sum_active_87
---sum_active_30
---sum_canceled_87
---sum_canceled_30
WITH months AS (
  SELECT
    '2017-01-01' as 'first_day',
    '2017-01-31' as 'last_day'
  UNION
  SELECT
    '2017-02-01' as 'first_day',
    '2017-02-28' as 'last_day'
  UNION
  SELECT
    '2017-03-01' as 'first_day',
    '2017-03-31' as 'last_day'
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
  SELECT id,
  first_day AS month,
  CASE
    WHEN (segment = 87)
      AND (subscription_start < first_day)
      AND (subscription_end > first_day
        OR subscription_end IS NULL) THEN 1
    ELSE 0
  END AS is_active_87,
  CASE
    WHEN (segment = 30)
      AND (subscription_start < first_day)
      AND (subscription_end > first_day
        OR subscription_end IS NULL) THEN 1
    ELSE 0
  END AS is_active_30,
  CASE
    WHEN (subscription_end BETWEEN first_day AND last_day)
      AND (segment = 87) THEN 1
    ELSE 0
  END AS is_canceled_87,
  CASE
    WHEN (subscription_end BETWEEN first_day AND last_day)
      AND (segment = 30) THEN 1
    ELSE 0
  END AS is_canceled_30
FROM cross_join
),
status_aggregate AS (
  SELECT month,
    SUM(is_active_87) AS active_87,
    SUM(is_active_30) AS active_30,
    SUM(is_canceled_87) AS canceled_87,
    SUM(is_canceled_30) AS canceled_30
  FROM status
  GROUP BY month
)
SELECT *
FROM status_aggregate;

--Calculate the churn rates for the two segments over the three month period. Which segment has a lower churn rate?
WITH months AS (
  SELECT
    '2017-01-01' as 'first_day',
    '2017-01-31' as 'last_day'
  UNION
  SELECT
    '2017-02-01' as 'first_day',
    '2017-02-28' as 'last_day'
  UNION
  SELECT
    '2017-03-01' as 'first_day',
    '2017-03-31' as 'last_day'
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
  SELECT id,
  first_day AS month,
  CASE
    WHEN (segment = 87)
      AND (subscription_start < first_day)
      AND (subscription_end > first_day
        OR subscription_end IS NULL) THEN 1
    ELSE 0
  END AS is_active_87,
  CASE
    WHEN (segment = 30)
      AND (subscription_start < first_day)
      AND (subscription_end > first_day
        OR subscription_end IS NULL) THEN 1
    ELSE 0
  END AS is_active_30,
  CASE
    WHEN (subscription_end BETWEEN first_day AND last_day)
      AND (segment = 87) THEN 1
    ELSE 0
  END AS is_canceled_87,
  CASE
    WHEN (subscription_end BETWEEN first_day AND last_day)
      AND (segment = 30) THEN 1
    ELSE 0
  END AS is_canceled_30
FROM cross_join
),
status_aggregate AS (
  SELECT month,
    SUM(is_active_87) AS active_87,
    SUM(is_active_30) AS active_30,
    SUM(is_canceled_87) AS canceled_87,
    SUM(is_canceled_30) AS canceled_30
  FROM status
  GROUP BY month
)
SELECT month,
  ROUND(100.0* (canceled_87) / (active_87), 2) AS 'churn rate 87',
  ROUND(100.0* (canceled_30) / (active_30), 2) AS 'churn rate 30'
FROM status_aggregate;

--How would you modify this code to support a large number of segments?
WITH months AS (
  SELECT
    '2017-01-01' as 'first_day',
    '2017-01-31' as 'last_day'
  UNION
  SELECT
    '2017-02-01' as 'first_day',
    '2017-02-28' as 'last_day'
  UNION
  SELECT
    '2017-03-01' as 'first_day',
    '2017-03-31' as 'last_day'
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
  SELECT id,
  first_day AS month,
  segment,
  CASE
    WHEN subscription_start < first_day
      AND (subscription_end > first_day 
        OR subscription_end IS NULL) THEN 1
    ELSE 0
  END AS is_active,
  CASE
    WHEN subscription_end BETWEEN first_day AND last_day THEN 1
    ELSE 0
  END AS is_canceled
FROM cross_join
),
status_aggregate AS (
  SELECT month,
    segment,
    SUM(is_active) AS active,
    SUM(is_canceled) AS canceled
  FROM status
  GROUP BY month, segment
)
SELECT month,
  segment,
  ROUND(100.0 * canceled / active, 2) AS 'churn rate'
FROM status_aggregate
GROUP BY month, segment;
