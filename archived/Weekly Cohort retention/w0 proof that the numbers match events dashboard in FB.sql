/*  @Doc
    Show the number of users grouped by the week in which that used the app within the past 8 weeks,
    grouped together by the week that they signed up on,
    and grouped together by the number of weeks since they first used the app.
    
    This one is used to proof the numbers are similiar to firebase events if shown day by day. But different from the retention numbers that firebase generates by itself.
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
    DATE_DIFF(CURRENT_DATE(), DATE(TIMESTAMP_MICROS(user_first_touch_timestamp)), WEEK) < 9),
  --
  --
  -- Create a base_events dataset with data from past 8 weeks and create a new first_open_date column
  fo_events AS (
  SELECT
    *
  FROM
    base_events
  WHERE
    -- Only look at first_open events
    event_name LIKE "%first_open%"),
  --
  --
  -- Find the first monday of in the base data set
  mon AS (
  SELECT
    -- Find date of the first monday in the data set.
    MIN(fo_events.first_open_date) AS date
  FROM
    fo_events
  WHERE
    -- BQ starts a week on a sunday with int value 1, thus monday is 2
    -- Using below to filter for only dates that are mondays
    EXTRACT(DAYOFWEEK
    FROM
      fo_events.first_open_date) = 1),
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
    -- The start date or the first date in the new event data set that is generated under events
    -- weeks_since_first_open_time,
    DATE_DIFF(first_open_date, mon.date, WEEK) AS signup_week,
    first_open_date,
    COUNT(DISTINCT user_pseudo_id) AS num_of_users
  FROM
    events,
    mon
  WHERE
    DATE_DIFF(first_open_date, mon.date, WEEK) = 7
  GROUP BY
    signup_week,
    first_open_date
  ORDER BY
    signup_week DESC,
    first_open_date ASC