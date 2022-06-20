CREATE OR REPLACE FUNCTION "validation".alpha("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("value" IS NULL) OR ("value" ~* '^[a-zA-Z]*$');
END
$$ LANGUAGE plpgsql;
