SELECT ARRAY[]::TEXT[] OPERATOR ("pg_catalog".=)
    ARRAY[]::TEXT[];

SELECT ARRAY[]::SET = ARRAY[]::SET;

SELECT ARRAY['a', 'b']::TEXT[] OPERATOR ("pg_catalog".=)
    ARRAY['a', 'b']::TEXT[];

SELECT ARRAY['a', 'b']::SET = ARRAY['a', 'b']::SET;

SELECT ARRAY['b', 'a']::TEXT[] OPERATOR ("pg_catalog".=)
    ARRAY['a', 'b']::TEXT[];

SELECT ARRAY['b', 'a']::SET = ARRAY['a', 'b']::SET;

SELECT ARRAY['b', 'c']::SET = ARRAY['a', 'b']::SET;

SELECT ARRAY['b']::SET = ARRAY['a', 'b']::SET;

