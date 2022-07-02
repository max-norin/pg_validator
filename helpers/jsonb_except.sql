CREATE FUNCTION "validation".jsonb_except("a" JSONB, "b" JSONB) RETURNS JSONB AS
$$
BEGIN
    RETURN (SELECT jsonb_object_agg(key, value)
            FROM (SELECT "key", "value"
                  FROM jsonb_each_text("a")
                  EXCEPT
                  SELECT "key", "value"
                  FROM jsonb_each_text("b")) "table"("key", "value"));
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION "validation".jsonb_except( JSONB, TEXT[], JSONB) IS '';
