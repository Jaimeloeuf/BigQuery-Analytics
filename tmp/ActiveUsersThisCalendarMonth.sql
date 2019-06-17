  -- Active users this calendar month. Meaning how many people used the app this month.
  -- This month meaning calendar month and not how many people used the app in the past 30 Days.
  -- Query will display current month and the number of people who used the app this month.
  --
  -- This query is built on the user dataset's modified_at__seconds attribute
  --
WITH
  -- Get the current date and year
  now AS (
  SELECT
    EXTRACT(month
    FROM
      CURRENT_TIMESTAMP()) AS month,
    EXTRACT(year
    FROM
      CURRENT_TIMESTAMP()) AS year)
SELECT
  EXTRACT(YEAR
  FROM
    TIMESTAMP_SECONDS(modified_at___seconds)) AS modified_year,
  EXTRACT(MONTH
  FROM
    TIMESTAMP_SECONDS(modified_at___seconds)) AS modified_month,
  COUNT(*) AS num_of_users
FROM
  `pslove-usa.users_data_for_analytics.users`,
  now
WHERE
  -- Filter out non-app users
  -- Get all the events created this month
  created_year = now.year
--   AND created_month = now.month
GROUP BY
  modified_year,
  modified_month