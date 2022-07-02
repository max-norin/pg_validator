/**
Docs where the regular expression comes from
- [mathiasbynens/url-regex](https://mathiasbynens.be/demo/url-regex) @diegoperini
- [datatracker.ietf.org](https://datatracker.ietf.org/doc/html/rfc3986)
*/

CREATE FUNCTION "validation".url("value" ANYELEMENT) RETURNS BOOLEAN AS
$$
BEGIN
    RETURN ("value" IS NULL) OR ("value" ~* '^(?:(?:https?|ftp):)?//(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4])|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+[a-z\u00a1-\uffff]{2,}\.?)(?::\d{2,5})?(?:[/?#]\S*)?$');
END
$$ LANGUAGE plpgsql IMMUTABLE
                    RETURNS NULL ON NULL INPUT;
