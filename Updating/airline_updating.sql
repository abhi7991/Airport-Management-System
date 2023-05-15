CREATE OR REPLACE PACKAGE update_airline_pkg IS

  PROCEDURE update_airline_name(
    airline_id_in IN NUMBER,
    airline_name_in IN VARCHAR2
  );

END update_airline_pkg;
/

CREATE OR REPLACE PACKAGE BODY update_airline_pkg AS
  PROCEDURE update_airline_name(
    airline_id_in IN NUMBER,
    airline_name_in IN VARCHAR2
  ) IS 
    -- Validation for checking if airline_name_in is not null
    if_airline_name_not_null EXCEPTION;
    -- Validation for checking if airline_name_in contains only alphabetical characters
    if_airline_name_not_alpha EXCEPTION;
  BEGIN
    -- Check if airline_name_in is null
    IF airline_id_in IS NULL THEN
      RAISE if_airline_name_not_null;
    END IF;
    IF airline_name_in IS NULL THEN
      RAISE if_airline_name_not_null;
    END IF;
    -- Check if airline_name_in contains only alphabetical characters
    FOR i IN 1..LENGTH(airline_name_in) LOOP
      IF NOT REGEXP_LIKE(SUBSTR(airline_name_in,i,1), '\b[A-Z]{2}\b|\b[A-Z][a-z]+(?: [A-Z][a-z]*)*
') THEN
        RAISE if_airline_name_not_alpha;
      END IF;
    END LOOP;

    -- Update airline name and commit the transaction
    UPDATE airlines
    SET airline_name = airline_name_in
    WHERE airline_id = airline_id_in;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Airline name updated successfully.');
    
  EXCEPTION
    -- Handle exceptions for validations
    WHEN if_airline_name_not_null THEN
      DBMS_OUTPUT.PUT_LINE('Airline id or name cannot be null.');
    WHEN if_airline_name_not_alpha THEN
      DBMS_OUTPUT.PUT_LINE('Airline name can contain only alphabetical characters.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occcured while updating airline.');
        ROLLBACK;
  END update_airline_name;

END update_airline_pkg;
/
