-- all is false
SELECT *
FROM unnest(ARRAY[require_rule (''::VARCHAR), require_rule (' \n \t '::VARCHAR), require_rule (NULL::VARCHAR), require_rule (NULL::INTEGER)]);

