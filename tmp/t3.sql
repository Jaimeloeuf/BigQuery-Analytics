  /* @Doc
    Get monthly new users and monthly new activated users.
    Activated users are users who have at least recorded 1 period.

    @Flow
    get whole dataset
    find the first monday
    filter out accs created before that
    calculate week of signup using first monday as reference point
    group users by the week number they signed up in.
    count total number of users
    count total number of activated users
*/
WITH
  base AS (
  SELECT
    DATE(TIMESTAMP_SECONDS(created_at___seconds)) AS created_date,
    --     *
    doc_ID,
    created_at___seconds,
    sources__0__source,
    sources__0__provider,
    number_of_periods
  FROM
    `pslove-usa.users_data_for_analytics.users`
    --     where
    ),
  mon AS (
  SELECT
    -- Find date of the first monday in the data set.
    MIN(created_date) AS date
  FROM
    base
  WHERE
    -- BQ starts a week on a sunday with int value 1, thus monday is 2
    -- Using below to filter for only dates that are mondays
    EXTRACT(DAYOFWEEK
    FROM
      base.created_date) = 2),
  dataset AS (
  SELECT
    DATE_DIFF(created_date, mon.date, week) AS weeks_since_creation,
    base.*
  FROM
    base,
    mon
  WHERE
    created_date >= mon.date)
SELECT
  weeks_since_creation,
  COUNT(DISTINCT doc_ID) as total_num_of_users,
  COUNTIF(number_of_periods > 0) total_num_of_activated_users,
  TRUNC(COUNTIF(number_of_periods > 0) / COUNT(DISTINCT doc_ID) * 100, 2) AS percentage
FROM
  dataset
GROUP BY
  weeks_since_creation
ORDER BY
  weeks_since_creation DESC