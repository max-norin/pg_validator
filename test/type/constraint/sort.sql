SELECT constraint_defs_sort(NULL::CONSTRAINT_DEF[], NULL::SORT_DIRECTION);

SELECT *
FROM unnest(constraint_defs_sort(ARRAY [


                                             ('d', 'n', 'u', '{a,b,c,d}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'f', '{a,b,c,e}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'u', '{a}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'f', '{b}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'f', '{d}', 't', '{c}', 'full', NULL, '{}'),
                                             ('d', 'n', 'f', '{z}', 't', '{c}', 'full', 'w', '{}')
                                             ]::CONSTRAINT_DEF[], NULL::SORT_DIRECTION));

