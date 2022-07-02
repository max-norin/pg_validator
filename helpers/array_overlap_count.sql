CREATE FUNCTION array_overlap_count("a" ANYARRAY, "b" ANYARRAY) RETURNS INT AS
$$
DECLARE
    "length" INT = array_length("a", 1);
    "index"  INT;
    "result" INT = 0;
BEGIN
    "index" = 1;
    WHILE "index" <= "length"
        LOOP
            IF ("a"["index"] IS NOT NULL) AND (array_position("b", "a"["index"]) IS NOT NULL) THEN
                "result" = "result" + 1;
            END IF;
            "index" = "index" + 1;
        END LOOP;

    RETURN "result";
END;
$$ LANGUAGE plpgsql IMMUTABLE
                    RETURNS NULL ON NULL INPUT;
COMMENT ON FUNCTION array_overlap_count(ANYARRAY, ANYARRAY) IS 'overlap count';

CREATE OPERATOR &? (
    LEFTARG = ANYARRAY,
    RIGHTARG = ANYARRAY,
    FUNCTION = array_overlap_count
    );
COMMENT ON OPERATOR &?(ANYARRAY, ANYARRAY) IS 'overlap count';
