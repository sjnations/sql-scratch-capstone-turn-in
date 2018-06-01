--Shannon Spaulding 05.2018 Calculating Churn Rates: Learn SQL from Scratch


-- Get familiar with the data #1 Take a look at the first 100 rows of data in the subscriptions table. How many different segments do you see?

SELECT *
FROM subscriptions;


-- Get familiar with the data #2 Determine the range of months of data provided. Which months will you be able to calculate churn for?

SELECT MIN(subscription_start) AS first_start_date, 
	MAX(subscription_end) AS last_end_date
FROM subscriptions;

SELECT count(*) As count_active_subscriptions
FROM subscriptions
WHERE subscription_end IS NULL;


-- Calculate churn rate for each segment #3 You'll be calculating the churn rate for both segments (87 and 30) over the first 3 months of 2017 (you can't calculate it for December, since there are no subscription_end values yet). To get started, create a temporary table of months.

WITH months AS (
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
)
SELECT *
FROM months;


-- Calculate churn rate for each segment #4 Create a temporary table, cross_join, from subscriptions and your months. Be sure to SELECT every column.

WITH months AS (
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
)
SELECT *
FROM cross_join
LIMIT 100;

-- Calculate churn rate for each segment #5 Create a temporary table, status, from the cross_join table you created. This table should contain: see project

WITH months AS (
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
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
  		WHEN segment = '87'
  			AND (first_day > subscription_start)
  			AND (first_day < subscription_end
            OR subscription_end IS NULL)
  		THEN 1
  		ELSE 0
  	END AS is_active_87,
    CASE
      WHEN segment = '30'
        AND (first_day > subscription_start)
        AND (first_day < subscription_end
            OR subscription_end IS NULL)
      THEN 1
      ELSE 0
    END AS is_active_30
	FROM cross_join
)
SELECT *
FROM status
LIMIT 100;



-- Calculate churn rate for each segment #5 Add an is_canceled_87 and an is_canceled_30 column to the status temporary table. This should be 1 if the subscription is canceled during the month and 0 otherwise.


WITH months AS (
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
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
  		WHEN segment = '87'
  			AND (first_day > subscription_start)
  			AND (first_day < subscription_end
            OR subscription_end IS NULL)
  		THEN 1
  		ELSE 0
  	END AS is_active_87,
    CASE
      WHEN segment = '30'
        AND (first_day > subscription_start)
        AND (first_day < subscription_end
            OR subscription_end IS NULL)
      THEN 1
      ELSE 0
    END AS is_active_30,
  	CASE
  		WHEN segment = '87'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END AS is_canceled_87,
  	CASE
  		WHEN segment = '30'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END AS is_canceled_30
  FROM cross_join
)
SELECT *
FROM status
LIMIT 100;


-- Calculate churn rate for each segment #7 Create a status_aggregate temporary table that is a SUM of the active and canceled subscriptions for each segment, for each month.


WITH months AS (
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
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
  		WHEN segment = '87'
  			AND (first_day > subscription_start)
  			AND (first_day < subscription_end
            OR subscription_end IS NULL)
  		THEN 1
  		ELSE 0
  	END AS is_active_87,
    CASE
      WHEN segment = '30'
        AND (first_day > subscription_start)
        AND (first_day < subscription_end
            OR subscription_end IS NULL)
      THEN 1
      ELSE 0
    END AS is_active_30,
  	CASE
  		WHEN segment = '87'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END AS is_canceled_87,
  	CASE
  		WHEN segment = '30'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END AS is_canceled_30
  FROM cross_join
),
status_aggregate AS (
	SELECT 
  	month,
  	SUM(is_active_87) AS sum_active_87,
  	SUM(is_active_30) AS sum_active_30,
  	SUM(is_canceled_87) AS sum_canceled_87,
  	SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month
)
SELECT *
FROM status_aggregate
LIMIT 100;


-- Calculate churn rate for each segment #8 Calculate the churn rates for the two segments over the three month period. Which segment has a lower churn rate?

WITH months AS (
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
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
  		WHEN segment = '87'
  			AND (first_day > subscription_start)
  			AND (first_day < subscription_end
            OR subscription_end IS NULL)
  		THEN 1
  		ELSE 0
  	END AS is_active_87,
    CASE
      WHEN segment = '30'
        AND (first_day > subscription_start)
        AND (first_day < subscription_end
            OR subscription_end IS NULL)
      THEN 1
      ELSE 0
    END AS is_active_30,
  	CASE
  		WHEN segment = '87'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END AS is_canceled_87,
  	CASE
  		WHEN segment = '30'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END AS is_canceled_30
  FROM cross_join
),
status_aggregate AS (
	SELECT 
  	month,
  	SUM(is_active_87) AS sum_active_87,
  	SUM(is_active_30) AS sum_active_30,
  	SUM(is_canceled_87) AS sum_canceled_87,
  	SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month
),
churn_rate AS (
	SELECT
  	month,
  	1.0 * sum_canceled_87 / sum_active_87 AS churn_rate_87,
  	1.0 * sum_canceled_30 / sum_active_30 AS churn_rate_30
  FROM status_aggregate
)
SELECT * 
FROM churn_rate
LIMIT 100;

-- Bonus How would you modify this code to support a large number of segments?

