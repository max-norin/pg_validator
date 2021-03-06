CREATE TYPE SORT_DIRECTION AS ENUM (
    'ASC', 'DESC'
);

CREATE FUNCTION sort_direction_to_int ("direction" SORT_DIRECTION)
    RETURNS INT
    AS $$
BEGIN
    IF "direction" IS NULL THEN
        RETURN 1;
    END IF;
    RETURN CASE "direction"
    WHEN 'ASC' THEN
        1
    WHEN 'DESC' THEN
        -1
    END;
END
$$
LANGUAGE plpgsql
IMMUTABLE;

CREATE CAST (SORT_DIRECTION AS INTEGER) WITH FUNCTION sort_direction_to_int (SORT_DIRECTION) AS ASSIGNMENT;

