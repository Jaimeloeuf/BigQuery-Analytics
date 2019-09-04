/*  @Doc
    Base query for user database
    Most data in the user database is not really needed, thus these only
    includes the most used attributes. Can be modified as you see fit.
    This dataset will also include a newly created, created_date column that
    is pre-parsed out from created_at___seconds as it is commonly used.
*/
base AS(
      SELECT
        __key__.name AS id,
        created_at,
        modified_at,
        sources,
        build_number,
        build,
        version,
        emails
      FROM
        `firestore.users`)