CREATE FUNCTION array_unique ("arr" ANYARRAY)
    RETURNS ANYARRAY
    AS $$
BEGIN
    RETURN ARRAY ( SELECT DISTINCT "table".* FROM unnest("arr") "table");
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

COMMENT ON FUNCTION array_unique (ANYARRAY) IS 'removes duplicate elements from array, but order is violated';

