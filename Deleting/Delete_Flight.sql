CREATE OR REPLACE PACKAGE FLIGHT_DELETE_PKG AS


 PROCEDURE delete_schedule(
    p_schedule_id IN NUMBER
  );

  PROCEDURE delete_flight(
    p_flight_id IN NUMBER
  );

END FLIGHT_DELETE_PKG;
/

CREATE OR REPLACE PACKAGE BODY FLIGHT_DELETE_PKG AS


 PROCEDURE delete_schedule(
    p_schedule_id IN NUMBER
  ) AS
    invalid_schedule_id EXCEPTION;
  BEGIN
    -- Validate inputs
    IF p_schedule_id IS NULL OR p_schedule_id <= 0 THEN
      RAISE invalid_schedule_id;
    END IF;
    
    -- delete schedule
    DELETE FROM SCHEDULE
      WHERE schedule_id = p_schedule_id;
    COMMIT; 
    
    DBMS_OUTPUT.PUT_LINE('Data successfully deleted from schedule table');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('No data found with the given schedule_id');
        WHEN invalid_schedule_id THEN 
        dbms_output.put_line('Invalid schedule id');
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('An error occurred while deleting data: ' || SQLERRM);
          ROLLBACK;
    END delete_schedule;

  PROCEDURE delete_flight(
    p_flight_id IN NUMBER
  ) AS
    invalid_flight_id EXCEPTION;
    l_schedule_id NUMBER;
    l_count NUMBER;
  BEGIN
    -- Validate inputs 
    select flight_id into l_count from flight where flight_id = p_flight_id;

    IF p_flight_id IS NULL OR p_flight_id <= 0 OR l_count = 0 THEN
     RAISE invalid_flight_id;
    END IF;

   select schedule_id into l_schedule_id from schedule where flight_id = p_flight_id;
    
   IF l_schedule_id IS NOT NULL THEN
    delete_schedule(l_schedule_id);
   END IF;

    -- update flight status to cancelled
    -- DELETE FROM FLIGHT
    --   WHERE flight_id = p_flight_id;

    UPDATE FLIGHT 
      SET status = 'Cancelled'
      WHERE flight_id = p_flight_id;
    COMMIT;

    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('Data successfully deleted from flight table');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('No data found with the given flight_id');
        WHEN invalid_flight_id THEN 
          dbms_output.put_line('Invalid flight id');
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('An error occurred while deleting data: ' || SQLERRM);
          ROLLBACK;
    END delete_flight;


END FLIGHT_DELETE_PKG;
