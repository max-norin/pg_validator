CREATE FUNCTION constraint_def_eq ("a" @extschema@.CONSTRAINT_DEF, "b" @extschema@.CONSTRAINT_DEF)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("a"."where" OPERATOR ( @extschema@.=!= ) "b"."where") AND ("a"."keys" = "b"."keys");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

CREATE OPERATOR = (
    LEFTARG = @extschema@.CONSTRAINT_DEF, RIGHTARG = @extschema@.CONSTRAINT_DEF, NEGATOR = !=, RESTRICT = eqsel, FUNCTION = constraint_def_eq
);

CREATE FUNCTION constraint_def_neq ("a" @extschema@.CONSTRAINT_DEF, "b" @extschema@.CONSTRAINT_DEF)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN NOT constraint_def_eq ("a", "b");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

CREATE OPERATOR != (
    LEFTARG = @extschema@.CONSTRAINT_DEF, RIGHTARG = @extschema@.CONSTRAINT_DEF, NEGATOR = =, RESTRICT = neqsel, FUNCTION = constraint_def_neq
);

CREATE FUNCTION constraint_def_contained ("a" @extschema@.CONSTRAINT_DEF, "b" @extschema@.CONSTRAINT_DEF)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("a"."where" OPERATOR ( @extschema@.=!= ) "b"."where") AND ("a"."keys" <@ "b"."keys");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION constraint_def_contained (@extschema@.CONSTRAINT_DEF, @extschema@.CONSTRAINT_DEF) IS 'is contained by';

CREATE OPERATOR <@ (
    LEFTARG = @extschema@.CONSTRAINT_DEF, RIGHTARG = @extschema@.CONSTRAINT_DEF, COMMUTATOR = @>, RESTRICT = arraycontsel, FUNCTION = constraint_def_contained
);

COMMENT ON OPERATOR <@ (@extschema@.CONSTRAINT_DEF, @extschema@.CONSTRAINT_DEF) IS 'is contained by';

CREATE FUNCTION constraint_def_contains ("a" @extschema@.CONSTRAINT_DEF, "b" @extschema@.CONSTRAINT_DEF)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("a"."where" OPERATOR ( @extschema@.=!= ) "b"."where") AND ("a"."keys" @> "b"."keys");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION constraint_def_contains (@extschema@.CONSTRAINT_DEF, @extschema@.CONSTRAINT_DEF) IS 'contains';

CREATE OPERATOR @> (
    LEFTARG = @extschema@.CONSTRAINT_DEF, RIGHTARG = @extschema@.CONSTRAINT_DEF, COMMUTATOR = <@, RESTRICT = arraycontsel, FUNCTION = constraint_def_contains
);

COMMENT ON OPERATOR @> (@extschema@.CONSTRAINT_DEF, @extschema@.CONSTRAINT_DEF) IS 'contains';

