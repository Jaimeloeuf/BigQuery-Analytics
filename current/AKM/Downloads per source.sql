/*  @Doc
    Number of downloads, per download source, grouped together and counted.sql
*/
SELECT
  app_info.install_source,
  COUNT(app_info.install_source) AS Num_Of_Downloads
FROM
  -- Look at data across all time.
  `pslove-usa.analytics_182790814.*`
WHERE
  -- Only get the first open events
  event_name LIKE "%first_open%"
  --   Apply the date constraint below if needed
  --   AND DATE(TIMESTAMP_MICROS(event_timestamp)) > DATE(2019, 6, 8)
  --   AND DATE(TIMESTAMP_MICROS(event_timestamp)) < DATE(2019, 6, 16)
GROUP BY
  app_info.install_source