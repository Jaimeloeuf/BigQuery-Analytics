# Churn/Retained user segmentation
This folder contains all queries, used to create datasources that have an additional column indicating if the user is a churned, retained or new user.  
The datasets/datasources created by these queries are used for doing user type breakdown in other queries or in DataStudio (Or really any other data visualisation tool) for the analysis of similiar results but between users who are considered to have churned and users we consider to be retained.  
All of this datasource segmentation metric are based on a 45 days cutoff, where all time and actions are measured on the timeline relative to the 45 days cutoff. The 45 days cutoff mark is defined as 45 days ago from the time of query execution, in timestamps.  

There are a total of 3 different types of users, namely:
- New users (n)
    - New users are users who created their account in after the 45 days cutoff.
    - Since both churn and retained values are calculated based actions relative to the 45 days cutoff timestamp, users whose accounts are created after the cutoff timestamp cannot be used for these metrics and as such they are labelled as new users.
    - New users should not be used as part of the Magic moment analysis, only churn and retained users should be used.
- Churned users (c)
    - Churned users are users who did not engage with the app as defined by the particular metric, one example would be, the user did not use the app for 45 days, thus did not trigger any events in the past 45 days, thus they are labelled as churn users.
- Retained users (r)
    - Retained users are users who are retained as defined by the particular metric, where for example, the user that used the app again in the past 45 days is labelled as a retained user.
    
The newly created "user_type" columns/attributes will have 1 of 3 values as defined above following the user type, and the value will be either of the following:
```
n, c, r
```