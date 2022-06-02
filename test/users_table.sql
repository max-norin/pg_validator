CREATE TABLE public."users"
(
    "id"       SERIAL PRIMARY KEY,
    "email"    VARCHAR(255) NOT NULL UNIQUE, -- TODO add check
    "nickname" VARCHAR(100) NOT NULL UNIQUE CHECK ( "nickname" ~ '^[a-z][a-z0-9_\\.]{4,}$' ),
    "password" VARCHAR(255) NOT NULL
);


CREATE OR REPLACE FUNCTION trigger_users_validate() RETURNS TRIGGER AS
$$
BEGIN
    PERFORM "validation".col_msgses_clear_err(ARRAY [
        ('nickname', ARRAY [
            require_m(NEW."nickname"),
            string_m(NEW."nickname"),
            unique_m((SELECT exists(SELECT *FROM "users" WHERE "nickname" = NEW."nickname") IS FALSE))
            ])::COL_MSGS,
        ('email', ARRAY [
            require_m(NEW."email"),
            string_m(NEW."email"),
            unique_m((SELECT exists(SELECT *FROM "users" WHERE "email" = NEW."email") IS FALSE))
            ])::COL_MSGS,
        ('password', ARRAY [
            require_m(NEW."password"),
            string_m(NEW."password")
            ])::COL_MSGS
        ]);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "valid"
    BEFORE INSERT OR UPDATE
    ON "users"
    FOR EACH ROW
EXECUTE FUNCTION trigger_users_validate();




