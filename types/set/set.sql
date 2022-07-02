CREATE DOMAIN "validation".SET AS TEXT[]
    CONSTRAINT "null_check" CHECK ( NOT (NULL::TEXT OPERATOR ("validation".=!=) ANY (VALUE)) )
    CONSTRAINT "unique_check" CHECK ( "validation".array_is_unique(VALUE) );
COMMENT ON DOMAIN "validation".SET IS 'mathematical set';
