# Альтернативы

- [pg_valid](https://github.com/bitsnap/pg_valid)
- [postgresql-patterns-library](https://github.com/bitsnap/pg_valid)
- [postgres-json-schema](https://github.com/bitsnap/pg_valid)

# Проблема рефлексии

Далее буду ссылаться на проблемы рефлексии в postgresql. Если кратко, то проблема в том, что нужно
использовать `EXECUTE`. Лично мне не нравится использование такого рода методов в программировании -
имею ввиду запуск кода из строки.

Есть тип данных отвечающий за функции с параметрами - `REGPROCEDURE`. Вызвав `SELECT` можно получить
имена функции и удостовериться, что они существуют.

```postgresql
SELECT 'length(TEXT)'::regprocedure, to_regprocedure('length(TEXT)');
```

Про такие типы данных можно прочитать в **8.19. Object Identifier Types**. Однако использовать их
напрямую в выражениях нельзя. Например, ниже запрос с типом отвечающим за таблицы, но запустить
запрос нельзя.

```postgresql
SELECT *
FROM 'users':: regclass; 
```

Для успешного запуска нужно воспользоваться опасным (на мой скромный взгляд) выражением `EXECUTE`.

Ниже пример с `REGCLASS`

```postgresql
CREATE FUNCTION "validation".exec0("table" REGCLASS) RETURNS SETOF RECORD AS
$$
BEGIN
    RETURN QUERY EXECUTE format('SELECT * FROM %I WHERE TRUE;', "table");
END
$$ LANGUAGE plpgsql;
SELECT *
FROM "validation".exec0('users':: REGCLASS) as "t"("id" INTEGER, "email" VARCHAR(255), "nickname" VARCHAR(100), "password" VARCHAR(255));
```

Ниже пример с `REGPROCEDURE`

```postgresql
CREATE FUNCTION "validation".exec1("func" REGPROCEDURE, "text" TEXT) RETURNS SETOF RECORD AS
$$
BEGIN
    RETURN QUERY EXECUTE format(
            'SELECT %I(%L)', substr("func"::TEXT, 0, strpos("func"::TEXT, '('::TEXT)), "text"
        );
END
$$ LANGUAGE plpgsql;
SELECT *
FROM "validation".exec1('length(TEXT)':: REGPROCEDURE, 'Hello'::TEXT) as "t"("result" INTEGER);
```

# Варианты с внешним хранением функций

## Вариант сделать таблицу проверок к `information_schema.columns`

Был вариант сделать таблицу, где хранить список функций для проверок колонки. Подобное решение есть
в альтернативном варианте [pg_valid](https://github.com/bitsnap/pg_valid).

`"table_name"` и `"column_name"` ссылались бы на `information_schema.columns`. `"function"`
определяла функцию для проверки. Проверка осушествлялась бы в триггере, где запускались бы указанные
в этой таблице функции.

```postgresql
CREATE TYPE "validation".validation AS
(
    "table_name"  information_schema.sql_identifier, -- таблица
    "column_name" information_schema.sql_identifier, -- колонка
    "function"    REGPROCEDURE,                      -- функция проверки
    "params"      INT[],                             -- параметры для функции проверки
    "message"     TEXT                               -- сообщение об ошибке
);

SELECT *
FROM information_schema.columns
WHERE table_name = 'users'
  AND table_schema = 'public';
```

Вариант не понравился, т.к. рефлексия postgresql на недостаточном уровне развития.

## Вариант типа данных по мативам [vuelidate](https://vuelidate.js.org/)

Был вариант сделать тип данных для проверки, где `"function"` это функция проверки с
параметрами `(ANYELEMENT, VARIADIC INT[])`, чтобы запускать `"function"("model", "params")` и
записывать значение в `"invalid"` или сделать `"invalid"` генерируемым значением. Проверка
осушествлялась бы триггере.

```postgresql
CREATE TYPE "validation".validation AS
(
    "model"    ANYELEMENT,   -- значение
    "function" REGPROCEDURE, -- функция проверки принимающая "model" и "params"
    "params"   INT[],        -- параметры для функции
    "dirty"    BOOLEAN,      -- была ли осуществленна проверка для "model"
    "invalid"  BOOLEAN,      -- проверка дала отрицательное значение
    "message"  TEXT          -- сообщение об ошибке
);
```

Вариант не понравился, т.к. рефлексия postgresql на недостаточном уровне развития и нельзя создавать
комлексные типы с `ANYELEMENT`.

# Проверка в триггере без внешних таблиц

## Сразу в JSONB

Сразу в триггере формируем сообщения об ошибках, если имеются. Просто, но выглядит громоздко.

```postgresql
CREATE FUNCTION trigger_users_validate() RETURNS TRIGGER AS
$$
DECLARE
    v    JSONB = '{}'; -- переменная для хранения сообщений
    msgs TEXT[];
BEGIN
    -- формируем массив с сообщениями не NULL
    msgs = array_remove(ARRAY [
                            require(NEW."email") | 'require',
                            string(NEW."email") | 'string'
                            ], NULL);
    -- проверяем есть ли сообщения
    IF array_length(msgs, 1) > 0 THEN
        v = jsonb_set(v, '{email}'::TEXT[], to_jsonb(msgs));
    END IF;

    -- формируем массив с сообщениями не NULL
    msgs = array_remove(ARRAY [
                            require(NEW."nickname") | 'require',
                            string(NEW."nickname") | 'string'
                            ], NULL);
    -- проверяем есть ли сообщения
    IF array_length(msgs, 1) > 0 THEN
        v = jsonb_set(v, '{nickname}'::TEXT[], to_jsonb(msgs));
    END IF;

    IF (v != '{}') THEN
        RAISE EXCEPTION USING ERRCODE = 'data_exception', MESSAGE = jsonb_pretty(v);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Транспонированная матрица

Для работы потребовалось установить
расширение [tablefunc](https://www.postgresql.org/docs/current/tablefunc.html)

```postgresql
CREATE EXTENSION IF NOT EXISTS tablefunc;
```

Идея была иметь таблицу с сообщениями, где название колонок это наименование заполняемых полей.

```postgresql
SELECT ARRAY ["validation".to_require(''::varchar(255))]        AS email,
       ARRAY ["validation".to_require('7@j.com'::varchar(255))] AS password;
```

Но потом опять плохие новости, что crosstab (функция транспонирования) приниматет в качестве
аргументов строку с запросом, а не сам запрос.

## Агрегатный вариант

Думал сделать на основе агрегатной функции jsonb_object_agg и использовать её функции:

- jsonb_object_agg_transfn
- jsonb_object_agg_finalfn

```postgresql
SELECT pg_get_function_arguments('jsonb_object_agg_transfn'::regproc);
SELECT pg_get_function_result('jsonb_object_agg_transfn'::regproc);
SELECT pg_get_function_arguments('jsonb_object_agg_finalfn'::regproc);
SELECT pg_get_function_result('jsonb_object_agg_finalfn'::regproc);
```

Но из-за использования в них типа internal пришлось писать свои.

```postgresql
CREATE FUNCTION "validation".col_msgses_err_agg_transfn("v" jsonb, "col" text, "msgs" text[]) RETURNS jsonb AS
$$
BEGIN
    "msgs" = "validation".array_remove("msgs", NULL);
    IF array_length("msgs", 1) > 0 THEN
        RETURN jsonb_set("v", ARRAY ["col"], to_jsonb("msgs"));
    END IF;

    RETURN "v";
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION "validation".col_msgses_err_agg_finalfn("v" jsonb) RETURNS void AS
$$
BEGIN
    IF ("v" != '{}') THEN
        RAISE EXCEPTION USING ERRCODE = 'data_exception', MESSAGE = ("v");
    END IF;
END
$$ LANGUAGE plpgsql;

CREATE AGGREGATE "validation".col_msgses_err_agg(text, text[]) (
    SFUNC = "validation".col_msgses_err_agg_transfn,
    STYPE = jsonb,
    INITCOND = '{}',
    FINALFUNC = "validation".col_msgses_err_agg_finalfn
    );
```

В последствии этот способ мне показался логически неправильным, т.к. по сути не все параметры
передаваемые в функцию перехода в конечном итоге попадают в финальную фунцию. Вариант имеет место
быть, но мне лично не нравится.

## Конечный вариант

Исходя из неудачных экспериметов делаю вывод, что лучше сделать тип данных `"COL_MSGS""`, который
будет содержать колонку и сообщения об ошибках. / определение в файле `col_msgs/col_msgs.sql`
