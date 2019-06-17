# Big Query queries
Repo contains all our queries used on BQ.  
.vscode workspace config file is also saved. Feel free to use it or not.


## Repo structure and descriptions
archived
- Old queries that are no longer used in production.
- Still kept for reference.

base_queries
- Contains all the base queries that can be built upon to create more complex queries.
- Most of these queries can be used for chaining purposes, as they can be built into a "WITH" clause.

current
- Contains all the queries currently used in production.
- Also contains all the queries that are being worked on right now.
- Similiar queries in this directory may also be grouped together too.


## Calculating cohort using BigQuery
All time and date data needed should be extracted from a timestamp value. And all timestamp values should be in UTC format for consistency. Timestamps that are available for use in the events database are:
- event_timestamp
- user_first_touch_timestamp
- (Not recommended)  user_properties.value.int_value
    - This holds the value for the first_open timestamp as part of every single events' user property.
- (Not recommended)  event_date
    - "event_date" is not recommended because it is based on the locale of the user's device. Meaning that there is no fix timezone used across all the events, which makes clustering by dates/times difficult and erroneous.

For event time or event date, always use the "event_timestamp" value. To get the event date from the timestamp value, use the query below:
```sql
DATE(TIMESTAMP_MICROS(event_timestamp)
```
To get the user's first_open_time, use the "user_first_touch_timestamp" value. To get the date from the timestamp, use the query below:
```sql
DATE(TIMESTAMP_MICROS(user_first_touch_timestamp))
```
Count the number of users by distince "user_pseudo_id" because for events like "first_open" there will be no real user_id available yet, thus firebase will automatically generate a unique value to use as the "user_pseudo_id" for identification
```sql
COUNT(distinct user_pseudo_id)
```
For most of the analysis, especially cohort retention analysis, we would want to exclude the manual installs, as these are installation / users that are created when we do app testing, and thus should not count towards the actual stats. To Filter out manual installs:
```sql
WHERE
  app_info.install_source NOT LIKE "%manual%"
```
To remove reinstall numbers:
```sql
-- @TODO to be implemented
WHERE
  event.params.value > 1
```