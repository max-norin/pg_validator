# pg_validator

> Расширение позволяет проверить данные перед COMMIT и присылает ответ об ошибке в виде из json.
> Данные проверяются на уникальные индексы, уникальные ограничения, внешние ключи. Тип данных не
> проверяется.

## Пример вывода ошибки

```
[22000] ERROR: {"id": ["unique"], "email": ["exists"], "title": ["require"]}
Где: PL/pgSQL function trigger_validate() line 125 at RAISE
```

## Основное

### Установка

Скачайте себе в папку `extension` PostgreSQL файлы из [dist](./dist) и выполните следующую команду.

```postgresql
CREATE EXTENSION "pg_validator"
    SCHEMA "validator"
    VERSION '1.0';
```

### Использование

Чтобы осуществить проверку данных, нужно к таблице добавить триггер `trigger_validate()` из
расширения.

```postgresql
CREATE TRIGGER "validate"
    BEFORE INSERT OR UPDATE
    ON "public"."users"
    FOR EACH ROW
EXECUTE FUNCTION trigger_validate();
```

## Домены

Расширение имеет популярные домены и проверки к ним в виде отдельных функций.

- [alpha](./domains/alpha.sql)
- [email](./domains/email.sql)
- [nickname](./domains/nickname.sql)
- [unsigned_bigint](./domains/unsigned_bigint.sql)
- [unsigned_int](./domains/unsigned_int.sql)
- [url](./domains/url.sql)

```postgresql
-- Пример
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

### Почему тип данных не проверяется?

Базовые типы данных такие как: дата, время, дата и время, ip адрес - проверяются перед запуском
триггеров и проверить их не удаётся. Другой вариант можно сделать на каждую таблицу функцию для
вставки и обновления данных, а таблицу напрямую запретить редактировать. Однако это трудоёмкая
задача для разработков и лишние энергозатраты со стороны сервера базы данных. Поэтому я рекомендую
использовать домены.

### Откуда берутся проверки?

Триггер `trigger_validate()` извлекает данные о всех ограничениях и индексах из информационных
таблиц. Если проверки на ограничения или индексы перекрывают друг друга или подобная проверка уже
была выполнена, то проверки не будет. Подобробно вы можете ознакомиться
самостоятельно [здесь](./validate/validate.sql).

Для проверки работоспособности вы можете воспользоваться тестовыми файлами [здесь](./test/validate).
Для просмотра всех сообщений можно воспользоваться настройкой `client_min_messages`.

```postgresql
-- Уставовка уровня вывода сообщений
SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'WARNING'::TEXT, FALSE);
SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'NOTICE'::TEXT, FALSE);
SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'DEBUG'::TEXT, FALSE);
SELECT pg_catalog.current_setting('client_min_messages'::TEXT);
```

## Файлы

- `helpers/*.sql` - вспомогательные функции
    - [array_is_unique](./helpers/array_is_unique.sql)
    - [array_overlap_count](./helpers/array_overlap_count.sql)
    - [array_unique](./helpers/array_unique.sql)
    - [is_distinct_from](./helpers/is_distinct_from.sql)
    - [jsonb_array_append](./helpers/jsonb_array_append.sql)
    - [jsonb_except](./helpers/jsonb_except.sql)
    - [to_columns](./helpers/to_columns.sql)
- `types/*.sql` - вспомогательные типы
    - [constraint_def](./types/constraint_def) - определение ограничения
    - [set](./types/set) - математическое множество
    - [constraint_type](./types/constraint_type.sql) - `emun('f','u')`
    - [fk_mode](./types/fk_mode.sql) - `emun('full','simple')`
    - [sort_direction](./types/sort_direction.sql) - `emun('ASC','DESC')`
- `rules/*.sql` - популярные правила
    - [alpha](./rules/alpha.sql)
    - [email](./rules/email.sql)
    - [exists](./rules/exists_rule.sql)
    - [nickname](./rules/nickname.sql)
    - [require](./rules/require_rule.sql)
    - [unique](./rules/unique_rule.sql)
    - [url](./rules/url.sql)
- `domains/*.sql` - популярные домены
    - [alpha](./domains/alpha.sql)
    - [email](./domains/email.sql)
    - [nickname](./domains/nickname.sql)
    - [unsigned_bigint](./domains/unsigned_bigint.sql)
    - [unsigned_int](./domains/unsigned_int.sql)
    - [url](./domains/url.sql)
- [validate/validate.sql](./validate/validate.sql) - проверяющий триггер
- [test/*.sql](./test) - тестовые файлы

## Полезное

- [Pseudotypes](https://www.postgresql.org/docs/current/datatype-pseudo.html)
- [Functions with Variable Numbers of Arguments](https://www.postgresql.org/docs/current/xfunc-sql.html#XFUNC-SQL-VARIADIC-FUNCTIONS)
- [Object Identifier Types](https://www.postgresql.org/docs/current/datatype-oid.html#DATATYPE-OID-TABLE)
