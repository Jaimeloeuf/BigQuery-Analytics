  -- Base Query for getting the first open time from events tables
  --
SELECT
  up.key,
  up.value.int_value,
  TIMESTAMP_MILLIS(up.value.int_value) AS created_date
FROM
  `pslove-usa.analytics_182790814.*`,
  UNNEST(user_properties) AS up
WHERE
  up.key = 'first_open_time'
  AND up.value.int_value IS NOT NULL
ORDER BY
  up.value.int_value DESC