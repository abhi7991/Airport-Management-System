/*
This Package is used for inserting and Updating passenger data
After a passenger signs up an Order gets generated in the order table
When a passenger deetes a ticket the number of passengers on a flight reduces
*/
--ALTER TABLE ticket
--  PARALLEL(DEGREE 1);
CREATE OR REPLACE PACKAGE passenger_updating_pkg AS
  PROCEDURE update_passenger(
    p_passenger_id     IN NUMBER DEFAULT NULL,
    p_age              IN NUMBER,
    p_address          IN VARCHAR2,
    p_sex              IN VARCHAR2,
    p_govt_id_nos      IN VARCHAR2,
    p_first_name       IN VARCHAR2,
    p_last_name        IN VARCHAR2,
    p_dob              IN DATE,
    p_contact_number   IN VARCHAR2,
    p_email            IN VARCHAR2
  );
END passenger_updating_pkg;
/

CREATE OR REPLACE PACKAGE BODY passenger_updating_pkg AS
PROCEDURE update_passenger(
    p_passenger_id     IN NUMBER ,
    p_age              IN NUMBER,
    p_address          IN VARCHAR2,
    p_sex              IN VARCHAR2,
    p_govt_id_nos      IN VARCHAR2,
    p_first_name       IN VARCHAR2,
    p_last_name        IN VARCHAR2,
    p_dob              IN DATE,
    p_contact_number   IN VARCHAR2,
    p_email            IN VARCHAR2
  ) IS
    v_passenger_id NUMBER;
    v_count NUMBER;    
  BEGIN
    IF p_passenger_id IS NULL THEN
      -- Prompt user to enter passenger ID
      dbms_output.put('Please enter the passenger ID: ');
      Return;
    ELSIF p_passenger_id IS NULL or p_age IS NULL OR p_address IS NULL OR p_sex IS NULL OR p_govt_id_nos IS NULL OR p_first_name IS NULL OR p_last_name IS NULL OR p_dob IS NULL OR p_contact_number IS NULL OR p_email IS NULL THEN
      dbms_output.put('All input parameters must be specified');
      Return;      
    ELSIF p_sex NOT IN ('Male', 'Female', 'Other') THEN
      dbms_output.put('Sex must be specified as male, female, or other');
      Return;      
    -- Validate gov_id_nos input
    ELSIF LENGTH(p_govt_id_nos) != 10 THEN
      dbms_output.put('Govt ID Number must be a 10-digit value');
      Return;            
    -- Validate contact_number input
    ELSIF LENGTH(p_contact_number) != 10 THEN
      dbms_output.put('Contact Number must be a 10-digit value');
      Return;
    -- Validate email input
    ELSIF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') = FALSE THEN
      dbms_output.put('Invalid email format');
      Return;         
    ELSE
      v_passenger_id := p_passenger_id;
    END IF;

    SELECT COUNT(*) INTO v_count FROM PASSENGER WHERE passenger_id = v_passenger_id;
    
    IF v_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('No passenger found with the given ID');
      RETURN;
    END IF;

    -- Check if email already exists
    SELECT COUNT(*) INTO v_count FROM PASSENGER WHERE email = p_email AND passenger_id <> p_passenger_id;
    
    IF v_count > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Email already in use by another passenger');
      RETURN;
    END IF;

    BEGIN
      UPDATE PASSENGER
      SET
        age = p_age,
        address = p_address,
        sex = p_sex,
        govt_id_nos = p_govt_id_nos,
        first_name = p_first_name,
        last_name = p_last_name,
        dob = p_dob,
        contact_number = p_contact_number,
        email = p_email
      WHERE
        passenger_id = v_passenger_id;
      commit;  
      DBMS_OUTPUT.PUT_LINE('Data Successfully Updated');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No passenger found with the given ID');
        RETURN;
      WHEN OTHERS THEN
        --DBMS_OUTPUT.PUT_LINE('An error occurred while updating the passenger');
        DBMS_OUTPUT.PUT_LINE('An error occurred while updating the passenger: ' || SQLERRM);      
        RETURN;
    END;

  END update_passenger;
END passenger_updating_pkg;
/

SHOW ERRORS;
