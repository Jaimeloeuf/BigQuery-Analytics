/*  @Doc
    Base Query for getting the first open time from all events in the events tables
    All events other than the "first_open" event, should have this timestamp
    User_properties needs to be unnested/flattened before it can be accessed.
*/
SELECT
  user_id,
  up.key,
  up.value.int_value
FROM
  `pslove-usa.analytics_182790814.*`,
  UNNEST(user_properties) AS up
WHERE
  up.key = 'first_open_time'