CREATE TABLE public."customers"
(
    "email" EMAIL PRIMARY KEY
);

CREATE TABLE public."posts"
(
    "id"         SERIAL PRIMARY KEY,
    "user_id"    INTEGER  NOT NULL,
    "email"      EMAIL    NOT NULL,
    "nickname"   NICKNAME NOT NULL,
    "rating"     FLOAT,
    "title"      TEXT     NOT NULL,
    "text"       TEXT     NOT NULL CHECK ( length("text") > 5 ),
    "deleted_at" TIMESTAMP,
    -- составныее внешние ключи MATCH FULL и MATCH SIMPLE
    FOREIGN KEY ("user_id", "user_id", "nickname") REFERENCES public."users" ("id", "age", "nickname") MATCH FULL ON UPDATE CASCADE,
    FOREIGN KEY ("user_id", "rating") REFERENCES public."users" ("id", "rating") ON UPDATE CASCADE,
    -- дополнительные которые проверять нет смысла
    FOREIGN KEY ("user_id", "nickname") REFERENCES public."users" ("id", "nickname") MATCH FULL ON UPDATE CASCADE,
    FOREIGN KEY ("user_id") REFERENCES public."users" ("id") MATCH FULL ON UPDATE CASCADE,
    -- два внешних ключа на одну колонку, но разные таблицы
    FOREIGN KEY ("email") REFERENCES public."users" ("email") ON UPDATE CASCADE,
    FOREIGN KEY ("email") REFERENCES public."customers" ("email") ON UPDATE CASCADE,
    -- два одинаковых внешних ключа
    FOREIGN KEY ("email") REFERENCES public."customers" ("email") ON UPDATE CASCADE
);
-- два одинаковых индекса без constraint
CREATE UNIQUE INDEX ON public."posts" ("title", "user_id") WHERE "deleted_at" IS NULL;
CREATE UNIQUE INDEX ON public."posts" ("title", "user_id") WHERE "posts"."deleted_at" IS NULL;

CREATE TRIGGER "validate"
    BEFORE INSERT OR
        UPDATE
    ON "posts"
    FOR EACH ROW
EXECUTE FUNCTION "validation".trigger_validate();

INSERT INTO "customers"("email")
VALUES ('email@email.em'),
       ('email@email.ema');

INSERT INTO "posts" (id, user_id, email, nickname, rating, title, text)
VALUES (DEFAULT, 1, 'email@email.em', 'nickname', 1, 'sdf', 'dasdasd');


UPDATE "public"."posts"
SET "_email" = 'email@email.em5'
WHERE "id" = 1;

-- TODO сделать  MATCH FULL c NULL
