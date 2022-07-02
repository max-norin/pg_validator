CREATE FUNCTION trigger_validate ()
    RETURNS TRIGGER
    AS $$
DECLARE
    "v" JSONB = '{}';
    "column" TEXT;
    "constraint" CONSTRAINT_DEF;
    "constraints" CONSTRAINT_DEF[] = '{}';
    "f_constraints" CONSTRAINT_DEF[] = '{}';
    "u_constraints" CONSTRAINT_DEF[] = '{}';
    "record" CONSTANT JSONB = to_jsonb (NEW);
    "chanced_record" CONSTANT JSONB = "record" - to_jsonb (OLD);
    "chanced_columns" CONSTANT SET = ARRAY (
    SELECT jsonb_object_keys("chanced_record"));
    "relid" CONSTANT OID = TG_RELID;
    "schema" CONSTANT TEXT = TG_TABLE_SCHEMA;
    "table" CONSTANT TEXT = TG_TABLE_NAME;
    "schema_table" CONSTANT TEXT = format('%I.%I', "schema", "table");
    "stack" TEXT;
    "res" BOOLEAN;
    "f_confirmed_constraints" CONSTRAINT_DEF[] = '{}';
    -- variable stores successful constraints to avoid doing same check multiple times
    -- if there is FOREIGN KEY ("user_id", "email") REFERENCES "users"("id", "email") and data is correct
    -- then check FOREIGN KEY ("user_id") REFERENCES "users"("id") and FOREIGN KEY ("email") REFERENCES "users"("email") is irrelevant
    "u_confirmed_constraints" CONSTRAINT_DEF[] = '{}';
    -- variable stores successful constraints to avoid doing same check multiple times
    -- if there is UNIQUE("email") and data is correct
    -- then check UNIQUE("email", "nickname") is irrelevant
BEGIN
    RAISE INFO USING MESSAGE = (concat('table: ', "schema_table"));
    RAISE INFO USING MESSAGE = (concat('chanced_record: ', "chanced_record"));
    -- if there are no changes, then do not checks
    IF array_length("chanced_columns", 1) IS NULL THEN
        RETURN NEW;
    END IF;
    -- if function was called due to presence of ON UPDATE in FOREIGN KEY clause, then do not checks
    GET DIAGNOSTICS "stack" = PG_CONTEXT;
    RAISE INFO USING MESSAGE = (concat('stack: ', "stack"));
    IF position(E'\n' IN "stack") > 0 THEN
        RETURN NEW;
    END IF;
    -- check require rule
    FOR "column" IN
    SELECT a.attname
    FROM pg_attribute a
        JOIN pg_type t ON a.atttypid = t.oid
    WHERE a.attrelid = "relid"
        AND a.attnum > 0
        AND NOT a.attisdropped
        AND (a.attnotnull
            OR (t.typtype = 'd'::"char"
                AND t.typnotnull))
            LOOP
                IF ("chanced_record" ? "column") AND (NOT require_rule ("chanced_record" ->> "column")) THEN
                    "v" = jsonb_array_append ("v", ARRAY["column"], '"require"'::JSONB);
                END IF;
            END LOOP;
    -- get constraints PRIMARY KEY, UNIQUE, FOREIGN KEY and PARTIAL UNIQUE INDEX
    WITH "table" ("constraint") AS (
        SELECT to_constraint_def (pg_get_constraintdef("pg_constraint"."oid"::OID, TRUE), "pg_constraint"."conname")
        FROM "pg_constraint"
        WHERE "pg_constraint"."conrelid" = "relid"
            AND "pg_constraint"."contype" IN ('f', 'p', 'u')
        UNION
        SELECT to_constraint_def (pg_get_indexdef("pg_index"."indexrelid"::OID, 0, TRUE), "pg_class"."relname")
        FROM "pg_index"
            JOIN "pg_class" ON "pg_class"."oid" = "pg_index"."indexrelid"
        WHERE "pg_index"."indrelid" = "relid"
            AND "pg_index"."indisunique" = TRUE
)
    SELECT array_agg("table"."constraint")
    INTO "constraints"
    FROM "table"
    WHERE ("table"."constraint")."columns" && "chanced_columns";
    -- constraints group by "type"
    FOREACH "constraint" IN ARRAY "constraints" LOOP
        CASE "constraint"."type"
        WHEN 'f' THEN
            "f_constraints" = array_append("f_constraints", "constraint");
        WHEN 'u' THEN
            "u_constraints" = array_append("u_constraints", "constraint");
        ELSE
        END CASE;
        END LOOP;
        -- constraints order by priority
        "f_constraints" = constraint_defs_sort ("f_constraints", 'DESC');
        "u_constraints" = constraint_defs_sort ("u_constraints", 'ASC');
        -- FOREIGN KEY constraints
        FOREACH "constraint" IN ARRAY "f_constraints" LOOP
            RAISE DEBUG USING MESSAGE = (concat('def: ', "constraint"."content"));
            RAISE DEBUG USING MESSAGE = (concat('keys: ', "constraint"."keys"));
            RAISE DEBUG USING MESSAGE = (concat('f_cc: ', "f_confirmed_constraints"));
            IF ("v" ?| "constraint"."columns") OR ("constraint" <@ ANY ("f_confirmed_constraints")) THEN
                CONTINUE;
            END IF;
            "res" = exists_rule ("constraint"."fk_table", "constraint"."fk_columns", "record", "constraint"."columns", "constraint"."fk_mode", NULL::TEXT);
            IF ("res" IS TRUE) THEN
                "f_confirmed_constraints" = array_append("f_confirmed_constraints", "constraint");
                ELSEIF ("res" IS FALSE) THEN
                -- array_unique because fk can be assigned
                -- FOREIGN KEY ("user_id", "user_id", "nickname") REFERENCES public."users" ("id", "age", "nickname")
                -- where "user_id" can repeat
                FOREACH "column" IN ARRAY array_unique ("constraint"."columns")
                LOOP
                    "v" = jsonb_array_append ("v", ARRAY["column"], '"exists"'::JSONB);
                    -- to_jsonb('exists:' || "constraint"."name")
                END LOOP;
            END IF;
        END LOOP;
        -- UNIQUE constraints
        FOREACH "constraint" IN ARRAY "u_constraints" LOOP
            RAISE DEBUG USING MESSAGE = (concat('def: ', "constraint"."content"));
            RAISE DEBUG USING MESSAGE = (concat('keys: ', "constraint"."keys"));
            RAISE DEBUG USING MESSAGE = (concat('u_cc: ', "u_confirmed_constraints"));
            IF ("v" ?| "constraint"."columns") OR ("constraint" @> ANY ("u_confirmed_constraints")) THEN
                CONTINUE;
            END IF;
            "res" = unique_rule ("schema_table", "constraint"."columns", "record", "constraint"."where");
            IF ("res" IS TRUE) THEN
                "u_confirmed_constraints" = array_append("u_confirmed_constraints", "constraint");
                ELSEIF ("res" IS FALSE) THEN
                FOREACH "column" IN ARRAY "constraint"."columns" LOOP
                    "v" = jsonb_array_append ("v", ARRAY["column"], '"unique"'::JSONB);
                    -- to_jsonb('unique:' || "constraint"."name")
                END LOOP;
            END IF;
        END LOOP;

        IF ("v" != '{}') THEN
            RAISE EXCEPTION USING ERRCODE = 'data_exception', MESSAGE = "v", SCHEMA = "schema", TABLE = "table";
        END IF;

        RETURN NEW;
END
$$
LANGUAGE plpgsql
STABLE;

