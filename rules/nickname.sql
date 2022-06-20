CREATE OR REPLACE FUNCTION "validation".nickname("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("value" IS NULL) OR ("value" ~ '^[a-z][a-z0-9_\\.]{4,}$');
END
$$ LANGUAGE plpgsql;

-- TESTS. All is false
SELECT *
FROM unnest(ARRAY [
    "validation".nickname('-account'::varchar),
    "validation".nickname('_account'::varchar),
    "validation".nickname('.account'::varchar),
    "validation".nickname('1account'::varchar),
    "validation".nickname('acco'::varchar)
    ]);

