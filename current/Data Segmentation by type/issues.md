# Issues facing the use of Periods as method of user segmentation
The user segementation query using the periods database does not really work right now, due to missing/invalid data in the "periods" database.  
This document is written on 2nd September, so some things might have already by done, so please update accordingly.  
A script needs to be written to loop through all the fields in the periods database to fill in missing attributes and to correct invalid data.  

## Tasks to be completed to fix the issues
- Need to fill up all the missing user_id values, around 39,293 missing user_id out of the 103623 period records.
    - The missing user_id data is available in one of the attributes called "path", which is essentially the NoSQL database path to that object that just so happen to contain the user_id values of each row.
    - A script running across the firebase database should basically take the user_id value from the database path and insert it into the missing user_id field.
    - After this query is ran, there should not be a single row of data where the user_id attribute is empty
- Missing modified_at fields of 3845 out of 100K rows of records
    - Since there is no way of knowing what is the modified_at value at the time of running the script, a fixed value should be used, or just leave it empty so that the pseudo value does not affect the stats too much with the bias of 3800++ similiar values.
    - This one would require perhaps either using the created_at value or their last active value to fill up the missing "modified_at"
- 92 period records with missing created_at timestamps.
    - Not sure how will this will be added, perhaps by using the last day of that period cycle?
    - This is not a huge number of records, so it is not that important, but should still be fixed to avoid inconsistencies.
- Records with other missing attributes like cycle_length and period days and stuff
    - This is not an urgent priority, but can probably be fixed up while the others are done too.