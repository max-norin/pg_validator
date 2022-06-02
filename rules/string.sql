CREATE OR REPLACE FUNCTION "validation".string("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    -- TODO нужна ли проверка на строку? если postgresql сам конвектирует в строку??
    IF ("value" IS NULL) THEN
        RETURN FALSE;
    END IF;

    RETURN pg_typeof("value") IN ('character', 'character varying', 'text');
END
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION "validation".string_m("value" ANYELEMENT) RETURNS TEXT AS
$$
BEGIN
    RETURN "validation".string("value") OPERATOR ("validation".|) 'string'::text;
END
$$ LANGUAGE plpgsql;

SELECT "validation".require('3454'::varchar),
       "validation".require('\n   '::varchar),
       "validation".require(''::varchar),
       "validation".require(12123::integer),
       "validation".require(TRUE),
       "validation".require(NULL::varchar);
