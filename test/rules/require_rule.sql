-- all is false
SELECT *
FROM unnest(ARRAY [
    require_rule(''::varchar),
    require_rule(' \n \t '::varchar),
    require_rule(NULL::varchar),
    require_rule(NULL::integer)
    ]);
