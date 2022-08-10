CREATE FUNCTION unique_rule ("schema_table" TEXT, "columns" TEXT[], "record" JSONB, "where" TEXT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN @extschema@.exists_rule ("schema_table", "columns", "record", "columns", 'simple', "where") IS FALSE;
END;
$$
LANGUAGE plpgsql
STABLE;

