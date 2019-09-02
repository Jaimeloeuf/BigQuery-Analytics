  /* @Doc

Segmentation based on user's session usage
To find the ids of the users who have churned. Defined by having no "session_start" events fired in the past 45 days

Steps:
- Get all "first_open" and "session_start" events from users who signed up before the 45 days cutoff
    - This is done for both these events because not all IDs like user_ids have been populated yet in "first_open" events
        - Some users may only get a user_id after a few uses or a few session starts
    - All of these events are "grouped" or partitioned together by their common "user_pseudo_id"s
    - Thus by taking both the events, I can assume that the latest events should contains the most user_ids for that user
    - All these events are ordered by DESCENDING timestamp
        - So that the last event for each user is at the top of the partition
- Get the last session_start event and their first_open events before the 45 cutoff days.
    - Now that each user have at least 1 or 2 events
        - Parititon all these events by their psuedo_ids
        - Dont need to order
        - Only select session_start event before the 45 day cutoff
            - Extract the ids and keep it

    - This is because a user who signed up before the cutoff can have a session_start event during the 45 days

- Grab the last session_start event and grab their IDs
    - Get the last session_start event by ordering the events by DESCENDING "event_timestamp"
    - Last session_start event 

    What do we label the new users in the new 45 days signup period? Put as null?
*/
CREATE OR REPLACE TABLE
  `firestore.segmented_users` AS
WITH
  dates AS (
  SELECT
    TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 45 day) AS cutoff_ts),
  --
  --
  -- "first_open" and "session_start" events of users who signed up before the 45 days cutoff
  events AS (
  SELECT
    -- Group/Partition users and number the events after ordering them by DESCENDING timestamp
    ROW_NUMBER() OVER(PARTITION BY user_pseudo_id ORDER BY event_timestamp DESC) AS row_number,
    event_name,
    event_timestamp,
    user_id,
    user_pseudo_id,
    device.advertising_id
  FROM
    `pslove-usa.analytics_182790814.*`,
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
  ids AS (
  SELECT
    'c' AS user_type,
    * EXCEPT(row_number,
      event_name,
      event_timestamp,
      cutoff_ts)
  FROM
    events,
    dates
  WHERE
    -- Take the first event of each user partition, which is the last event triggered by the user.
    row_number = 1
    -- Keep the event only if it is triggered before the 45 days cutoff
    AND TIMESTAMP_DIFF(TIMESTAMP_MICROS(event_timestamp), dates.cutoff_ts, second) < 0)
SELECT
  user_type,
  events.*
FROM
  ids,
  `pslove-usa.analytics_182790814.*` AS events
WHERE
  events.user_pseudo_id IN (ids.user_pseudo_id)