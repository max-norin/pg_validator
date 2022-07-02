CREATE FUNCTION "validation".constraint_eq("a" "validation".CONSTRAINT, "b" "validation".CONSTRAINT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("a"."where" =!= "b"."where") AND ("a"."keys" OPERATOR ("validation".=) "b"."keys");
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OPERATOR "validation".= (
    LEFTARG = "validation".CONSTRAINT,
    RIGHTARG = "validation".CONSTRAINT,
    NEGATOR = !=,
    RESTRICT = eqsel,
    FUNCTION = "validation".constraint_eq
    );



CREATE FUNCTION "validation".constraint_neq("a" "validation".CONSTRAINT, "b" "validation".CONSTRAINT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN NOT "validation".constraint_eq("a", "b");
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OPERATOR "validation".!= (
    LEFTARG = "validation".CONSTRAINT,
    RIGHTARG = "validation".CONSTRAINT,
    NEGATOR = =,
    RESTRICT = neqsel,
    FUNCTION = "validation".constraint_neq
    );



CREATE FUNCTION "validation".constraint_contained("a" "validation".CONSTRAINT, "b" "validation".CONSTRAINT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("a"."where" =!= "b"."where") AND ("a"."keys" <@ "b"."keys");
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION "validation".constraint_contained("validation".CONSTRAINT, "validation".CONSTRAINT) IS 'is contained by';

CREATE OPERATOR "validation".<@ (
    LEFTARG = "validation".CONSTRAINT,
    RIGHTARG = "validation".CONSTRAINT,
    COMMUTATOR = @>,
    RESTRICT = arraycontsel,
    FUNCTION = "validation".constraint_contained
    );
COMMENT ON OPERATOR "validation".<@("validation".CONSTRAINT, "validation".CONSTRAINT) IS 'is contained by';



CREATE FUNCTION "validation".constraint_contains("a" "validation".CONSTRAINT, "b" "validation".CONSTRAINT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("a"."where" =!= "b"."where") AND ("a"."keys" @> "b"."keys");
END;
$$ LANGUAGE plpgsql IMMUTABLE;
COMMENT ON FUNCTION "validation".constraint_contains("validation".CONSTRAINT, "validation".CONSTRAINT) IS 'contains';

CREATE OPERATOR "validation".@> (
    LEFTARG = "validation".CONSTRAINT,
    RIGHTARG = "validation".CONSTRAINT,
    COMMUTATOR = <@,
    RESTRICT = arraycontsel,
    FUNCTION = "validation".constraint_contains
    );
COMMENT ON OPERATOR "validation".@>("validation".CONSTRAINT, "validation".CONSTRAINT) IS 'contains';
