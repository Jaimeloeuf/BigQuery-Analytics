/*  @Doc
    This query groups all user devices and count them with a percentage too.
*/
WITH
  users AS (
  SELECT
    *
  FROM
    `pslove-usa.users_data_for_analytics.users`
  WHERE
--       acc is app acc
    device IS NOT NULL),
  total AS (
  SELECT
    COUNT(doc_ID) AS count
  FROM
    users)
SELECT
-- Null is only shown if the above filter is removed
  IFNULL(device,
    "Unknown") AS Device,
  COUNT(DISTINCT doc_ID) AS Num,
  ROUND(COUNT(DISTINCT doc_ID) / total.count * 100, 2) AS percent
FROM
  users,
  total
GROUP BY
  device,
  total.count
ORDER BY
  Num DESC