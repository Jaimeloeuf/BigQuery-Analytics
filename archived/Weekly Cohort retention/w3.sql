  /*  @Doc
    Show the number of users grouped by the week in which that used the app within the past 8 weeks,
    grouped together by the week that they signed up on,
    and grouped together by the number of weeks since they first used the app.
*/
WITH
  -- Create a base_events dataset with data from past 8 weeks and create a new first_open_date column
  events AS (
  SELECT
    *
  FROM
    `pslove-usa.analytics_182790814.*`
  WHERE
    -- Only look at first_open events
    event_name LIKE "%first_open%"),
  mon AS (
  SELECT
    -- Find date of the first monday in the data set.
    MIN(PARSE_DATE('%Y%m%d',
        events.event_date)) AS date
  FROM
    events
  WHERE
    -- BQ starts a week on a sunday with int value 1, thus monday is 2
    -- Using below to filter for only dates that are mondays
    EXTRACT(DAYOFWEEK
    FROM
      PARSE_DATE('%Y%m%d',
        events.event_date)) = 1)
  --
  --
  --
SELECT
  -- The start date or the first date in the new event data set that is generated under events
  DATE_DIFF(first_open_date, mon.date, WEEK) AS signup_week,
  --
  
  --
  COUNT(DISTINCT user_pseudo_id) AS num_of_users
FROM
  events,
  mon
GROUP BY
  signup_week
ORDER BY
  signup_week DESC