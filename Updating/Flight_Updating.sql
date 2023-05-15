CREATE OR REPLACE TRIGGER UPDATE_SCHEDULE_TRG
BEFORE UPDATE ON SCHEDULE
FOR EACH ROW
DECLARE
  l_now TIMESTAMP := SYSTIMESTAMP;
BEGIN
    -- Check if arrival and departure date are in the future
    IF :NEW.departure_time <= l_now THEN
        RAISE_APPLICATION_ERROR(-20003, 'Departure date should be in the future');
    END IF;

    IF :NEW.arrival_time <= l_now THEN
        RAISE_APPLICATION_ERROR(-20004, 'Arrival date should be in the future');
    END IF;
END;
/

CREATE OR REPLACE PACKAGE flight_updating_pkg AS

  PROCEDURE update_flight(
    p_flight_id IN NUMBER,
    p_flight_type IN VARCHAR2,
    p_destination IN VARCHAR2,
    p_source IN VARCHAR2,
    p_status IN VARCHAR2,
    p_no_pax IN NUMBER,
    p_airline_id IN NUMBER,
    p_seats_filled IN NUMBER
    -- p_duration IN NUMBER
  );

   PROCEDURE update_schedule(
    p_schedule_id IN VARCHAR2,
    p_flight_id IN NUMBER,
    p_departure_time IN TIMESTAMP,
    p_arrival_time IN TIMESTAMP,
    p_terminal_id IN NUMBER
  );
END flight_updating_pkg;
/

CREATE OR REPLACE PACKAGE BODY flight_updating_pkg AS

  PROCEDURE update_flight(
    p_flight_id IN NUMBER,
    p_flight_type IN VARCHAR2,
    p_destination IN VARCHAR2,
    p_source IN VARCHAR2,
    p_status IN VARCHAR2,
    p_no_pax IN NUMBER,
    p_airline_id IN NUMBER,
    p_seats_filled IN NUMBER
    -- p_duration IN NUMBER
  ) AS
    l_d_airport_count NUMBER;
    l_s_airport_count NUMBER;
    l_airline_count NUMBER;
    -- Define custom exceptions for invalid inputs
    invalid_flight_id EXCEPTION;
    invalid_flight_type EXCEPTION;
    invalid_status EXCEPTION;
    invalid_no_pax EXCEPTION;
    invalid_seats_filled EXCEPTION;
    invalid_duration EXCEPTION;
    
  BEGIN
    -- Validate inputs
    IF p_flight_id IS NULL OR p_flight_id <= 0 THEN
      RAISE invalid_flight_id;
    END IF;
    
    IF LENGTH(p_flight_type) <= 0 or p_flight_type IS NULL THEN
      RAISE invalid_flight_type;
    END IF;
    
    IF LENGTH(p_status) <= 0 or p_status IS NULL THEN
      RAISE invalid_status;
    END IF;
    
    IF p_no_pax <= 0 or p_no_pax IS NULL THEN
      RAISE invalid_no_pax;
    END IF;
    
    IF p_seats_filled > 0 or p_seats_filled IS NULL THEN
      RAISE invalid_seats_filled;
    END IF;

    -- IF p_duration > 0 or p_duration IS NULL THEN
    --   DBMS_OUTPUT.PUT_LINE('duration: ' || p_duration);
    --   RAISE invalid_duration;
    -- END IF;

    l_d_airport_count := ONBOARD_FLIGHT_PKG.check_airport(p_destination);
    DBMS_OUTPUT.PUT_LINE('Output value for destination: ' || l_d_airport_count);

    IF l_d_airport_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Destination airport does not exist in airport table');
      RETURN;
    END IF;

    l_s_airport_count := ONBOARD_FLIGHT_PKG.check_airport(p_source);
    DBMS_OUTPUT.PUT_LINE('Output value for source: ' || l_s_airport_count);

    IF l_s_airport_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Source airport does not exist in airport table');
      RETURN;
    END IF;

    l_airline_count := ONBOARD_FLIGHT_PKG.check_airline(p_airline_id);
    DBMS_OUTPUT.PUT_LINE('Output value for airline: ' || l_airline_count);

    IF l_airline_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Airline does not exist in airline table');
      RETURN;
    END IF;
    
    -- Update flight
    UPDATE flight SET
      flight_type = p_flight_type,
      destination = p_destination,
      source = p_source,
      status = p_status,
      no_pax = p_no_pax,
      airline_id = p_airline_id,
      seats_filled = p_seats_filled
      -- duration = p_duration
    WHERE flight_id = p_flight_id;

    COMMIT;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No data found with the given flight_id');
    WHEN invalid_flight_id THEN 
      dbms_output.put_line('Invalid flight id');
    WHEN invalid_flight_type THEN 
      dbms_output.put_line('Invalid flight type');
    WHEN invalid_status THEN 
      dbms_output.put_line('Invalid status');
    WHEN invalid_no_pax THEN 
      dbms_output.put_line('Invalid number of passengers');
    WHEN invalid_seats_filled THEN 
      dbms_output.put_line('Invalid number of seats filled');
    WHEN invalid_duration THEN 
      dbms_output.put_line('Invalid Duration');
    ROLLBACK;
    END update_flight;
  

 PROCEDURE update_schedule(
  p_schedule_id IN VARCHAR2,
  p_flight_id IN NUMBER,
  p_departure_time IN TIMESTAMP,
  p_arrival_time IN TIMESTAMP,
  p_terminal_id IN NUMBER
) AS
  -- Define custom exceptions for invalid inputs
  l_duration NUMBER;
  invalid_schedule_id EXCEPTION;
  invalid_flight_id EXCEPTION;
  invalid_terminal_id EXCEPTION;
BEGIN

  IF p_schedule_id IS NULL OR p_schedule_id <= 0 THEN
    RAISE invalid_schedule_id;
  END IF;

  IF p_flight_id IS NULL OR p_flight_id <= 0 THEN
    RAISE invalid_flight_id;
  END IF;

  IF p_terminal_id IS NULL OR p_terminal_id <= 0 THEN
    RAISE invalid_terminal_id;
  END IF;

  l_duration := ONBOARD_FLIGHT_PKG.get_duration(p_arrival_time, p_departure_time);
  DBMS_OUTPUT.PUT_LINE('Duration Match: ' || l_duration);

  IF l_duration = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Duration is Wrong');
    RETURN;
  END IF;

  UPDATE schedule SET
    flight_id = p_flight_id,
    departure_time = p_departure_time,
    arrival_time = p_arrival_time,
    terminal_id = p_terminal_id
  WHERE schedule_id = p_schedule_id;
  
UPDATE flight SET
    duration = l_duration
    WHERE flight_id = p_flight_id;

  COMMIT;

 EXCEPTION
  WHEN invalid_schedule_id THEN 
      dbms_output.put_line('Invalid schedule id');
  WHEN invalid_flight_id THEN 
      dbms_output.put_line('Invalid flight id');
  WHEN invalid_terminal_id THEN 
      dbms_output.put_line('Invalid terminal id');
END update_schedule;

END flight_updating_pkg;
