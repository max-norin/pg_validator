CREATE OR REPLACE FUNCTION "validation".require("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    IF ("value" IS NULL) THEN
        RETURN FALSE;
    END IF;

    IF (pg_typeof("value") IN ('character', 'character varying', 'text')) THEN
        RETURN length(trim(' \t\n' FROM "value")) > 0;
    END IF;

    RETURN TRUE;
END
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION "validation".require_m("value" ANYELEMENT) RETURNS TEXT AS
$$
BEGIN
    RETURN "validation".require("value") OPERATOR ("validation".|) 'require'::text;
END
$$ LANGUAGE plpgsql;


-- TESTS. All is false
SELECT *
FROM unnest(ARRAY [
    "validation".require(''::varchar),
    "validation".require(' \n \t '::varchar),
    "validation".require(NULL::varchar),
    "validation".require(NULL::integer)
    ]);

