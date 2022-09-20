CREATE DOMAIN EMAIL AS VARCHAR(255)
    CHECK (@extschema@.email_rule (VALUE));

