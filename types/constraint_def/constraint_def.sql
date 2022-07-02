CREATE TYPE CONSTRAINT_DEF AS (
    "content" TEXT, "name" TEXT, "type" CONSTRAINT_TYPE, "columns" TEXT[], "fk_table" TEXT, "fk_columns" TEXT[], "fk_mode" FK_MODE, "where" TEXT, "keys" SET);

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
        SELECT array_agg(format('%I:%I.%I', "col", "result"."fk_table", "result"."fk_columns"["index"]))::SET INTO "result"."keys"
        FROM unnest("result"."columns")
    WITH ORDINALITY AS "table" ("col", "index");
        RETURN "result";
    END IF;
    RETURN "result";
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

