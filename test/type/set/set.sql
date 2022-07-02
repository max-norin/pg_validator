SELECT '{1,2,3}'::SET <@ '{1,3,2,5}'::SET;

SELECT '{1,2,3}'::SET <@ ANY (ARRAY['{1,3,2,5}'::SET, '{4}'::SET]::SET[]);

-- TRUE
SELECT '{4}'::SET <@ ANY (ARRAY['{1,3,2,5}'::SET, '{4}'::SET]::SET[]);

-- TRUE
SELECT '{0}'::SET <@ ANY (ARRAY['{1,3,2,5}'::SET, '{4}'::SET]::SET[]);

-- FALSE
SELECT '{4,5}'::SET <@ ANY (ARRAY['{1,3,2,5}'::SET, '{4}'::SET]::SET[]);

-- FALSE
SELECT NULL::SET;

SELECT ARRAY[NULL]::SET;

