CREATE FUNCTION "validation".unique("table" TEXT, "columns" TEXT[], "record" JSONB, "where" TEXT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN "validation".exists("table", "columns", "record", "columns", 'simple', "where") IS FALSE;
END;
$$ LANGUAGE plpgsql STABLE;
