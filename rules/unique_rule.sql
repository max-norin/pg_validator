CREATE FUNCTION unique_rule ("relid" REGCLASS, "columns" TEXT[], "record" JSONB, "where" TEXT = 'TRUE')
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN @extschema@.exists_rule ("relid", "columns", "record", "columns", 'simple', "where") IS FALSE;
END;
$$
LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT
STABLE;

