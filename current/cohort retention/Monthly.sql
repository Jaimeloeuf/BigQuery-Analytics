/*  @Doc
    Query to show the retention rate of monthly user cohorts.

    Shows number of users who used the app in this current month,
    grouped together by number of month since they first used the app.
*/
SELECT
  EXTRACT(year
  FROM
    DATE(TIMESTAMP_MILLIS(up.value.int_value))) AS created_year,
  EXTRACT(month
  FROM
    DATE(TIMESTAMP_MILLIS(up.value.int_value))) AS created_month,
  -- Number of months from signup, by finding diff in months between event data and created date
  DATE_DIFF(PARSE_DATE('%Y%m%d',
      event_date), DATE(TIMESTAMP_MILLIS(up.value.int_value)), MONTH) AS mnth_diff,
  COUNT(DISTINCT user_id) AS num_of_users
FROM
  `pslove-usa.analytics_182790814.*`,
  UNNEST(user_properties) AS up
WHERE
  -- Only display rows with first_open_time
  up.key = 'first_open_time'
  -- Filter out non-app users
  AND (platform LIKE "%ANDROID%"
    OR platform LIKE "%IOS%")
    --  There should be 1 or 2 more users without the below 2 filters, as it will group all null user_ids as 1 user and anonymous as another
  AND user_id IS NOT NULL
  AND user_id NOT LIKE 'anonymous'
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