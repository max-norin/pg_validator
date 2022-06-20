DROP DOMAIN IF EXISTS "validation".ALPHA;
CREATE DOMAIN "validation".ALPHA AS VARCHAR(255) CHECK ("validation".alpha(VALUE));
