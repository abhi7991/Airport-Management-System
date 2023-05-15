/*
This Package is used for inserting Airport data
*/
CREATE OR REPLACE PACKAGE airport_pkg AS  
  PROCEDURE insert_airport(
    a_airport_name     IN VARCHAR2,
    a_city             IN VARCHAR2,
    a_state            IN VARCHAR2,
    a_country          IN VARCHAR2
  );
END airport_pkg;
/

CREATE OR REPLACE PACKAGE BODY airport_pkg AS
PROCEDURE insert_airport(
    a_airport_name     IN VARCHAR2,
    a_city             IN VARCHAR2,
    a_state            IN VARCHAR2,
    a_country          IN VARCHAR2
  ) IS
  BEGIN
    IF a_airport_name IS NULL OR a_city IS NULL OR a_state IS NULL OR a_country IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('All input parameters must be specified');
      RETURN;
    END IF;  
    
    -- Regex validations
    
    -- Validate airport name input
    IF REGEXP_LIKE(a_airport_name, '^[a-zA-Z ]*$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Only alphabets and spaces are allowed');
      RETURN;
    END IF;
    
    -- Validate city input
    IF REGEXP_LIKE(a_city, '^[a-zA-Z ]*$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Only alphabets and spaces are allowed');
      RETURN;
    END IF;
    
    -- Validate state input
    IF REGEXP_LIKE(a_state, '^[a-zA-Z ]*$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Only alphabets and spaces are allowed');
      RETURN;
    END IF;
    
    -- Validate country input
    IF REGEXP_LIKE(a_country, '^[a-zA-Z ]*$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Only alphabets and spaces are allowed');
      RETURN;
    END IF;

    INSERT INTO AIRPORT (
      airport_id,
      airport_name,
      city,
      state,
      country
    ) VALUES (
      admin.airport_seq.nextval,
      a_airport_name,
      a_city,
      a_state,
      a_country
    );
    DBMS_OUTPUT.PUT_LINE('Data Successfully inserted');
    commit;
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred while updating the airport: ' || SQLERRM);      
    rollback;
  END insert_airport;

END airport_pkg;
/

SHOW ERRORS;