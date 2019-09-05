/*  @Doc
    This query creates user type for each type of users and creates a new table with the type as the first column
    of every single event from the event database.
*/
CREATE OR REPLACE TABLE
  `firestore.segmented_users` AS
WITH
  events AS (
  SELECT
    *
  FROM
    `pslove-usa.analytics_182790814.*` ),
  -- Create a TimeStamp that will be used as the cutoff time, which is 45 days from today
  dates AS (
  SELECT
    TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 45 day) AS cutoff_ts),
  --
  --
  -- Get session_start events from the past 45 days from users that signed up before the past 45 days, and grouped them together by their user_pseudo_id
  retained_events AS (
  SELECT
    -- Group/Partition users and number the events after ordering them by DESCENDING timestamp
    ROW_NUMBER() OVER(PARTITION BY user_pseudo_id ORDER BY event_timestamp DESC) AS row_number,
    user_id,
    user_pseudo_id,
    device.advertising_id
  FROM
    events,
    dates
  WHERE
    -- Get all session_start events only
    event_name = "session_start"
    -- Event is from the past 45 days
    AND TIMESTAMP_DIFF(TIMESTAMP_MICROS(event_timestamp), dates.cutoff_ts, second) > 0
    -- User is created before the past 45 days
    AND TIMESTAMP_DIFF(TIMESTAMP_MICROS(user_first_touch_timestamp), dates.cutoff_ts, second) < 0),
  --
  --
  -- Only get the latest record from each user partition.
  retained_ids AS (
  SELECT
    'r' AS user_type,
    * EXCEPT(row_number)
  FROM
    retained_events
  WHERE
    row_number = 1),
  --
  --
  -- "first_open" and "session_start" events of users who signed up before the 45 days cutoff
  churned_events AS (
  SELECT
    -- Group/Partition users and number the events after ordering them by DESCENDING timestamp
    ROW_NUMBER() OVER(PARTITION BY user_pseudo_id ORDER BY event_timestamp DESC) AS row_number,
    event_name,
    event_timestamp,
    user_id,
    user_pseudo_id,
    device.advertising_id
  FROM
    events,
    dates
  WHERE
    -- Get all "first_open" and "session_start" events only
    (event_name = "session_start"
      OR event_name = "first_open")
    -- For users who are created before the past 45 days
    AND TIMESTAMP_DIFF(TIMESTAMP_MICROS(user_first_touch_timestamp), dates.cutoff_ts, second) < 0),
  --
  --
  -- Only get the latest record from each user partition.
  churned_ids AS (
  SELECT
    'c' AS user_type,
    * EXCEPT(row_number,
      event_name,
      event_timestamp,
      cutoff_ts)
  FROM
    churned_events,
    dates
  WHERE
    -- Take the first event of each user partition, which is the last event triggered by the user.
    row_number = 1
    -- Keep the event only if it is triggered before the 45 days cutoff
    AND TIMESTAMP_DIFF(TIMESTAMP_MICROS(event_timestamp), dates.cutoff_ts, second) < 0),
  --
  --
  -- Union of all IDs for both user types
  ids AS (
  SELECT
    *
  FROM
    churned_ids
  UNION ALL
  SELECT
    *
  FROM
    retained_ids)
    -- 
    -- 
SELECT
  user_type,
  events.*
FROM
  ids
RIGHT OUTER JOIN
  events
USING
  (user_pseudo_id)


  /*
  
  SHIT WAIT A MOMENT

  In the final select statement, we are joining all the ids with the events.
  If the "ids" only contain ids for retained and churned users, what about the "n" users?
  How will the join work?
  Will it be joining also, but just that the new fields that are joined are given null values?
  
  
  */