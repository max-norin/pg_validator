CREATE FUNCTION exists_rule ("relid" REGCLASS, "table_columns" TEXT[], "record" JSONB, "record_columns" TEXT[], "mode" @extschema@.FK_MODE = 'full', "where" TEXT = 'TRUE')
    RETURNS BOOLEAN
    AS $$
DECLARE
    "has_null" CONSTANT BOOLEAN NOT NULL = ("record" ->> "record_columns"[1]) IS NULL;
    "is_null"           BOOLEAN;
    "index"             INT;
    "length"   CONSTANT INT              = array_length("table_columns", 1);
    "values"            TEXT[] NOT NULL  = '{}';
    "sql"               TEXT;
    "result"            BOOLEAN NOT NULL = FALSE;
BEGIN
    IF ("length" IS NULL) OR ("length" OPERATOR ( @extschema@.<!> ) array_length("record_columns", 1)) THEN
        RETURN FALSE;
    END IF;
    -- get "values" array of escaped variables
    "index" = 1;
    WHILE "index" <= "length" LOOP
        -- checks only MATCH FULL can has NULL
        "is_null" = "record" ->> "record_columns"["index"] IS NULL;
        IF "is_null" THEN
            IF "mode" != 'full' THEN
                RETURN NULL;
            ELSE
                -- if first value is NULL and current value is NOT NULL, or vice versa
                IF "has_null" != "is_null" THEN
                    RETURN FALSE;
                END IF;
            END IF;
        ELSE
            "values" = array_append("values", format('%L', "record" ->> "record_columns"["index"]));
        END IF;
        "index" = "index" + 1;
    END LOOP;
    -- checks MATCH FULL
    IF "has_null" THEN
        -- number of values is equal to number of NULL
        RETURN TRUE;
    END IF;
    "sql" = format('SELECT exists( SELECT * FROM %s WHERE (%s)=(%s) AND %s);', "relid", array_to_string("table_columns", ','), array_to_string("values", ','), COALESCE("where", 'TRUE'));
    RAISE INFO USING MESSAGE = (concat('sql: ', "sql"));
    EXECUTE "sql" INTO "result";
    RETURN "result";
END;
$$
LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT
STABLE;

