SELECT question,
  COUNT(DISTINCT user_id) AS 'users'
FROM survey
GROUP BY 1; 

SELECT DISTINCT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    h.number_of_pairs,
    p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz AS 'q'
  LEFT JOIN home_try_on AS 'h'
    ON q.user_id = h.user_id
  LEFT JOIN purchase AS 'p'
    ON q.user_id = p.user_id
LIMIT 5;

WITH q AS(
  SELECT '1-quiz' AS 'stage', COUNT(DISTINCT user_id) AS 'distinct_users'
  FROM quiz),
h AS(
  SELECT '2-home_try_on' AS 'stage', COUNT(DISTINCT user_id) AS 'distinct_users'
  FROM home_try_on),
p AS(
  SELECT '3-purchase' AS 'stage', COUNT(DISTINCT user_id) AS 'distinct_users'
  FROM purchase)
SELECT *
FROM q
UNION
SELECT *
FROM h
UNION
SELECT *
FROM p;

SELECT h.number_of_pairs,
  COUNT(h.user_id) AS 'num_users',
  COUNT(p.user_id) AS 'num_purchase'
FROM home_try_on AS 'h'
LEFT JOIN purchase AS 'p'
  ON h.user_id = p.user_id
GROUP BY 1;