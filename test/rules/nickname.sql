-- all is false
SELECT *
FROM unnest(ARRAY[nickname ('-account'::VARCHAR), nickname ('_account'::VARCHAR), nickname ('.account'::VARCHAR), nickname ('1account'::VARCHAR), nickname ('acco'::VARCHAR)]);

