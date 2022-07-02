SELECT "validation".array_unique('{a,a,d,c}'::TEXT[]);
SELECT "validation".array_unique(NULL::TEXT[]);
SELECT "validation".array_unique(ARRAY [NULL,NULL]::TEXT[]);

