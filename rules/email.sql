/**
Docs where the regular expression comes from
- [github.com/gregseth/email-regex.md](https://gist.github.com/gregseth/5582254)
- [datatracker.ietf.org](https://datatracker.ietf.org/doc/html/rfc2822#section-3.4.1)
- [regular-expressions.info](https://www.regular-expressions.info/email.html)
- [emailregex](https://emailregex.com/)
*/

CREATE OR REPLACE FUNCTION "validation".email("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("value" IS NULL) OR ("value" ~* '^(?:[a-z0-9!#$%&''*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&''*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$');
END
$$ LANGUAGE plpgsql;
