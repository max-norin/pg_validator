CREATE FUNCTION is_not_distinct_from ("a" ANYELEMENT, "b" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN "a" IS NOT DISTINCT FROM "b";
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION is_not_distinct_from (ANYELEMENT, ANYELEMENT) IS '$1 IS NOT DISTINCT FROM $2';

CREATE OPERATOR =!= (
    LEFTARG = ANYELEMENT, RIGHTARG = ANYELEMENT, NEGATOR = <!>, RESTRICT = eqsel, FUNCTION = is_not_distinct_from
);

COMMENT ON OPERATOR =!= (ANYELEMENT, ANYELEMENT) IS '$1 IS NOT DISTINCT FROM $2';

CREATE FUNCTION is_distinct_from ("a" ANYELEMENT, "b" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN "a" IS DISTINCT FROM "b";
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION is_distinct_from (ANYELEMENT, ANYELEMENT) IS '$1 IS DISTINCT FROM $2';

CREATE OPERATOR <!> (
    LEFTARG = ANYELEMENT, RIGHTARG = ANYELEMENT, NEGATOR = =!=, RESTRICT = neqsel, FUNCTION = is_distinct_from
);

COMMENT ON OPERATOR <!> (ANYELEMENT, ANYELEMENT) IS '$1 IS DISTINCT FROM $2';

