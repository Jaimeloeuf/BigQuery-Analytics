# Notes on BQ repo

## Suggest to use partitioned tables
So that it is split up by date, thus when new data comes in, you only transform it day by day.

## Update events database per partition per night instead?
Instead of creating a new data set by selecting all data from the old one.
Create a new column instead.

## Why queries for Segmentation using Sessions are combined
It is better to combine the queries, so you "select" less data, making it cheaper.
Intead of 2 10.8GB selects, you select all once and perform multiple calculations on it.

Ask user to update their apps, or let user know of new features via email marketing when there is something new for the app.

## Partitioning by user_pseudo_id to group the rows together vertically for each user.
Below very imp can use in alot of stuff, like finding the last bday event fired.
So no longer need calculate, just find the last event per user.

-- Group/Partition users and number the events after ordering them by DESCENDING timestamp
ROW_NUMBER() OVER(PARTITION BY user_pseudo_id ORDER BY event_timestamp DESC) AS row_number,

This should be used instead of a partition over and a second ORDER BY Clause.
Because the second order by clause only orders after the partition is completed.
Because the partition is made first before the rest of the stuff are processed.
The only thing ran before the PARTITION code is the WHERE clause.