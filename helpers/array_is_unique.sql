CREATE FUNCTION array_is_unique ("arr" ANYARRAY)
    RETURNS BOOLEAN
    AS $$
DECLARE
    "length" CONSTANT INT = array_length("arr", 1);
    "index" INT;
BEGIN
    "index" = 1;
    WHILE "index" < "length" LOOP
        IF array_position("arr", "arr"["index"], "index" + 1) IS NOT NULL THEN
            RETURN FALSE;
        END IF;
        "index" = "index" + 1;
    END LOOP;
    RETURN TRUE;
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

COMMENT ON FUNCTION array_is_unique (ANYARRAY) IS 'checks array for duplicate elements';

