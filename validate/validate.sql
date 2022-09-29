CREATE FUNCTION trigger_validate ()
    RETURNS TRIGGER
    AS $$
DECLARE
    "v"                        JSONB                                = '{}';
    "constraints"   @extschema@.CONSTRAINT_DEF[]                    = '{}';
    "f_constraints" @extschema@.CONSTRAINT_DEF[] NOT NULL           = '{}';
    "u_constraints" @extschema@.CONSTRAINT_DEF[] NOT NULL           = '{}';
    "record" CONSTANT          JSONB NOT NULL                       = to_jsonb(NEW);
    "changed_record" CONSTANT  JSONB NOT NULL                       = "record" OPERATOR ( @extschema@.- ) to_jsonb (OLD);
    "changed_columns" CONSTANT @extschema@.SET NOT NULL             = ARRAY (SELECT jsonb_object_keys("changed_record"));
    "relid" CONSTANT           OID NOT NULL                         = TG_RELID;
    "column"                   TEXT;
    "constraint"    @extschema@.CONSTRAINT_DEF;
    "stack"                    TEXT;
    "res"                      BOOLEAN;
    "f_confirmed_constraints" @extschema@.CONSTRAINT_DEF[] NOT NULL = '{}';
    -- variable stores successful constraints to avoid doing same check multiple times
    -- if there is FOREIGN KEY ("user_id", "email") REFERENCES "users"("id", "email") and data is correct
    -- then check FOREIGN KEY ("user_id") REFERENCES "users"("id") and FOREIGN KEY ("email") REFERENCES "users"("email") is irrelevant
    "u_confirmed_constraints" @extschema@.CONSTRAINT_DEF[] NOT NULL = '{}';
    -- variable stores successful constraints to avoid doing same check multiple times
    -- if there is UNIQUE("email") and data is correct
    -- then check UNIQUE("email", "nickname") is irrelevant
