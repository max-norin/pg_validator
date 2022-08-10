CREATE TABLE "public"."users" (
    "id" SERIAL PRIMARY KEY,
    "email" validator.EMAIL NOT NULL UNIQUE,
    "nickname" validator.NICKNAME NOT NULL UNIQUE,
    "password" VARCHAR(255) NOT NULL,
    "age" validator.UNSIGNED_INT NOT NULL,
    "rating" FLOAT,
    "running_speed" DECIMAL(3, 2) NOT NULL,
    "date_of_birth" DATE NOT NULL,
    "time_of_birth" TIME NOT NULL,
    UNIQUE ("id", "email", "nickname"),
    UNIQUE ("id", "age", "nickname"),
    UNIQUE ("id", "nickname"),
    UNIQUE ("id", "rating"),
    UNIQUE ("id", "age"),
    UNIQUE ("email", "nickname")
);
-- two identical indexes without constraint
CREATE UNIQUE INDEX ON "public"."users" ("email", "age");
CREATE UNIQUE INDEX ON "public"."users" ("email", "age");

CREATE TRIGGER "validate"
    BEFORE INSERT OR UPDATE ON "public"."users"
    FOR EACH ROW
    EXECUTE FUNCTION validator.trigger_validate ();

INSERT INTO "public"."users" ("id", "email", "nickname", "password", "age", "rating", "running_speed", "date_of_birth", "time_of_birth")
    VALUES (1, 'email@email.em', 'nickname', 'password', 1, 1, 1.00, '2022-06-01', '00:00');

INSERT INTO "public"."users" ("id", "email", "nickname", "password", "age", "rating", "running_speed", "date_of_birth", "time_of_birth")
    VALUES (2, 'email@email.ema', 'nickname_', 'password', 2, 2, 2.00, '2022-06-01', '00:00');

UPDATE
    "public"."users"
SET "email" = 'email@email.ema'
WHERE "id" = 1;

