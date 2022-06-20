CREATE OR REPLACE FUNCTION "validation".alpha("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("value" IS NULL) OR ("value" ~* '^[a-zA-Z]*$');
END
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION "validation".alpha_m("value" ANYELEMENT) RETURNS TEXT AS
$$
BEGIN
    RETURN "validation".alpha("value") OPERATOR ("validation".|) 'alpha'::text;
END
$$ LANGUAGE plpgsql;

