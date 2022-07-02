CREATE TABLE "public"."customers"
(
    "email" EMAIL PRIMARY KEY
);

CREATE TABLE "public"."posts"
(
    "id"         SERIAL PRIMARY KEY,
    "user_id"    INTEGER  NOT NULL,
    "email"      EMAIL    NOT NULL,
    "nickname"   NICKNAME NOT NULL,
    "rating"     FLOAT,
    "age"        UNSIGNED_INT,
    "title"      TEXT     NOT NULL,
    "text"       TEXT     NOT NULL CHECK ( length("text") > 5 ),
    "deleted_at" TIMESTAMP,
    -- composite foreign keys MATCH FULL and MATCH SIMPLE and duplication ("user_id", "user_id", ...)
    FOREIGN KEY ("user_id", "user_id", "nickname") REFERENCES "public"."users" ("id", "age", "nickname") MATCH FULL ON UPDATE CASCADE,
    FOREIGN KEY ("user_id", "rating") REFERENCES "public"."users" ("id", "rating") MATCH FULL ON UPDATE CASCADE,
    FOREIGN KEY ("user_id", "age") REFERENCES "public"."users" ("id", "age") ON UPDATE CASCADE,
    -- additional foreign keys that do not make sense to check
    FOREIGN KEY ("user_id", "nickname") REFERENCES "public"."users" ("id", "nickname") MATCH FULL ON UPDATE CASCADE,
    FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") MATCH FULL ON UPDATE CASCADE,
    -- two foreign keys per column, but different tables
    FOREIGN KEY ("email") REFERENCES "public"."users" ("email") ON UPDATE CASCADE,
    FOREIGN KEY ("email") REFERENCES "public"."customers" ("email") ON UPDATE CASCADE,
    -- two identical foreign keys
    FOREIGN KEY ("email") REFERENCES "public"."customers" ("email") ON UPDATE CASCADE
);
-- two identical indexes without constraint
CREATE UNIQUE INDEX ON "public"."posts" ("title", "user_id") WHERE "deleted_at" IS NULL;
CREATE UNIQUE INDEX ON "public"."posts" ("title", "user_id") WHERE "public"."posts"."deleted_at" IS NULL;

CREATE TRIGGER "validate"
    BEFORE INSERT OR UPDATE
    ON "public"."posts"
    FOR EACH ROW
EXECUTE FUNCTION trigger_validate();



INSERT INTO "public"."customers"("email")
VALUES ('email@email.em'),
       ('email@email.ema');

INSERT INTO "public"."posts" (id, user_id, email, nickname, rating, age, title, text)
VALUES (1, 1, 'email@email.em', 'nickname', 1, 1, 'title', 'context');

INSERT INTO "public"."posts" (id, user_id, email, nickname, rating, age, title, text)
VALUES (2, 2, 'email@email.ema', 'nickname_', 2, NULL, 'title', 'context');

UPDATE "public"."posts"
SET "email" = 'email@email.ema'
WHERE "id" = 1;
