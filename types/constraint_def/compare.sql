CREATE FUNCTION constraint_def_eq("a" CONSTRAINT_DEF, "b" CONSTRAINT_DEF) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("a"."where" =!= "b"."where") AND ("a"."keys" = "b"."keys");
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OPERATOR = (
    LEFTARG = CONSTRAINT_DEF,
    RIGHTARG = CONSTRAINT_DEF,
    NEGATOR = !=,
    RESTRICT = eqsel,
    FUNCTION = constraint_def_eq
    );



CREATE FUNCTION constraint_def_neq("a" CONSTRAINT_DEF, "b" CONSTRAINT_DEF) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN NOT constraint_def_eq("a", "b");
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OPERATOR != (
    LEFTARG = CONSTRAINT_DEF,
    RIGHTARG = CONSTRAINT_DEF,
    NEGATOR = =,
    RESTRICT = neqsel,
    FUNCTION = constraint_def_neq
    );



CREATE FUNCTION constraint_def_contained("a" CONSTRAINT_DEF, "b" CONSTRAINT_DEF) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("a"."where" =!= "b"."where") AND ("a"."keys" <@ "b"."keys");
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION constraint_def_contained(CONSTRAINT_DEF, CONSTRAINT_DEF) IS 'is contained by';

CREATE OPERATOR <@ (
    LEFTARG = CONSTRAINT_DEF,
    RIGHTARG = CONSTRAINT_DEF,
    COMMUTATOR = @>,
    RESTRICT = arraycontsel,
    FUNCTION = constraint_def_contained
    );
COMMENT ON OPERATOR <@(CONSTRAINT_DEF, CONSTRAINT_DEF) IS 'is contained by';



CREATE FUNCTION constraint_def_contains("a" CONSTRAINT_DEF, "b" CONSTRAINT_DEF) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("a"."where" =!= "b"."where") AND ("a"."keys" @> "b"."keys");
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION constraint_def_contains(CONSTRAINT_DEF, CONSTRAINT_DEF) IS 'contains';

CREATE OPERATOR @> (
    LEFTARG = CONSTRAINT_DEF,
    RIGHTARG = CONSTRAINT_DEF,
    COMMUTATOR = <@,
    RESTRICT = arraycontsel,
    FUNCTION = constraint_def_contains
    );
COMMENT ON OPERATOR @>(CONSTRAINT_DEF, CONSTRAINT_DEF) IS 'contains';
