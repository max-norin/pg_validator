CREATE TYPE "validation".CONSTRAINT AS
(
    "def"        TEXT,
    "name"       TEXT,
    "type"       "validation".CONSTRAINT_TYPE,
    "columns"    TEXT[],
    "fk_table"   TEXT,
    "fk_columns" TEXT[],
    "fk_mode"    "validation".FK_MODE,
    "where"      TEXT,
    "keys"       "validation".SET
);

CREATE FUNCTION "validation".to_constraint("def" TEXT, "name" TEXT) RETURNS "validation".CONSTRAINT AS
$$
DECLARE
    "result" "validation".CONSTRAINT;
    "match"  TEXT[];
BEGIN
    "result"."def" = "def";
    "result"."name" = "name";

    "match" = regexp_match("def", '(PRIMARY\s+KEY|UNIQUE).*?\((.+?)\).*?(WHERE(.+?))?$', 'i');
    IF "match"[2] IS NOT NULL THEN
        "result"."type" = 'u';
        "result"."columns" = "validation".to_columns("match"[2]);
        "result"."where" = "match"[4];
        "result"."keys" = "result"."columns"::"validation".SET;
        RETURN "result";
    END IF;
    "match" = regexp_match("def", 'FOREIGN\s+KEY\s+\((.+?)\)\s+REFERENCES\s+(.+?)\s*\((.+?)\)\s*(MATCH\s*(SIMPLE|FULL))?', 'i');
    IF "match"[1] IS NOT NULL THEN
        "result"."type" = 'f';
        "result"."columns" = "validation".to_columns("match"[1]);
        "result"."fk_table" = "match"[2];
        "result"."fk_columns" = "validation".to_columns("match"[3]);
        "result"."fk_mode" = COALESCE(lower("match"[5]), 'simple');
        SELECT array_agg(format('%I:%I.%I', "col", "result"."fk_table", "result"."fk_columns"["index"]))::"validation".SET
        INTO "result"."keys"
        FROM unnest("result"."columns") WITH ORDINALITY AS "table"("col", "index");
        RETURN "result";
    END IF;

    RETURN "result";
END ;
$$ LANGUAGE plpgsql IMMUTABLE;
