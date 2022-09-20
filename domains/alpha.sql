CREATE DOMAIN ALPHA AS VARCHAR(255)
    CHECK (@extschema@.alpha_rule (VALUE));

