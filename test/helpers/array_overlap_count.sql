SELECT '{a,b,c}'::TEXT[] & ? '{a,b}'::TEXT[];

-- 2
SELECT NULL::TEXT[] && NULL::TEXT[];

-- null
SELECT NULL::TEXT[] & ? NULL::TEXT[];

-- null
SELECT ARRAY[NULL]::TEXT[] && ARRAY[NULL]::TEXT[];

-- false
SELECT ARRAY[NULL]::TEXT[] & ? ARRAY[NULL]::TEXT[];

-- 0
