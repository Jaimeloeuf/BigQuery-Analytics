/*  @Doc
    Number of downloads, per download source, grouped together and counted
    
    This query is used to fill up the App Key Metric spreadsheet's values in the "first_open" column.
    Using this query, you can skip running the individual queries one by one to filter for device type
*/
WITH
  dates AS (
  SELECT
    DATE(2019, 6, 15) AS start_date,
    DATE(2019, 6, 23) AS end_date),
  events AS (
  SELECT
    event_timestamp,
    event_name,
    user_pseudo_id,
    app_info.install_source AS install_source
  FROM
    `pslove-usa.analytics_182790814.*`,
    dates
  WHERE
    -- Only get the first open events
    event_name LIKE "%first_open%"
    -- Filter out manual installs
    AND app_info.install_source NOT LIKE "%manual%"
    -- Reinstalls are counted in this case
    AND DATE(TIMESTAMP_MICROS(event_timestamp)) > dates.start_date
    AND DATE(TIMESTAMP_MICROS(event_timestamp)) < dates.end_date),
  -- Sub query to get the total number of first_open in the week
  total AS (
  SELECT
    COUNT(DISTINCT user_pseudo_id) AS num_of_users
  FROM
    events)
SELECT
  install_source,
  COUNT(install_source) AS Downloads,
  ROUND(COUNT(install_source) / total.num_of_users * 100, 2) AS percent,
  total.num_of_users AS Total_this_week
FROM
  events,
  total
GROUP BY
  install_source,
  total.num_of_users
ORDER BY
  -- order by number of downloads so that the view is clearer
  Downloads DESC