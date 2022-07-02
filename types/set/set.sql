CREATE DOMAIN SET AS TEXT[]
    CONSTRAINT "null_check" CHECK ( NOT (NULL::TEXT OPERATOR (=!=) ANY (VALUE)) )
    CONSTRAINT "unique_check" CHECK ( array_is_unique(VALUE) );
COMMENT ON DOMAIN SET IS 'mathematical set';
