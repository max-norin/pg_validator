SELECT array_unique ('{a,a,d,c}'::TEXT[]);

SELECT array_unique (NULL::TEXT[]);

SELECT array_unique (ARRAY[NULL, NULL]::TEXT[]);

