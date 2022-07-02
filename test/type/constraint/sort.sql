SELECT "validation".constraints_sort(NULL::"validation".CONSTRAINT[], NULL::SORT_DIRECTION);

SELECT *
FROM unnest("validation".constraints_sort(ARRAY [


                                             ('d', 'n', 'u', '{a,b,c,d}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'f', '{a,b,c,e}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'u', '{a}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'f', '{b}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'f', '{d}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'f', '{z}', 't', '{c}', 'full', 'w', '{}')
                                             ]::"validation".CONSTRAINT[], NULL::SORT_DIRECTION));

