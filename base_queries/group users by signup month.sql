/*  @Doc
    This base query, displays 
    and also the exact date that they were created in as the table's first attribute.
*/
with base AS (
    SELECT
    DATE(TIMESTAMP_SECONDS(created_at___seconds)) AS created_date,
    *
    FROM
    `pslove-usa.users_data_for_analytics.users`
    WHERE
    --   TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), TIMESTAMP_SECONDS(created_at___seconds), ) < 2

    -- all users who were created in the past 2 Months from the current month,
    --     If current month is MAY, then all users who signed up in MAY and APR will show up.
    --   AND DATE_DIFF(DATE(CURRENT_TIMESTAMP()), DATE(TIMESTAMP_SECONDS(created_at___seconds)), MONTH) < 2
    ORDER BY
    created_at___seconds DESC)
SELECT
    *
FROM
    base