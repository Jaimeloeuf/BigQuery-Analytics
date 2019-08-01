/*  @Doc
    This query counts the number of events with user_id of null or "anonymous"
*/
SELECT
  COUNT(*) AS num_of_rows,
  COUNT(DISTINCT user_pseudo_id) AS num_of_distinct_pseudo_IDs,
  COUNTIF(user_id IS NULL) AS num_of_rows__UID_null,
  COUNTIF(user_id LIKE "anonymous") AS num_of_rows__UID_anonymous
FROM
  `pslove-usa.analytics_182790814.*`
WHERE
  user_id IS NULL
  OR user_id LIKE "anonymous"