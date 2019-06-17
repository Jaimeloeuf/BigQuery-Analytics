SELECT
  COUNT(DISTINCT events.user_pseudo_id )
FROM
  `pslove-usa.analytics_182790814.*` AS events,
  --   UNNEST(user_properties) AS up
  UNNEST(event_params) AS params
WHERE
  event_name LIKE "%first_open%"
  AND params.key LIKE "%previous_first_open_coun%"
  AND params.value.int_value > 0
--   AND app_info.install_source NOT LIKE "%manual_install%"