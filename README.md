# pg_validator

> The extension allows you to check the data before COMMIT and sends an error response in the form
> of json. The data is checked for unique indexes, unique constraints, foreign keys. The data type
> is not checked.

[README in Russian](./README.ru.md)

## Error output example

```
[22000] ERROR: {"id": ["unique"], "email": ["exists"], "title": ["require"]}
Context: PL/pgSQL function trigger_validate() line 125 at RAISE
```

## Getting Started

### Install

Download the files from [dist](./dist) to your `extension` folder PostgreSQL and run the following
command.

```postgresql
CREATE EXTENSION "pg_validator"
    SCHEMA "validator"
    VERSION '1.0';
```

[More about the extension and the control file](https://www.postgresql.org/docs/current/extend-extensions.html)

### Usage

To perform the check, you need to add `trigger_validate()` trigger from the extension to the table.

```postgresql
CREATE TRIGGER "validate"
    BEFORE INSERT OR UPDATE
    ON "public"."users"
    FOR EACH ROW
EXECUTE FUNCTION trigger_validate();
```

## Domains

The extension has popular domains and checks them as separate features.

- [alpha](./domains/alpha.sql)
- [email](./domains/email.sql)
- [nickname](./domains/nickname.sql)
- [unsigned_bigint](./domains/unsigned_bigint.sql)
- [unsigned_int](./domains/unsigned_int.sql)
- [url](./domains/url.sql)

```postgresql
-- Example
CREATE TABLE "users"
(
    "id"       SERIAL PRIMARY KEY,
    "email"    EMAIL        NOT NULL UNIQUE,
    "nickname" NICKNAME     NOT NULL UNIQUE,
    "site"     URL          NOT NULL,
    "password" VARCHAR(255) NOT NULL,
    "age"      UNSIGNED_INT NOT NULL
);
```

## FAQ

### Why is the data type not checked?

Basic data types such as date, time, datetime, IP address are validated before triggers run and
cannot be validated. Another option is to make a function to insert and update data in each table
and prevent the table from being edited directly. However, this is a time-consuming task for
developers and unnecessary power consumption on the part of the database server. Therefore, I
recommend using domains.

### Where do checks come from?

`trigger_validate()` trigger retrieves all constraints and indexes from info tables. If constraint
or index checks overlap, or if a similar check has already been performed, then no check will be
made. You can read more about this for yourself [here](./validate/validate.sql).

You can use the test files [here](./test/validate) to see if it works. To view all messages, you can
use the `client_min_messages` setting.

```postgresql
-- Setting the message output level
SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'WARNING'::TEXT, FALSE);
SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'NOTICE'::TEXT, FALSE);
SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'DEBUG'::TEXT, FALSE);
SELECT pg_catalog.current_setting('client_min_messages'::TEXT);
```

## Files

- `helpers/*.sql` - helper functions
    - [array_is_unique](./helpers/array_is_unique.sql)
    - [array_overlap_count](./helpers/array_overlap_count.sql)
    - [array_unique](./helpers/array_unique.sql)
    - [is_distinct_from](./helpers/is_distinct_from.sql)
    - [jsonb_array_append](./helpers/jsonb_array_append.sql)
    - [jsonb_except](./helpers/jsonb_except.sql)
    - [to_columns](./helpers/to_columns.sql)
- `types/*.sql` - helper types
    - [constraint_def](./types/constraint_def) - constraint definition
    - [set](./types/set) - mathematical set
    - [constraint_type](./types/constraint_type.sql) - `emun('f','u')`
    - [fk_mode](./types/fk_mode.sql) - `emun('full','simple')`
    - [sort_direction](./types/sort_direction.sql) - `emun('ASC','DESC')`
- `rules/*.sql` - popular rules
    - [alpha](rules/alpha_rule.sql)
    - [email](rules/email_rule.sql)
    - [exists](./rules/exists_rule.sql)
    - [nickname](rules/nickname_rule.sql)
    - [require](./rules/require_rule.sql)
    - [unique](./rules/unique_rule.sql)
    - [url](rules/url_rule.sql)
- `domains/*.sql` - popular domains
    - [alpha](./domains/alpha.sql)
    - [email](./domains/email.sql)
    - [nickname](./domains/nickname.sql)
    - [unsigned_bigint](./domains/unsigned_bigint.sql)
    - [unsigned_int](./domains/unsigned_int.sql)
    - [url](./domains/url.sql)
- [`validate/validate.sql`](./validate/validate.sql) - validate trigger
- [`test/*.sql`](./test) - test files

## Useful links

- [Pseudotypes](https://www.postgresql.org/docs/current/datatype-pseudo.html)
- [Functions with Variable Numbers of Arguments](https://www.postgresql.org/docs/current/xfunc-sql.html#XFUNC-SQL-VARIADIC-FUNCTIONS)
- [Object Identifier Types](https://www.postgresql.org/docs/current/datatype-oid.html#DATATYPE-OID-TABLE)