WITH months AS (
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
),
cross_join AS (
	SELECT *
	FROM subscriptions
  CROSS JOIN months
),
status AS (
	SELECT id,
  	segment,
  	first_day AS month,
  	CASE
  		WHEN  (first_day > subscription_start)
  			AND (first_day < subscription_end
            OR subscription_end IS NULL)
  		THEN 1
  		ELSE 0
  	END AS is_active,
  	CASE
  		WHEN subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END as is_canceled
  FROM cross_join
),
status_aggregate AS (
	SELECT
  	month,
  	segment,
  	SUM(is_active) AS sum_active,
  	SUM(is_canceled) AS sum_canceled
  FROM status
  GROUP BY 1,2
),
churn_rate AS (
	SELECT
  	month,
  	segment,
  	1.0 * sum_canceled / sum_active AS churn_rate
  FROM status_aggregate
  GROUP BY 1, 2
)
SELECT * 
FROM churn_rate
LIMIT 100;


--Queries from presentation slides

-- SLIDE 4: 1.1 

-- A. Range of Start and End dates for subscriptions logged as transaction dates.

SELECT MIN(subscription_start) AS first_start_date, 
	MAX(subscription_end) AS last_end_date
FROM subscriptions;

-- B. Count of records that do not have an End Date (Active Subscriptions)

SELECT count(*) As count_active_subscriptions
FROM subscriptions
WHERE subscription_end IS NULL;


-- SLIDE 5: 1.2

-- A. Range of Start and End dates for subscriptions logged as transaction dates.

SELECT MIN(subscription_start) AS first_start_date, 
	MAX(subscription_end) AS last_end_date
FROM subscriptions;

-- B. Count of records that do not have an End Date (Active Subscriptions)

SELECT count(*) As count_active_subscriptions
FROM subscriptions
WHERE subscription_end IS NULL;


-- SLIDE 6: 1.3

-- A. List of distince values for segment 

SELECT DISTINCT segment, count(*) AS count_user_segment
FROM subscriptions
GROUP BY segment;

-- SLIDE 8: 2.1 

-- A. The overall monthly company churn rate
WITH months AS(
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
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
  		WHEN segment = '87'
  			AND (first_day > subscription_start)
  			AND (first_day < subscription_end
            OR subscription_end IS NULL)
  		THEN 1
  		ELSE 0
  	END AS is_active_87,
    CASE
      WHEN segment = '30'
        AND (first_day > subscription_start)
        AND (first_day < subscription_end
            OR subscription_end IS NULL)
      THEN 1
      ELSE 0
    END AS is_active_30,
  	CASE
  		WHEN segment = '87'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END as is_canceled_87,
  	CASE
  		WHEN segment = '30'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END as is_canceled_30
  FROM cross_join
),
status_aggregate AS (
	SELECT 
  	month,
  	SUM(is_active_87) AS sum_active_87,
  	SUM(is_active_30) AS sum_active_30,
  	SUM(is_canceled_87) AS sum_canceled_87,
  	SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month
),
churn_rate AS (
	SELECT
  	month,
  	1.0 * (sum_canceled_30 + sum_canceled_87) / (sum_active_30 + sum_active_87) AS churn_rate_ALL
  FROM status_aggregate
)
SELECT * 
FROM churn_rate
LIMIT 100;


-- SLIDE 10: 3.1

-- A. The overall monthly company churn rate
WITH months AS(
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
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
  		WHEN segment = '87'
  			AND (first_day > subscription_start)
  			AND (first_day < subscription_end
            OR subscription_end IS NULL)
  		THEN 1
  		ELSE 0
  	END AS is_active_87,
    CASE
      WHEN segment = '30'
        AND (first_day > subscription_start)
        AND (first_day < subscription_end
            OR subscription_end IS NULL)
      THEN 1
      ELSE 0
    END AS is_active_30,
  	CASE
  		WHEN segment = '87'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END as is_canceled_87,
  	CASE
  		WHEN segment = '30'
  			AND subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END as is_canceled_30
  FROM cross_join
),
status_aggregate AS (
	SELECT 
  	month,
  	SUM(is_active_87) AS sum_active_87,
  	SUM(is_active_30) AS sum_active_30,
  	SUM(is_canceled_87) AS sum_canceled_87,
  	SUM(is_canceled_30) AS sum_canceled_30
  FROM status
  GROUP BY month
),
churn_rate AS (
	SELECT
  	month,
  	1.0 * (sum_canceled_30 + sum_canceled_87) / (sum_active_30 + sum_active_87) AS churn_rate_ALL
  FROM status_aggregate
)
SELECT * 
FROM churn_rate
LIMIT 100;


-- SLIDE 10: BONUS 

-- Calculation of churn rate by month by segment; scalable to added segments

WITH months AS(
  SELECT
    '2017-01-01' as first_day,
    '2017-01-31' as last_day
  UNION
   SELECT 
    '2017-02-01' as first_day,
    '2017-02-28' as last_day
  UNION
   SELECT
     '2017-03-01' as first_day,
     '2017-03-31' as last_day
),
cross_join AS (
	SELECT *
	FROM subscriptions
  CROSS JOIN months
),
status AS (
	SELECT id,
  	segment,
  	first_day AS month,
  	CASE
  		WHEN  (first_day > subscription_start)
  			AND (first_day < subscription_end
            OR subscription_end IS NULL)
  		THEN 1
  		ELSE 0
  	END AS is_active,
  	CASE
  		WHEN subscription_end BETWEEN first_day AND last_day
  		THEN 1
  		ELSE 0
  	END as is_canceled
  FROM cross_join
),
status_aggregate AS (
	SELECT
  	month,
  	segment,
  	SUM(is_active) AS sum_active,
  	SUM(is_canceled) AS sum_canceled
  FROM status
  GROUP BY 1,2
),
churn_rate AS (
	SELECT
  	month,
  	segment,
  	1.0 * sum_canceled / sum_active AS churn_rate
  FROM status_aggregate
  GROUP BY 1, 2
)
SELECT * 
FROM churn_rate
LIMIT 100;