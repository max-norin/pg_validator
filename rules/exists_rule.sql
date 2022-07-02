CREATE OR REPLACE FUNCTION exists_rule("table" TEXT, "table_columns" TEXT[], "record" JSONB, "record_columns" TEXT[], "mode" FK_MODE = 'full',
                                               "where" TEXT = NULL) RETURNS BOOLEAN AS
$$
DECLARE
    "sql"          TEXT;
    "column"       TEXT;
    "null_counter" INT     = 0;
    "length"       INT     = array_length("table_columns", 1);
    "values"       TEXT[]  = '{}';
    "result"       BOOLEAN = FALSE;
BEGIN
    IF ("length" IS NULL) OR ("length" <!> array_length("record_columns", 1)) THEN
        RETURN FALSE;
    END IF;
    -- get "values" array of escaped variables
    FOREACH "column" IN ARRAY "record_columns"
        LOOP
            -- checks only MATCH FULL can has NULL
            IF "record" ->> "column" IS NULL THEN
                IF "mode" != 'full' THEN
                    RETURN NULL;
                ELSE
                    -- done via counter because NULL can be at end
                    "null_counter" = "null_counter" + 1;
                END IF;
            ELSE
                "values" = array_append("values", format('%L', "record" ->> "column"));
            END IF;
        END LOOP;
    -- checks MATCH FULL
    IF "null_counter" > 0 THEN
        -- number of values is equal to number of NULL
        RETURN "null_counter" = "length";
    END IF;

    "sql" = format('SELECT exists( SELECT * FROM %I WHERE (%s)=(%s) AND %s);', "table", array_to_string("table_columns", ','), array_to_string("values", ','), COALESCE("where", 'TRUE'));
    RAISE INFO USING MESSAGE = (concat('sql: ', "sql"));

    EXECUTE "sql" INTO "result";

    RETURN "result";
END;
$$ LANGUAGE plpgsql STABLE;
