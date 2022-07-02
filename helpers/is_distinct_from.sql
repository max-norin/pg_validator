CREATE FUNCTION "validation".is_not_distinct_from("a" ANYELEMENT, "b" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN "a" IS NOT DISTINCT FROM "b";
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION "validation".is_not_distinct_from(ANYELEMENT, ANYELEMENT) IS '$1 IS NOT DISTINCT FROM $2';

CREATE OPERATOR "validation".=!= (
    LEFTARG = ANYELEMENT,
    RIGHTARG = ANYELEMENT,
    NEGATOR = <!>,
    RESTRICT = eqsel,
    FUNCTION = "validation".is_not_distinct_from
    );
COMMENT ON OPERATOR "validation".=!=(ANYELEMENT, ANYELEMENT) IS '$1 IS NOT DISTINCT FROM $2';

CREATE FUNCTION "validation".is_distinct_from("a" ANYELEMENT, "b" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN "a" IS DISTINCT FROM "b";
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION "validation".is_distinct_from(ANYELEMENT, ANYELEMENT) IS '$1 IS DISTINCT FROM $2';

CREATE OPERATOR "validation".<!> (
    LEFTARG = ANYELEMENT,
    RIGHTARG = ANYELEMENT,
    NEGATOR = =!=,
    RESTRICT = neqsel,
    FUNCTION = "validation".is_distinct_from
    );
COMMENT ON OPERATOR "validation".<!>(ANYELEMENT, ANYELEMENT) IS '$1 IS DISTINCT FROM $2';
