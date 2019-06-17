  -- Active users this calendar month. Meaning how many people used the app this month.
  -- This month meaning calendar month and not how many people used the app in the past 30 Days.
  -- Query will display current month and the number of people who used the app this month.
  --
  -- This query is built on the user dataset's modified_at__seconds attribute
  --
WITH
  -- Get the current date and year
  current_date AS (
  SELECT
    EXTRACT(month
    FROM
      CURRENT_TIMESTAMP()) AS month,
    EXTRACT(year
    FROM
      CURRENT_TIMESTAMP()) AS year)
  --
  --
SELECT
  EXTRACT(YEAR
  FROM
--   
-- Below is WRONG!!! Firstly its milis not secs
-- Secondly, the int_value is first open time not what we want here.
-- 
    TIMESTAMP_SECONDS(up.value.int_value)) AS created_year,
  EXTRACT(MONTH
  FROM
    TIMESTAMP_SECONDS(up.value.int_value)) AS created_month,
  COUNT(DISTINCT user_id) AS num_of_users
FROM
  `pslove-usa.analytics_182790814.*`,
  unnest(user_properties) as up,
  current_date
WHERE
  -- Filter out users who have not completed the signup
  user_id IS NOT NULL
  AND user_id NOT LIKE 'anonymous'
  -- Filter out non-app users
  --   Get all the events created this month
  --   AND = current_date.month
GROUP BY
  created_year,
  created_month