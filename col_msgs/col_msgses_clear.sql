/**
  Clearing the COL_MSGS array from empty messages.
 */

/**
  Function to clear COL_MSGS array from empty messages.
  Notes: SETOF COL_MSGS not allowed to use
 */
CREATE OR REPLACE FUNCTION "validation".col_msgses_clear("col_msgses" "validation".COL_MSGS[]) RETURNS "validation".COL_MSGS[] AS
$$
BEGIN
    RETURN (
        WITH "col_msgses"("col", "msgs") AS (
            SELECT "col", array_remove("msgs", NULL)
            FROM unnest("col_msgses") as "table"("col", "msgs")
        )
        SELECT array_agg(("col", "msgs")::"validation".COL_MSGS)
        FROM "col_msgses"
        WHERE array_length("col_msgses"."msgs", 1) > 0
    );
END
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION "validation".col_msgses_clear("validation".COL_MSGS[]) IS 'get not empty COL_MSGS[]';
/**
  Function to raise errors if present.
 */
CREATE OR REPLACE FUNCTION "validation".col_msgses_clear_err("col_msgses" "validation".COL_MSGS[]) RETURNS VOID AS
$$
DECLARE
    "v" JSONB;
BEGIN
    SELECT "validation".col_msgses_clear("col_msgses") INTO "col_msgses";

    IF (array_length("col_msgses", 1) > 0) THEN
        SELECT jsonb_object_agg("col", to_jsonb("msgs")) INTO "v" FROM unnest("col_msgses") "table"("col", "msgs");
        RAISE EXCEPTION USING ERRCODE = 'data_exception', MESSAGE = ("v");
    END IF;
END
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION "validation".col_msgses_clear_err("validation".COL_MSGS[]) IS 'raise not empty COL_MSGS[]';








