DROP DOMAIN IF EXISTS "validation".EMAIL;
CREATE DOMAIN "validation".EMAIL AS VARCHAR(255) CHECK ("validation".email(VALUE));
