CREATE FUNCTION "validation".jsonb_array_append("json" JSONB, "path" TEXT[], "value" JSONB) RETURNS JSONB AS
$$
BEGIN
    RETURN jsonb_set("json", "path", COALESCE("json" #> "path", '[]'::JSONB) || "value");
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION "validation".jsonb_array_append( JSONB, TEXT[], JSONB) IS 'insert "value" into array along "path"';
