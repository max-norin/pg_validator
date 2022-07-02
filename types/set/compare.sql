CREATE FUNCTION set_eq ("a" SET, "b" SET)
    RETURNS BOOLEAN
    AS $$
DECLARE
    "length" CONSTANT INT = array_length("a", 1);
    "index" INT;
BEGIN
    IF ("length" != array_length("b", 1)) THEN
        RETURN FALSE;
    END IF;
    "index" = 1;
    WHILE "index" <= "length" LOOP
        -- = because SET element cannot be NULL
        IF NOT ("a"["index"] = ANY ("b")) THEN
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

COMMENT ON FUNCTION set_eq (SET, SET) IS 'comparison of sets for equality';

CREATE OPERATOR = (
    LEFTARG = SET, RIGHTARG = SET, NEGATOR = !=, RESTRICT = eqsel, FUNCTION = set_eq
);

COMMENT ON OPERATOR = (SET, SET) IS 'comparison of sets for equality';

CREATE FUNCTION set_neq ("a" SET, "b" SET)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN NOT set_eq ("a", "b");
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

COMMENT ON FUNCTION set_eq (SET, SET) IS 'comparison of sets for not equality';

CREATE OPERATOR != (
    LEFTARG = SET, RIGHTARG = SET, NEGATOR = =, RESTRICT = neqsel, FUNCTION = set_neq
);

COMMENT ON OPERATOR != (SET, SET) IS 'comparison of sets for not equality';

