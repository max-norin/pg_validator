CREATE OR REPLACE FUNCTION "validation".exists_m("result" BOOLEAN) RETURNS TEXT AS
$$
BEGIN
    RETURN result OPERATOR ("validation".|) 'exists'::text;
END
$$ LANGUAGE plpgsql;
