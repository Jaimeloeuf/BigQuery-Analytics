/*  @Doc
    This query selects all the fields needed for app_remove analysis from their respective records,
    so that it is flattened out for export to CSV.
*/
SELECT
  user_id,
  user_pseudo_id,
  event_date,
  DATE(TIMESTAMP_MICROS(user_first_touch_timestamp)) AS first_open_date,
  TIMESTAMP_DIFF(TIMESTAMP_MICROS(event_timestamp), TIMESTAMP_MICROS(user_first_touch_timestamp), minute) AS mins_before_uninstall,
  TIMESTAMP_DIFF(TIMESTAMP_MICROS(event_timestamp), TIMESTAMP_MICROS(user_first_touch_timestamp), hour) AS hours_before_uninstall,
  device.mobile_brand_name,
  device.mobile_model_name,
  device.mobile_marketing_name,
  device.mobile_os_hardware_model,
  device.operating_system_version,
  device.advertising_id,
  device.LANGUAGE,
  geo.continent,
  geo.country,
  geo.region,
  geo.city,
  geo.sub_continent,
  app_info.version,
  app_info.install_source,
  traffic_source.name,
  traffic_source.medium,
  traffic_source.source
FROM
  `pslove-usa.analytics_182790814.*`
WHERE
  event_name LIKE "%app_remove%"
ORDER BY
  event_date DESC