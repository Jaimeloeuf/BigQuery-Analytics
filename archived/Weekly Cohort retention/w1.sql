/*  @Doc
    Show the number of users grouped by the week in which that used the app within the past 8 weeks,
    grouped together by the week that they signed up on,
    and grouped together by the number of weeks since they first used the app.
*/
WITH
  -- Create a base_events dataset with data from past 8 weeks and create a new first_open_date column
  base_events AS (
  SELECT
    DATE(TIMESTAMP_MILLIS(up.value.int_value)) AS first_open_date,
    *
  FROM
    `pslove-usa.analytics_182790814.*`,
    UNNEST(user_properties) AS up
  WHERE
    -- Only display rows with first_open_time
    up.key = 'first_open_time'
    -- Filter for only events that occured in the past 2 months or past 8 weeks
    AND DATE_DIFF(CURRENT_DATE("Asia/Singapore"), DATE(TIMESTAMP_MILLIS(up.value.int_value)), WEEK) < 9),
  -- Find the first monday of in the base data set
  mon AS (
  SELECT
    -- Find date of the first monday in the data set.
    MIN(PARSE_DATE('%Y%m%d',
        base_events.event_date)) AS date
  FROM
    base_events
  WHERE
    -- BQ starts a week on a sunday with int value 1, thus monday is 2
    -- Using below to filter for only dates that are mondays
    EXTRACT(DAYOFWEEK
    FROM
      PARSE_DATE('%Y%m%d',
        base_events.event_date)) = 1),
  -- Filter off data from base_events dataset whose event_date is before first monday
  events AS (
  SELECT
    base_events.*
  FROM
    base_events,
    mon
  WHERE
    --   Filter out events before the first monday
    PARSE_DATE('%Y%m%d',
      event_date) >= mon.date)
  --
  --
  --
SELECT
  -- The start date or the first date in the new event data set that is generated under events
  DATE_DIFF(first_open_date, mon.date, WEEK) AS signup_week,
  --
  COUNT(DISTINCT user_pseudo_id) AS num_of_users
FROM
  events,
  mon
GROUP BY
  signup_week
ORDER BY
  signup_week DESC