/*
=================== ARRAY_IS_UNIQUE =================== 
*/
CREATE FUNCTION array_is_unique ("arr" ANYARRAY)
    RETURNS BOOLEAN
    AS $$
DECLARE
    "length" CONSTANT INT = array_length("arr", 1);
    "index" INT;
BEGIN
    "index" = 1;
    WHILE "index" < "length" LOOP
        IF array_position("arr", "arr"["index"], "index" + 1) IS NOT NULL THEN
            RETURN FALSE;
        END IF;
        "index" = "index" + 1;
    END LOOP;
    RETURN TRUE;
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

COMMENT ON FUNCTION array_is_unique (ANYARRAY) IS 'checks array for duplicate elements';

/*
=================== ARRAY_OVERLAP_COUNT =================== 
*/
CREATE FUNCTION array_overlap_count ("a" ANYARRAY, "b" ANYARRAY)
    RETURNS INT
    AS $$
DECLARE
    "length" CONSTANT INT = array_length("a", 1);
    "index" INT;
    "result" INT = 0;
BEGIN
    "index" = 1;
    WHILE "index" <= "length" LOOP
        IF ("a"["index"] IS NOT NULL) AND (array_position("b", "a"["index"]) IS NOT NULL) THEN
            "result" = "result" + 1;
        END IF;
        "index" = "index" + 1;
    END LOOP;
    RETURN "result";
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

COMMENT ON FUNCTION array_overlap_count (ANYARRAY, ANYARRAY) IS 'overlap count';

CREATE OPERATOR &? (
    LEFTARG = ANYARRAY, RIGHTARG = ANYARRAY, FUNCTION = array_overlap_count
);

COMMENT ON OPERATOR &? (ANYARRAY, ANYARRAY) IS 'overlap count';

/*
=================== ARRAY_UNIQUE =================== 
*/
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

