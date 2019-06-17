-- Total number of first open events across all events intraday table
-- This event is triggered/recorded when the user opens the app with internet connection
SELECT
  COUNT(*) as num_of_first_opens
FROM
  `pslove-usa.analytics_182790814.*`
WHERE
  event_name = "first_open"