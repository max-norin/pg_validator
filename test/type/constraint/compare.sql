SELECT ARRAY ['a']::TEXT[] <@ ARRAY ['a','b']::TEXT[];
SELECT ARRAY ['a']::TEXT[] @> ARRAY ['a','b']::TEXT[];


SELECT ('d', 'n', 'f', '{z}', 't', '{c}', 'full', '2', ARRAY [4, 3])::"validation".CONSTRAINT = ANY (
    ARRAY [
        ('d', 'n', 'f', '{z}', 't', '{c}', 'full', '2', ARRAY [3, 4])
        ]::"validation".CONSTRAINT[]
    );
