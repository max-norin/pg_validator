CREATE FUNCTION constraint_defs_sort ("constraints" CONSTRAINT_DEF[], "direction" SORT_DIRECTION)
    RETURNS CONSTRAINT_DEF[]
    AS $$
DECLARE
    "all_columns" TEXT[] = '{}';
    "weighty_columns" TEXT[] = '{}';
    "index" INT;
    "length" CONSTANT INT = array_length("constraints", 1);
    "column" TEXT;
BEGIN
    IF "length" IS NULL THEN
        RETURN "constraints";
    END IF;
    -- get "all_columns" array of columns without "where"
    "index" = 1;
    WHILE "index" <= "length" LOOP
        IF "constraints"["index"]."where" IS NULL THEN
            "all_columns" = array_cat("all_columns", "constraints"["index"]."columns");
        END IF;
        "index" = "index" + 1;
    END LOOP;
    -- get "weighty_columns" array of columns that occur more than once
    "index" = 1;
    WHILE "index" < array_length("all_columns", 1)
    LOOP
        "column" = "all_columns"["index"];
        IF array_position("all_columns", "column", "index" + 1) IS NULL THEN
            "index" = "index" + 1;
        ELSE
            "weighty_columns" = array_append("weighty_columns", "column");
            "all_columns" = array_remove("all_columns", "column");
        END IF;
    END LOOP;
    -- sort on frequency of used "columns" without "where"
    WITH "table" AS (
        SELECT "table".*
        FROM unnest("constraints") "table"
        ORDER BY (
                CASE WHEN "table"."where" IS NULL THEN
                    1
                ELSE
                    -1
                END) * "direction"::INTEGER, ("table"."columns" & ? "weighty_columns") * "direction"::INTEGER
)
    SELECT array_agg("table".*) INTO "constraints"
FROM "table";
    RETURN "constraints";
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION constraint_defs_sort (CONSTRAINT_DEF[], SORT_DIRECTION) IS 'sort constraints on frequency of used "columns" without "where"';

