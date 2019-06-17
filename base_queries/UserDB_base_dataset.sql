/*  @Doc
    Base query for user database
    Most data in the user database is not really needed, thus these only
    includes the most used attributes. Can be modified as you see fit.
    This dataset will also include a newly created, created_date column that
    is pre-parsed out from created_at___seconds as it is commonly used.
*/
WITH
  base AS (
  SELECT
    DATE(TIMESTAMP_SECONDS(created_at___seconds)) AS created_date,
    doc_ID,
    created_at___seconds,
    sources__0__source,
    sources__0__provider,
    number_of_periods
  FROM
    `pslove-usa.users_data_for_analytics.users`)
SELECT
  *
FROM
  base