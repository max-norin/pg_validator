SELECT "validation".exists(
               'users',
               ARRAY ['id','email'],
               '{
                   "id": 1,
                   "email": "email@email.em",
                   "nickname": "nickname"
               }',
               ARRAY ['id','email'],
               'full',
               NULL);


SELECT "validation".exists(
               'users',
               NULL,
               '{
                   "id": 1,
                   "email": "email@email.em",
                   "nickname": "nickname"
               }',
               NULL,
               'full',
               NULL::TEXT);
