CREATE OR REPLACE FUNCTION "validation".unique_m("result" BOOLEAN) RETURNS TEXT AS
$$
BEGIN
    RETURN result OPERATOR ("validation".|) 'unique'::text;
END
$$ LANGUAGE plpgsql;
