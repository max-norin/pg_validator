CREATE DOMAIN NICKNAME AS VARCHAR(100)
    CHECK (@extschema@.nickname_rule (VALUE));

