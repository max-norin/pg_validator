CREATE DOMAIN URL AS VARCHAR(255)
    CHECK (@extschema@.url_rule (VALUE));

