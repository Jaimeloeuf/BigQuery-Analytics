/*  @Doc
    Show the number of users grouped by the week in which that used the app within the past 8 weeks,
    grouped together by the week that they signed up on,
    and grouped together by the number of weeks since they first used the app.
*/
WITH
  -- Create a base_events dataset with data from past 8 weeks and create a new first_open_date column for all events
  base_events AS (
  SELECT
    DATE(TIMESTAMP_MICROS(user_first_touch_timestamp)) AS first_open_date,
    *
  FROM
    `pslove-usa.analytics_182790814.*`
  WHERE
    -- Filter for events that occured in the past 8 weeks, and using CURRENT_DATE without any parameters for UTC date.
    -- This filter can be removed, but, it there will be alot more data to process and older data might not be as useful
    DATE_DIFF(CURRENT_DATE(), DATE(TIMESTAMP_MICROS(user_first_touch_timestamp)), WEEK) < 9),
  --
  --
  -- Find the first monday of in the base data set
  mon AS (
  SELECT
    -- Find date of the first monday in the data set.
    MIN(first_open_date) AS date
  FROM
    base_events
  WHERE
    -- BQ starts a week on a sunday with int value 1, thus monday is 2
    -- Using below to filter for only dates that are mondays
    EXTRACT(DAYOFWEEK
    FROM
      first_open_date) = 1),
  -- Filter off data from base_events dataset whose event_date is before first monday
  events AS (
  SELECT
    base_events.*
  FROM
    base_events,
    mon
  WHERE
    --   Filter out events before the first monday
    first_open_date >= mon.date)
  --
  --
  --
SELECT
  -- weeks_since_first_open_time,
  -- Number of weeks from the first monday to the week of this event
  DATE_DIFF(first_open_date, mon.date, WEEK) AS signup_week,
  --
  -- Number of weeks from signup
  DATE_DIFF(DATE(TIMESTAMP_MICROS(event_timestamp)), first_open_date, week) AS week_diff,
  --
  -- Count user_pseudo_id because not all users have user_ids
  COUNT(DISTINCT user_pseudo_id) AS num_of_users
FROM
  events,
  mon
WHERE
  -- Filter out manual installs
  app_info.install_source NOT LIKE "%manual%"
GROUP BY
  -- The order of the grouping is very important! DO NOT CHANGE
  signup_week,
  week_diff
ORDER BY
  -- Technically we do not need to do ordering in BQ as it is done in datastudio
  -- But by doing this, the SQL table output will be more readable
  week_diff ASC,
  signup_week DESC