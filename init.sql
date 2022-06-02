/**
  Initial database setup.
 */

CREATE ROLE "validation" LOGIN;
CREATE SCHEMA "validation" AUTHORIZATION "validation";

ALTER ROLE "validation" SET search_path TO "public", "validation";
