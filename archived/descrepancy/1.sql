SELECT
  COUNT(DISTINCT user_pseudo_id)
FROM
  `pslove-usa.analytics_182790814.*`,
  UNNEST(user_properties) AS up
WHERE
  DATE(TIMESTAMP_MICROS(event_timestamp)) > DATE(2019, 6, 2)
  AND DATE(TIMESTAMP_MICROS(event_timestamp)) < DATE(2019, 6, 10)
  AND DATE(TIMESTAMP_MICROS(user_first_touch_timestamp)) > DATE(2019, 6, 2)
  AND DATE(TIMESTAMP_MICROS(user_first_touch_timestamp)) < DATE(2019, 6, 10)