/*
This Package is used for updating airport data
*/
CREATE OR REPLACE PACKAGE airport_updating_pkg AS
  PROCEDURE update_airport(
    a_airport_id       IN NUMBER,
    a_airport_name     IN VARCHAR2,
    a_city             IN VARCHAR2,
    a_state            IN VARCHAR2,
    a_country          IN VARCHAR2
  );
END airport_updating_pkg;
/

CREATE OR REPLACE PACKAGE BODY airport_updating_pkg AS
PROCEDURE update_airport(
    a_airport_id       IN NUMBER,
    a_airport_name     IN VARCHAR2,
    a_city             IN VARCHAR2,
    a_state            IN VARCHAR2,
    a_country          IN VARCHAR2
  ) IS
  k_count NUMBER; 
  BEGIN
    IF a_airport_id IS NULL THEN
      -- Prompt user to enter airport ID
      dbms_output.put('Please enter the airport ID: ');
      Return;
    ELSIF a_airport_name IS NULL OR a_city IS NULL OR a_state IS NULL OR a_country IS NULL THEN
      dbms_output.put('All input parameters must be specified');
      Return;      

    -- Regex validations
    
    -- Validate airport name input
    ELSIF REGEXP_LIKE(a_airport_name, '^[a-zA-Z ]*$') = FALSE THEN
      dbms_output.put('Only alphabets and spaces are allowed');
    Return;
    
    -- Validate city input
    ELSIF REGEXP_LIKE(a_city, '^[a-zA-Z ]*$') = FALSE THEN
      dbms_output.put('Only alphabets and spaces are allowed');
    Return;
    
    -- Validate state input
    ELSIF REGEXP_LIKE(a_state, '^[a-zA-Z ]*$') = FALSE THEN
      dbms_output.put('Only alphabets and spaces are allowed');
    Return;
    
    -- Validate country input
    ELSIF REGEXP_LIKE(a_country, '^[a-zA-Z ]*$') = FALSE THEN
      dbms_output.put('Only alphabets and spaces are allowed');
    Return;
    
    END IF; 
    
    SELECT COUNT(*) INTO k_count FROM AIRPORT WHERE airport_id = a_airport_id;
    
    IF k_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('No airport found with the given ID');
      RETURN;
    END IF;

    BEGIN
      UPDATE AIRPORT
      SET
        airport_name = a_airport_name,
        city = a_city,
        state = a_state,
        country = a_country
      WHERE
        airport_id = a_airport_id;
      commit;  
      DBMS_OUTPUT.PUT_LINE('Data Successfully Updated');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No airport found with the given ID');
        RETURN;
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred while updating the airport: ' || SQLERRM);      
        RETURN;
    END;

  END update_airport;
END airport_updating_pkg;
/

SHOW ERRORS;