/**
  Type COL_MSGS.
 */

DROP TYPE IF EXISTS "validation".COL_MSGS;
/**
  Column with messages.
 */
CREATE TYPE "validation".COL_MSGS AS
(
    "col"  TEXT,
    "msgs" TEXT[]
);
COMMENT ON TYPE "validation".COL_MSGS IS 'column with messages';
