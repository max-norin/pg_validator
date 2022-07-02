CREATE FUNCTION unique_rule("table" TEXT, "columns" TEXT[], "record" JSONB, "where" TEXT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN exists_rule("table", "columns", "record", "columns", 'simple', "where") IS FALSE;
END;
$$ LANGUAGE plpgsql STABLE;
