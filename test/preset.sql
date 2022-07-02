SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'WARNING'::TEXT, FALSE);

SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'NOTICE'::TEXT, FALSE);

SELECT pg_catalog.set_config('client_min_messages'::TEXT, 'DEBUG'::TEXT, FALSE);

SELECT pg_catalog.current_setting('client_min_messages'::TEXT);

