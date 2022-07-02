-- all is false
SELECT *
FROM unnest(ARRAY [
    "validation".nickname('-account'::varchar),
    "validation".nickname('_account'::varchar),
    "validation".nickname('.account'::varchar),
    "validation".nickname('1account'::varchar),
    "validation".nickname('acco'::varchar)
    ]);