BEGIN
    RAISE INFO USING MESSAGE = (concat('table: ', "relid"));
    RAISE INFO USING MESSAGE = (concat('changed_record: ', "changed_record"));
    -- if there are no changes, then do not checks
    IF array_length("changed_columns", 1) IS NULL THEN
        RETURN NEW;
    END IF;
    -- if function was called due to presence of ON UPDATE in FOREIGN KEY clause, then do not checks
    GET DIAGNOSTICS "stack" = PG_CONTEXT;
    RAISE INFO USING MESSAGE = (concat('stack: ', "stack"));
    IF "stack" !~* 'at (GET DIAGNOSTICS|SQL STATEMENT|EXECUTE)$' THEN
        RETURN NEW;
    END IF;
    -- NOT NULL constraints
    FOR "column" IN SELECT a.attname
                    FROM pg_attribute a
                        JOIN pg_type t ON a.atttypid = t.oid
                    WHERE a.attrelid = "relid"
                        AND a.attnum > 0
                        AND NOT a.attisdropped
                        AND a.attgenerated = ''
                        AND (a.attnotnull OR (t.typtype = 'd'::"char" AND t.typnotnull))
            LOOP
                IF ("changed_record" ? "column") AND (NOT @extschema@.require_rule ("changed_record" ->> "column")) THEN
                    "v" = @extschema@.jsonb_array_append ("v", ARRAY["column"], '"validation.require"'::JSONB);
                END IF;
            END LOOP;
    -- get constraints PRIMARY KEY, UNIQUE, FOREIGN KEY and PARTIAL UNIQUE INDEX
    WITH "table" ("constraint") AS (
        SELECT @extschema@.to_constraint_def (pg_get_constraintdef("pg_constraint"."oid"::OID, TRUE), "pg_constraint"."conname")
        FROM "pg_constraint"
        WHERE "pg_constraint"."conrelid" = "relid"
            AND "pg_constraint"."contype" IN ('f', 'p', 'u')
        UNION
        SELECT @extschema@.to_constraint_def (pg_get_indexdef("pg_index"."indexrelid"::OID, 0, TRUE), "pg_class"."relname")
        FROM "pg_index"
            JOIN "pg_class" ON "pg_class"."oid" = "pg_index"."indexrelid"
        WHERE "pg_index"."indrelid" = "relid"
            AND "pg_index"."indisunique" = TRUE
    )
    SELECT array_agg("table"."constraint")
    INTO "constraints"
    FROM "table"
    WHERE ("table"."constraint")."columns" && "changed_columns";
    -- constraints group by "type"
    FOREACH "constraint" IN ARRAY COALESCE("constraints", ARRAY []::@extschema@.CONSTRAINT_DEF[]) LOOP
        CASE "constraint"."type"
        WHEN 'f' THEN
            "f_constraints" = array_append("f_constraints", "constraint");
        WHEN 'u' THEN
            "u_constraints" = array_append("u_constraints", "constraint");
        ELSE
        END CASE;
    END LOOP;
    -- constraints order by priority
    "f_constraints" = @extschema@.constraint_defs_sort ("f_constraints", 'DESC');
    "u_constraints" = @extschema@.constraint_defs_sort ("u_constraints", 'ASC');
    -- FOREIGN KEY constraints
    FOREACH "constraint" IN ARRAY COALESCE("f_constraints", ARRAY []::@extschema@.CONSTRAINT_DEF[]) LOOP
        RAISE DEBUG USING MESSAGE = (concat('def: ', "constraint"."content"));
        RAISE DEBUG USING MESSAGE = (concat('keys: ', "constraint"."keys"));
        RAISE DEBUG USING MESSAGE = (concat('f_cc: ', "f_confirmed_constraints"));
        IF ("v" ?| "constraint"."columns") OR ("constraint" OPERATOR ( @extschema@.<@ ) ANY ("f_confirmed_constraints")) THEN
            CONTINUE;
        END IF;
        "res" = @extschema@.exists_rule ("constraint"."fk_table", "constraint"."fk_columns", "record", "constraint"."columns", "constraint"."fk_mode");
        IF ("res" IS TRUE) THEN
            "f_confirmed_constraints" = array_append("f_confirmed_constraints", "constraint");
        ELSEIF ("res" IS FALSE) THEN
            -- array_unique because fk can be assigned
            -- FOREIGN KEY ("user_id", "user_id", "nickname") REFERENCES public."users" ("id", "age", "nickname")
            -- where "user_id" can repeat
            FOREACH "column" IN ARRAY @extschema@.array_unique ("constraint"."columns")
            LOOP
                "v" = @extschema@.jsonb_array_append ("v", ARRAY["column"], '"validation.exists"'::JSONB);
            END LOOP;
        END IF;
    END LOOP;
    -- UNIQUE constraints
    FOREACH "constraint" IN ARRAY COALESCE("u_constraints", ARRAY []::@extschema@.CONSTRAINT_DEF[]) LOOP
        RAISE DEBUG USING MESSAGE = (concat('def: ', "constraint"."content"));
        RAISE DEBUG USING MESSAGE = (concat('keys: ', "constraint"."keys"));
        RAISE DEBUG USING MESSAGE = (concat('u_cc: ', "u_confirmed_constraints"));
        IF ("v" ?| "constraint"."columns") OR ("constraint" OPERATOR ( @extschema@.@> ) ANY ("u_confirmed_constraints")) THEN
            CONTINUE;
        END IF;
        "res" = @extschema@.unique_rule ("relid", "constraint"."columns", "record", COALESCE("constraint"."where", 'TRUE'));
        IF ("res" IS TRUE) THEN
            "u_confirmed_constraints" = array_append("u_confirmed_constraints", "constraint");
        ELSEIF ("res" IS FALSE) THEN
            FOREACH "column" IN ARRAY "constraint"."columns" LOOP
                "v" = @extschema@.jsonb_array_append ("v", ARRAY["column"], '"validation.unique"'::JSONB);
            END LOOP;
        END IF;
    END LOOP;

    IF ("v" != '{}') THEN
        RAISE EXCEPTION USING ERRCODE = 'data_exception', MESSAGE = "v", SCHEMA = TG_TABLE_SCHEMA, TABLE = TG_TABLE_NAME;
    END IF;

    RETURN NEW;
END
$$
LANGUAGE plpgsql
STABLE;

