CREATE OR REPLACE PACKAGE delete_airline_pkg AS
  PROCEDURE delete_airline(p_airline_id IN NUMBER);
END delete_airline_pkg;
/
CREATE OR REPLACE PACKAGE BODY delete_airline_pkg AS
  PROCEDURE delete_airline(p_airline_id IN NUMBER) IS
  BEGIN
    DELETE FROM airlines
    WHERE airline_id = p_airline_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Delete operation successful');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No data found for the given airline ID');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
      ROLLBACK;
  END delete_airline;
END delete_airline_pkg;
/