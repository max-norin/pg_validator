CREATE FUNCTION to_columns("text" TEXT) RETURNS TEXT[] AS
$$
BEGIN
    RETURN string_to_array(replace("text", ' ', ''), ',');
END;
$$ LANGUAGE plpgsql IMMUTABLE
                    RETURNS NULL ON NULL INPUT;
COMMENT ON FUNCTION to_columns(TEXT) IS 'string of columns to array';


