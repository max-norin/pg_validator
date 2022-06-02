# Использование

```postgresql
CREATE TABLE "users"
(
    -- TODO
);
```

# Что в файлах

## `init.sql `

- создается пользователь validation
  / [doc](https://www.postgresql.org/docs/current/sql-createrole.html)
- создается схема validation, принадлежащая вышеуказанному пользователю
  / [doc](https://www.postgresql.org/docs/current/sql-createschema.html)
- добавляется в search_path пользователя validation схема validation
  / [doc](https://www.postgresql.org/docs/current/ddl-schemas.html)

## `helpers.sql`

- создается функция для работы с правилами - если результат отрицательный, то возвращается сообщение
- создается оператор для краткой записи функции указанной выше

## `col_msgs/failed_attempts.sql`

Неудачные попытки создать функции проверки

## `col_msgs/col_msgs.sql`

создается тип COL_MSGS - колонка с сообщениями

## `validate/col_msgses_clear.sql`

Фунция отчистки массива типа COL_MSGS от пустых сообщений

## `rules/*.sql`

Популярные правила:

- require
- string
- alpha
- integer
- numeric

- min_length
- max_length
- min_value
- max_value
- between

- email
- url

## `domains/*.sql`

Популярные домены:

- alpha
- numeric
- email
- url
- nickname

## `test/*.sql`

Тестовые файлы

# Полезное

- [Pseudotypes](https://www.postgresql.org/docs/current/datatype-pseudo.html)
- internal использовать можно только в функциях на C
- [Functions with Variable Numbers of Arguments](https://www.postgresql.org/docs/current/xfunc-sql.html#XFUNC-SQL-VARIADIC-FUNCTIONS)
- [Object Identifier Types](https://www.postgresql.org/docs/current/datatype-oid.html#DATATYPE-OID-TABLE)
