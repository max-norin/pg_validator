-- all is false
SELECT *
FROM unnest(ARRAY [
    nickname('-account'::varchar),
    nickname('_account'::varchar),
    nickname('.account'::varchar),
    nickname('1account'::varchar),
    nickname('acco'::varchar)
    ]);

