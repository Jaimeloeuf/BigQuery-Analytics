/*  @Doc
    App Key Metrics query to fill in the number of first open events this "week",
    where the install source is android OS and android OS clones.
*/
SELECT
  COUNT(DISTINCT user_pseudo_id) AS num_of_users
FROM
  `pslove-usa.analytics_182790814.*`
WHERE
  -- Only get the first open events
  event_name LIKE "%first_open%"
  -- Filter out manual installs
  AND app_info.install_source LIKE "%android%"
  -- Change out the DATE constraint below as needed
  AND DATE(TIMESTAMP_MICROS(event_timestamp)) > DATE(2019, 6, 8)
  AND DATE(TIMESTAMP_MICROS(event_timestamp)) < DATE(2019, 6, 16)
  -- Reinstalls are counted in this case