  /*  @Doc
    Query to show the retention rate of monthly user cohorts.

    Shows number of users who used the app in this current month,
    grouped together by number of month since they first used the app.
*/
WITH
  -- Create a base_events dataset to create a new first_open_date column for all events
  events AS (
  SELECT
    DATE(TIMESTAMP_MICROS(user_first_touch_timestamp)) AS first_open_date,
    *
  FROM
    `pslove-usa.analytics_182790814.*`)
  --
  --
SELECT
  EXTRACT(year
  FROM
    first_open_date) AS created_year,
  EXTRACT(month
  FROM
    first_open_date) AS created_month,
  -- Number of months from signup, by finding diff in months between event data and created date
  DATE_DIFF(DATE(TIMESTAMP_MICROS(event_timestamp)), first_open_date, MONTH) AS mnth_diff,
  --
  --
  COUNT(DISTINCT user_pseudo_id) AS num_of_users
FROM
  events
/* When filter for manual installs, the numbers become quite different from the firebase value. */
-- WHERE
--   app_info.install_source NOT LIKE "%manual%"
GROUP BY
  -- The order of the grouping is very important! DO NOT CHANGE
  created_year,
  created_month,
  mnth_diff
ORDER BY
  -- Actually no need to order because DataStudio does the ordering too.
  -- Ordering is only used here so that the SQL output looks more readable
  created_year DESC,
  created_month DESC,
  mnth_diff ASC