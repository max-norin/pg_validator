/**
  Helper functions.
 */

/**
  Return message if result is false.
 */
CREATE OR REPLACE FUNCTION "validation".or_message("result" BOOLEAN, "message" TEXT) RETURNS TEXT AS
$$
BEGIN
    IF ("result" IS TRUE) THEN
        RETURN NULL;
    END IF;

    RETURN "message";
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION "validation".or_message(BOOLEAN, TEXT) IS 'if result is false then return message';

DROP OPERATOR IF EXISTS "validation".|(BOOLEAN, TEXT);
/**
  Shorthand for or_message(BOOLEAN, TEXT) function.
 */
CREATE OPERATOR "validation".| (
    LEFTARG = BOOLEAN,
    RIGHTARG = TEXT,
    FUNCTION = "validation".or_message
    );
COMMENT ON OPERATOR "validation".|(BOOLEAN, TEXT) IS 'if LEFTARG is false then return message from RIGHTARG';