/*
=================== IS_DISTINCT_FROM =================== 
*/
CREATE FUNCTION is_not_distinct_from ("a" ANYELEMENT, "b" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN "a" IS NOT DISTINCT FROM "b";
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION is_not_distinct_from (ANYELEMENT, ANYELEMENT) IS '$1 IS NOT DISTINCT FROM $2';

CREATE OPERATOR =!= (
    LEFTARG = ANYELEMENT, RIGHTARG = ANYELEMENT, NEGATOR = <!>, RESTRICT = eqsel, FUNCTION = is_not_distinct_from
);

COMMENT ON OPERATOR =!= (ANYELEMENT, ANYELEMENT) IS '$1 IS NOT DISTINCT FROM $2';

CREATE FUNCTION is_distinct_from ("a" ANYELEMENT, "b" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN "a" IS DISTINCT FROM "b";
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION is_distinct_from (ANYELEMENT, ANYELEMENT) IS '$1 IS DISTINCT FROM $2';

CREATE OPERATOR <!> (
    LEFTARG = ANYELEMENT, RIGHTARG = ANYELEMENT, NEGATOR = =!=, RESTRICT = neqsel, FUNCTION = is_distinct_from
);

COMMENT ON OPERATOR <!> (ANYELEMENT, ANYELEMENT) IS '$1 IS DISTINCT FROM $2';

/*
=================== JSONB_ARRAY_APPEND =================== 
*/
CREATE FUNCTION jsonb_array_append ("json" JSONB, "path" TEXT[], "value" JSONB)
    RETURNS JSONB
    AS $$
BEGIN
    RETURN jsonb_set("json", "path", COALESCE("json" #> "path", '[]'::JSONB) || "value");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION jsonb_array_append (JSONB, TEXT[], JSONB) IS 'insert "value" into array along "path"';

/*
=================== JSONB_EXCEPT =================== 
*/
CREATE FUNCTION jsonb_except ("a" JSONB, "b" JSONB)
    RETURNS JSONB
    AS $$
BEGIN
    RETURN (
        SELECT jsonb_object_agg(key, value)
        FROM (
            SELECT "key", "value"
            FROM jsonb_each_text("a")
            EXCEPT
            SELECT "key", "value"
            FROM jsonb_each_text("b")
            ) "table" ("key", "value"));
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION jsonb_except (JSONB, JSONB) IS '$1 EXCEPT $2';

CREATE OPERATOR - (
    LEFTARG = JSONB, RIGHTARG = JSONB, FUNCTION = jsonb_except
);

COMMENT ON OPERATOR - (JSONB, JSONB) IS '$1 EXCEPT $2';

/*
=================== TO_COLUMNS =================== 
*/
CREATE FUNCTION to_columns ("text" TEXT)
    RETURNS TEXT[]
    AS $$
BEGIN
    RETURN string_to_array(replace("text", ' ', ''), ',');
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

COMMENT ON FUNCTION to_columns (TEXT) IS 'string of columns to array';

/*
=================== CONSTRAINT_TYPE =================== 
*/
CREATE TYPE CONSTRAINT_TYPE AS ENUM (
    'u', 'f'
);

/*
=================== FK_MODE =================== 
*/
CREATE TYPE FK_MODE AS ENUM (
    'full', 'simple'
);

COMMENT ON TYPE FK_MODE IS 'foreign key mode';

/*
=================== SORT_DIRECTION =================== 
*/
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

/*
=================== SET =================== 
*/
CREATE DOMAIN SET AS TEXT[]
    CONSTRAINT "null_check" CHECK (NOT (NULL::TEXT =!= ANY (VALUE)))
    CONSTRAINT "unique_check" CHECK (array_is_unique (VALUE));

COMMENT ON DOMAIN SET IS 'mathematical set';

/*
=================== COMPARE =================== 
*/
CREATE FUNCTION set_eq ("a" SET, "b" SET)
    RETURNS BOOLEAN
    AS $$
DECLARE
    "length" CONSTANT INT = array_length("a", 1);
    "index" INT;
BEGIN
    IF ("length" != array_length("b", 1)) THEN
        RETURN FALSE;
    END IF;
    "index" = 1;
    WHILE "index" <= "length" LOOP
        -- = because SET element cannot be NULL
        IF NOT ("a"["index"] = ANY ("b")) THEN
            RETURN FALSE;
        END IF;
        "index" = "index" + 1;
    END LOOP;
    RETURN TRUE;
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

COMMENT ON FUNCTION set_eq (SET, SET) IS 'comparison of sets for equality';

CREATE OPERATOR = (
    LEFTARG = SET, RIGHTARG = SET, NEGATOR = !=, RESTRICT = eqsel, FUNCTION = set_eq
);

COMMENT ON OPERATOR = (SET, SET) IS 'comparison of sets for equality';

CREATE FUNCTION set_neq ("a" SET, "b" SET)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN NOT set_eq ("a", "b");
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

COMMENT ON FUNCTION set_eq (SET, SET) IS 'comparison of sets for not equality';

CREATE OPERATOR != (
    LEFTARG = SET, RIGHTARG = SET, NEGATOR = =, RESTRICT = neqsel, FUNCTION = set_neq
);

COMMENT ON OPERATOR != (SET, SET) IS 'comparison of sets for not equality';

/*
=================== CONSTRAINT_DEF =================== 
*/
CREATE TYPE CONSTRAINT_DEF AS (
    "content" TEXT,
    "name" TEXT,
    "type" CONSTRAINT_TYPE,
    "columns" TEXT[],
    "fk_table" TEXT,
    "fk_columns" TEXT[],
    "fk_mode" FK_MODE,
    "where" TEXT,
    "keys" SET
);

CREATE FUNCTION to_constraint_def ("content" TEXT, "name" TEXT)
    RETURNS CONSTRAINT_DEF
    AS $$
DECLARE
    "result" CONSTRAINT_DEF;
    "match" TEXT[];
BEGIN
    "result"."content" = "content";
    "result"."name" = "name";
    "match" = regexp_match("content", '(PRIMARY\s+KEY|UNIQUE).*?\((.+?)\).*?(WHERE(.+?))?$', 'i');
    IF "match"[2] IS NOT NULL THEN
        "result"."type" = 'u';
        "result"."columns" = to_columns ("match"[2]);
        "result"."where" = "match"[4];
        "result"."keys" = "result"."columns"::SET;
        RETURN "result";
    END IF;
    "match" = regexp_match("content", 'FOREIGN\s+KEY\s+\((.+?)\)\s+REFERENCES\s+(.+?)\s*\((.+?)\)\s*(MATCH\s*(SIMPLE|FULL))?', 'i');
    IF "match"[1] IS NOT NULL THEN
        "result"."type" = 'f';
        "result"."columns" = to_columns ("match"[1]);
        "result"."fk_table" = "match"[2];
        "result"."fk_columns" = to_columns ("match"[3]);
        "result"."fk_mode" = COALESCE(lower("match"[5]), 'simple');
        SELECT array_agg(format('%I:%I.%I', "col", "result"."fk_table", "result"."fk_columns"["index"]))::SET
        INTO "result"."keys"
        FROM unnest("result"."columns") WITH ORDINALITY AS "table" ("col", "index");
        RETURN "result";
    END IF;
    RETURN "result";
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

/*
=================== COMPARE =================== 
*/
CREATE FUNCTION constraint_def_eq ("a" CONSTRAINT_DEF, "b" CONSTRAINT_DEF)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("a"."where" = != "b"."where") AND ("a"."keys" = "b"."keys");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

CREATE OPERATOR = (
    LEFTARG = CONSTRAINT_DEF, RIGHTARG = CONSTRAINT_DEF, NEGATOR = !=, RESTRICT = eqsel, FUNCTION = constraint_def_eq
);

CREATE FUNCTION constraint_def_neq ("a" CONSTRAINT_DEF, "b" CONSTRAINT_DEF)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN NOT constraint_def_eq ("a", "b");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

CREATE OPERATOR != (
    LEFTARG = CONSTRAINT_DEF, RIGHTARG = CONSTRAINT_DEF, NEGATOR = =, RESTRICT = neqsel, FUNCTION = constraint_def_neq
);

CREATE FUNCTION constraint_def_contained ("a" CONSTRAINT_DEF, "b" CONSTRAINT_DEF)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("a"."where" = != "b"."where") AND ("a"."keys" <@ "b"."keys");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION constraint_def_contained (CONSTRAINT_DEF, CONSTRAINT_DEF) IS 'is contained by';

CREATE OPERATOR <@ (
    LEFTARG = CONSTRAINT_DEF, RIGHTARG = CONSTRAINT_DEF, COMMUTATOR = @>, RESTRICT = arraycontsel, FUNCTION = constraint_def_contained
);

COMMENT ON OPERATOR <@ (CONSTRAINT_DEF, CONSTRAINT_DEF) IS 'is contained by';

CREATE FUNCTION constraint_def_contains ("a" CONSTRAINT_DEF, "b" CONSTRAINT_DEF)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("a"."where" = != "b"."where") AND ("a"."keys" @> "b"."keys");
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION constraint_def_contains (CONSTRAINT_DEF, CONSTRAINT_DEF) IS 'contains';

CREATE OPERATOR @> (
    LEFTARG = CONSTRAINT_DEF, RIGHTARG = CONSTRAINT_DEF, COMMUTATOR = <@, RESTRICT = arraycontsel, FUNCTION = constraint_def_contains
);

COMMENT ON OPERATOR @> (CONSTRAINT_DEF, CONSTRAINT_DEF) IS 'contains';

/*
=================== SORT =================== 
*/
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
        ORDER BY (CASE WHEN "table"."where" IS NULL THEN 1 ELSE -1 END) * "direction"::INTEGER,
                 ("table"."columns" &? "weighty_columns") * "direction"::INTEGER
)
    SELECT array_agg("table".*)
    INTO "constraints"
FROM "table";
    RETURN "constraints";
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

COMMENT ON FUNCTION constraint_defs_sort (CONSTRAINT_DEF[], SORT_DIRECTION) IS 'sort constraints on frequency of used "columns" without "where"';

/*
=================== ALPHA =================== 
*/
CREATE FUNCTION alpha ("value" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("value" ~* '^[a-zA-Z]*$');
END
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

/*
=================== EMAIL =================== 
*/
/**
Docs where the regular expression comes from
- [github.com/gregseth/email-regex.md](https://gist.github.com/gregseth/5582254)
- [datatracker.ietf.org](https://datatracker.ietf.org/doc/html/rfc2822#section-3.4.1)
- [regular-expressions.info](https://www.regular-expressions.info/email.html)
- [emailregex](https://emailregex.com/)
 */
CREATE FUNCTION email ("value" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("value" ~* '^(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$');
END
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

/*
=================== EXISTS_RULE =================== 
*/
CREATE FUNCTION exists_rule ("schema_table" TEXT, "table_columns" TEXT[], "record" JSONB, "record_columns" TEXT[], "mode" FK_MODE = 'full', "where" TEXT = NULL)
    RETURNS BOOLEAN
    AS $$
DECLARE
    "has_null" CONSTANT BOOLEAN = ("record" ->> "record_columns"[1]) IS NULL;
    "is_null" BOOLEAN;
    "index" INT;
    "length" CONSTANT INT = array_length("table_columns", 1);
    "values" TEXT[] = '{}';
    "sql" TEXT;
    "result" BOOLEAN = FALSE;
BEGIN
    IF ("length" IS NULL) OR ("length" <!> array_length("record_columns", 1)) THEN
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
    "sql" = format('SELECT exists( SELECT * FROM %s WHERE (%s)=(%s) AND %s);', "schema_table", array_to_string("table_columns", ','), array_to_string("values", ','), COALESCE("where", 'TRUE'));
    RAISE INFO USING MESSAGE = (concat('sql: ', "sql"));
    EXECUTE "sql" INTO "result";
    RETURN "result";
END;
$$
LANGUAGE plpgsql
STABLE;

/*
=================== NICKNAME =================== 
*/
CREATE FUNCTION nickname ("value" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("value" ~ '^[a-z][a-z0-9_\\.]{4,}$');
END
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

/*
=================== REQUIRE_RULE =================== 
*/
CREATE FUNCTION require_rule ("value" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("value" IS NOT NULL);
END
$$
LANGUAGE plpgsql
IMMUTABLE;

CREATE FUNCTION require_rule ("value" TEXT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("value" IS NOT NULL)
        AND (length(trim(' \t\n' FROM "value")) > 0);
END
$$
LANGUAGE plpgsql
IMMUTABLE;

/*
=================== UNIQUE_RULE =================== 
*/
CREATE FUNCTION unique_rule ("schema_table" TEXT, "columns" TEXT[], "record" JSONB, "where" TEXT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN exists_rule ("schema_table", "columns", "record", "columns", 'simple', "where") IS FALSE;
END;
$$
LANGUAGE plpgsql
STABLE;

/*
=================== URL =================== 
*/
/**
Docs where the regular expression comes from
- [mathiasbynens/url-regex](https://mathiasbynens.be/demo/url-regex) @diegoperini
- [datatracker.ietf.org](https://datatracker.ietf.org/doc/html/rfc3986)
 */
CREATE FUNCTION url ("value" ANYELEMENT)
    RETURNS BOOLEAN
    AS $$
BEGIN
    RETURN ("value" ~* '^(?:(?:https?|ftp):)?//(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4])|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+[a-z\u00a1-\uffff]{2,}\.?)(?::\d{2,5})?(?:[/?#]\S*)?$');
END
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

/*
=================== ALPHA =================== 
*/
CREATE DOMAIN ALPHA AS VARCHAR(255)
    CHECK (alpha (VALUE));

/*
=================== EMAIL =================== 
*/
CREATE DOMAIN EMAIL AS VARCHAR(255)
    CHECK (email (VALUE));

/*
=================== NICKNAME =================== 
*/
CREATE DOMAIN NICKNAME AS VARCHAR(100)
    CHECK (nickname (VALUE));

/*
=================== UNSIGNED_BIGINT =================== 
*/
CREATE DOMAIN UNSIGNED_BIGINT AS BIGINT
    CHECK (VALUE >= 0);

/*
=================== UNSIGNED_INT =================== 
*/
CREATE DOMAIN UNSIGNED_INT AS INTEGER
    CHECK (VALUE >= 0);

/*
=================== URL =================== 
*/
CREATE DOMAIN URL AS VARCHAR(255)
    CHECK (url (VALUE));

/*
=================== VALIDATE =================== 
*/
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

