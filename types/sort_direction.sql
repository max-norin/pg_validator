CREATE TYPE "validation".SORT_DIRECTION AS ENUM ('ASC', 'DESC');
CREATE FUNCTION "validation".sort_direction_to_int("direction" "validation".SORT_DIRECTION) RETURNS INT AS
$$
BEGIN
    IF "direction" IS NULL THEN
        RETURN 1;
END IF;

RETURN CASE "direction"
WHEN 'ASC' THEN 1
WHEN 'DESC' THEN -1
END;
END


$$ LANGUAGE plpgsql IMMUTABLE;
CREATE CAST ("validation".SORT_DIRECTION AS INTEGER) WITH FUNCTION "validation".sort_direction_to_int("validation".SORT_DIRECTION) AS ASSIGNMENT;
