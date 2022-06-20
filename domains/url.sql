DROP DOMAIN IF EXISTS "validation".URL;
CREATE DOMAIN "validation".URL AS VARCHAR(255) CHECK ("validation".url(VALUE));
