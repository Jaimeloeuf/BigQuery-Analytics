SELECT
  SUM(IFNULL(number_of_periods,
      0)) AS total_number_of_periods_logged_by_users_who_signed_up_in_this_month,
  EXTRACT(month
  FROM
    TIMESTAMP_SECONDS(created_at___seconds)) AS month,
  EXTRACT(year
  FROM
    TIMESTAMP_SECONDS(created_at___seconds)) AS year
FROM
  `pslove-usa.users_data_for_analytics.users`
GROUP BY
  year,
  month
ORDER BY
  year DESC,
  month DESC
