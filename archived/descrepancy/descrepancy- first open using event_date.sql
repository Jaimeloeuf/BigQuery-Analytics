SELECT
  PARSE_DATE('%Y%m%d',
    event_date) AS date,
  COUNT(*)
FROM
  `pslove-usa.analytics_182790814.*`
  --   ,
  --   UNNEST(user_properties) AS up,
  --   UNNEST(event_params) AS params
WHERE
  event_name LIKE "%first_open%"
  --   AND params.key LIKE "%previous_first_open_coun%"
  --     AND params.value.int_value > 0
  --   AND params.value.int_value = 0
  AND PARSE_DATE('%Y%m%d',
    event_date) > DATE(2019, 6, 2)
  AND PARSE_DATE('%Y%m%d',
    event_date) < DATE(2019, 6, 10)
GROUP BY
  date
ORDER BY
  date