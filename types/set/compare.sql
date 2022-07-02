CREATE FUNCTION "validation".set_eq("a" "validation".SET, "b" "validation".SET) RETURNS BOOLEAN AS
$$
DECLARE
    "length" INT = array_length("a", 1);
    "index"  INT;
BEGIN
    IF ("length" != array_length("b", 1)) THEN
        RETURN FALSE;
    END IF;

    "index" = 1;
    WHILE "index" <= "length"
        LOOP
            IF NOT ("a"["index"] = ANY ("b")) THEN
                RETURN FALSE;
            END IF;
            "index" = "index" + 1;
        END LOOP;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql IMMUTABLE
                    RETURNS NULL ON NULL INPUT;
COMMENT ON FUNCTION "validation".set_eq("validation".SET, "validation".SET) IS 'comparison of sets for equality';



CREATE OPERATOR "validation".= (
    LEFTARG = "validation".SET,
    RIGHTARG = "validation".SET,
    NEGATOR = !=,
    RESTRICT = eqsel,
    FUNCTION = "validation".set_eq
    );
COMMENT ON OPERATOR "validation".=("validation".SET, "validation".SET) IS 'comparison of sets for equality';

CREATE FUNCTION "validation".set_neq("a" "validation".SET, "b" "validation".SET) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN NOT "validation".set_eq("a", "b");
END;
$$ LANGUAGE plpgsql IMMUTABLE
                    RETURNS NULL ON NULL INPUT;
COMMENT ON FUNCTION "validation".set_eq("validation".SET, "validation".SET) IS 'comparison of sets for not equality';

CREATE OPERATOR "validation".!= (
    LEFTARG = "validation".SET,
    RIGHTARG = "validation".SET,
    NEGATOR = =,
    RESTRICT = neqsel,
    FUNCTION = "validation".set_neq
    );
COMMENT ON OPERATOR "validation".!=("validation".SET, "validation".SET) IS 'comparison of sets for not equality';
