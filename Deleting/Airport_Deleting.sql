/*
This Package is used for deleting airport data
*/

CREATE OR REPLACE PACKAGE airport_deleting_pkg AS
  PROCEDURE delete_airport(
    a_airport_id IN NUMBER
  );
END airport_deleting_pkg;
/

CREATE OR REPLACE PACKAGE BODY airport_deleting_pkg AS

    PROCEDURE delete_airport(
    a_airport_id IN NUMBER
    ) IS
    BEGIN
    
      DELETE FROM AIRPORT
      WHERE airport_id = a_airport_id;
      COMMIT;
    
      DBMS_OUTPUT.PUT_LINE('Airport deleted successfully');  
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Airport with airport_id ' || a_airport_id || ' not found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error deleting airport with airport_id ' || a_airport_id || ': ' || SQLERRM);
            
    END delete_airport;
END airport_deleting_pkg;
/

SHOW ERRORS;