-- all is false
SELECT *
FROM unnest(ARRAY [
    "validation".require(''::varchar),
    "validation".require(' \n \t '::varchar),
    "validation".require(NULL::varchar),
    "validation".require(NULL::integer)
    ]);
