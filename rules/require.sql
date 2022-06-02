CREATE OR REPLACE FUNCTION "validation".require("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    IF ("value" IS NULL) THEN
        RETURN FALSE;
    END IF;

    IF ("validation".string("value")) THEN
        RETURN length(trim("value")) > 0; -- TODO \t \n
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

-- TODO проверка
SELECT "validation".require('3454'::varchar),
       "validation".require('\n   '::varchar),
       "validation".require(''::varchar),
       "validation".require(12123::integer),
       "validation".require(TRUE),
       "validation".require(NULL::varchar);

