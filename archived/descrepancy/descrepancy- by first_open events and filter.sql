  -- This query shows the number of first_open events triggered for each day
  --
SELECT
  DATE(TIMESTAMP_MICROS(event_timestamp)) AS date,
  COUNT(*)
FROM
  `pslove-usa.analytics_182790814.*` AS events,
  UNNEST(event_params) AS params
WHERE
  event_name LIKE "%first_open%"
  -- Only display rows with first_open_time as the event_name. Ignore the other events.
  AND DATE(TIMESTAMP_MICROS(event_timestamp)) > DATE(2019, 6, 2)
  AND DATE(TIMESTAMP_MICROS(event_timestamp)) < DATE(2019, 6, 10)
  AND ( params.key LIKE "%previous_first_open_count%"
    AND params.value.int_value = 0 )
GROUP BY
  date
ORDER BY
  date