  /* @Doc

Segmentation based on user's session usage
To find the ids of the users who have been retained, defined by a "session_start" event fired in the past 45 days

Steps:
- Filter to get all "session_start" events that happened in the past 45 days
- Keep only those events whose user signed up before the 45 days cutoff period
- Ordered by DESCENDING timestamp (latest session_start event at the top of the partition)
    - This is because when users first start using the app, they may not have created an account (Using anonymous account or what noy)
    - Which means at the start they do not have a user_id until later where some of them decide to sign up for an account.
    - Thus by getting the last event, we can be sure that it contain the latest "most filled up" set of IDs for that user.
    - If they dont have an user_id for example in their last seesion event, then we can be sure that they don't have one.

- Extract all unique user identifers from the events.
- Group/Partition all the session_start events by user_pseudo_id

- Using "row_number = 1", only grab the the first session_start event of the partition.
- Only 1 event is taken for each user because more than 1 session_start events might have been triggered in the past 45 days
        - If not partitioned by user_ids to get 1 event, there will be repeated ids
*/
CREATE OR REPLACE TABLE
  `firestore.segmented_users` AS
WITH
  -- Create a TimeStamp that will be used as the cutoff time, which is 45 days from today
  dates AS (
  SELECT
    TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 45 day) AS cutoff_ts),
  --
  --
  -- Get session_start events from the past 45 days from users that signed up before the past 45 days, and grouped them together by their user_pseudo_id
  events AS (
  SELECT
    -- Group/Partition users and number the events after ordering them by DESCENDING timestamp
    ROW_NUMBER() OVER(PARTITION BY user_pseudo_id ORDER BY event_timestamp DESC) AS row_number,
    user_id,
    user_pseudo_id,
    device.advertising_id
  FROM
    `pslove-usa.analytics_182790814.*`,
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
  ids AS (
  SELECT
    'r' AS user_type,
    * EXCEPT(row_number)
  FROM
    events
  WHERE
    row_number = 1)
SELECT
  user_type,
  events.*
FROM
  ids,
  `pslove-usa.analytics_182790814.*` AS events
WHERE
  events.user_pseudo_id IN (ids.user_pseudo_id)