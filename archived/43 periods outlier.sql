-- Query to select outlier caused by "populate DB" script
SELECT
  *
FROM
  `pslove-usa.users_data_for_analytics.users`
WHERE
  doc_ID = 'x8yuqupjU4XeMQDQzwlkouAFLQ82'