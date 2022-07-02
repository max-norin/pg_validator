CREATE FUNCTION jsonb_except ("a" JSONB, "b" JSONB)
    RETURNS JSONB
    AS $$
BEGIN
    RETURN (
        SELECT jsonb_object_agg(key, value)
        FROM (
            SELECT "key", "value"
            FROM jsonb_each_text("a")
            EXCEPT
            SELECT "key", "value"
            FROM jsonb_each_text("b")
            ) "table" ("key", "value"));
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION jsonb_except (JSONB, JSONB) IS '$1 EXCEPT $2';

CREATE OPERATOR - (
    LEFTARG = JSONB, RIGHTARG = JSONB, FUNCTION = jsonb_except
);

COMMENT ON OPERATOR - (JSONB, JSONB) IS '$1 EXCEPT $2';

