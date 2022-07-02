CREATE FUNCTION "validation".require("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("value" IS NOT NULL);
END
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE FUNCTION "validation".require("value" TEXT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("value" IS NOT NULL) AND (length(trim(' \t\n' FROM "value")) > 0);
END
$$ LANGUAGE plpgsql IMMUTABLE;
