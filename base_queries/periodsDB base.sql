/*  @Doc
    Base query for the periods database.

    Created_at field is when the period has been created/added
    Modified_at field is when the period has been last modified.

    Modified_at will be treated as the last used value, so even if user did not create a period in the past 45 days,
    but they modified any existing period in the past 45 days, it will also be counted as a retained user.
*/
WITH
  periods AS (
  SELECT
    -- Order the rows by user_id and order the records of each unique user_id by the "modified_at" attribute in a descending manner.
    ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY modified_at DESC) AS row_number,
    user_id,
    __key__.path,
    created_at,
    modified_at,
    has_been_manually_ended_or_shortened,
    start_date_time,
    end_date_time,
    cycle_length,
    period_length
  FROM
    `pslove-usa.firestore.periods`
  WHERE
    -- Will be removed after Haris cleaned the DB up
    user_id IS NOT NULL)
SELECT
  *
FROM
  periods