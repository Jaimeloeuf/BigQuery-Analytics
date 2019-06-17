  /*  @Doc
    This query demos how firebase calculates number of first open users.
    This will give a slightly different result compared to the other methods,
    of counting number of distinct user_id across the eventsDB or doc_id across the userDB
*/
WITH
  -- Create a events dataset with just the event_date column, and only with "first_open" events
  events AS (
  SELECT
    event_date
  FROM
    `pslove-usa.analytics_182790814.*`
  WHERE
    event_name = 'first_open'),
  --
  --
  today AS (
  SELECT
    COUNT(*)
  FROM
    events
  WHERE
    --   Get the numbers for today (UTC time). Can be removed to get total number of events.
    PARSE_DATE('%Y%m%d',
      event_date) = CURRENT_DATE()),
  --
  --
  two_days AS (
  SELECT
    COUNT(*)
  FROM
    events
  WHERE
    --   Use the below example to check for the number across 2 days (UTC time)
    PARSE_DATE('%Y%m%d',
      event_date) = DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)),
  --
  --
  all_time AS (
  SELECT
    COUNT(*)
  FROM
    events)
SELECT
  *
FROM
  -- @IMP  Choose 1 to select from since they are all named the same, there will be duplicates
  today,
  two_days,
  all_time