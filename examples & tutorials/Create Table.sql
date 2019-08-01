  /* @Doc
  Example on how to create and use tables using SQL
  */
--   
  /*
  
  CREATE OR REPLACE TABLE
    `firestore.segmented_users` ( x INT64
      OPTIONS
        (description="An optional INTEGER field"),
        y INT64
      OPTIONS
        (description="A second optional INTEGER field") )
  OPTIONS
    ( description="Test BQ Table" ) AS
  SELECT
    COUNT(event_date)
  FROM
    `pslove-usa.analytics_182790814.events_20190819`
   */ /* CREATE OR REPLACE TABLE
    `firestore.segmented_users` ( date string
      OPTIONS
        (description="Event Date"))
  OPTIONS
    ( description="Test BQ Table" ) AS
  SELECT
    event_date
  FROM
    `pslove-usa.analytics_182790814.events_20190819`
   */
CREATE OR REPLACE TABLE
  `firestore.segmented_user` AS
SELECT
  event_date
FROM
  `pslove-usa.analytics_182790814.events_20190819`