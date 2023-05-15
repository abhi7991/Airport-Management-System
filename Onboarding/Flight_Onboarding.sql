CREATE OR REPLACE TRIGGER INSERT_SCHEDULE_TRG
BEFORE INSERT ON SCHEDULE
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

CREATE OR REPLACE PACKAGE ONBOARD_FLIGHT_PKG AS
  FUNCTION check_terminal_busy (p_terminal_id IN NUMBER,p_departure_time IN TIMESTAMP ) RETURN NUMBER;
  FUNCTION check_airport(in_airport_name IN VARCHAR2) RETURN NUMBER;
  FUNCTION check_airline(in_airline_id IN NUMBER) RETURN NUMBER;
  FUNCTION check_terminal(in_terminal_id IN NUMBER) RETURN NUMBER;
  FUNCTION get_duration(in_arrival_time IN TIMESTAMP, in_departure_time IN TIMESTAMP) RETURN NUMBER;

  PROCEDURE INSERT_FLIGHT(
    p_flight_type IN VARCHAR2,
    p_departure_time IN TIMESTAMP,
    p_arrival_time IN TIMESTAMP,
    p_destination IN VARCHAR2,
    p_source IN VARCHAR2,
    p_status IN VARCHAR2,
    p_no_pax IN NUMBER,
    p_airline_id IN NUMBER,
    p_seats_filled IN NUMBER,
    p_terminal_id IN NUMBER
  );
END ONBOARD_FLIGHT_PKG;
/

CREATE OR REPLACE PACKAGE BODY ONBOARD_FLIGHT_PKG AS
    FUNCTION check_terminal_busy (p_terminal_id IN NUMBER, p_departure_time IN TIMESTAMP) RETURN NUMBER IS
      v_flight_count NUMBER;
    BEGIN
      SELECT COUNT(*) INTO v_flight_count FROM schedule 
      WHERE terminal_id = p_terminal_id 
      AND departure_time = p_departure_time;     
      RETURN v_flight_count;
    END check_terminal_busy;

    
  FUNCTION check_airport(in_airport_name IN VARCHAR2) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_result
    FROM airport
    WHERE airport_name = in_airport_name;

    RETURN v_result;
  END check_airport;

  FUNCTION check_airline(in_airline_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_result
    FROM airlines
    WHERE airline_id = in_airline_id;

    RETURN v_result;
  END check_airline;

  FUNCTION check_terminal(in_terminal_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_result
    FROM terminal
    WHERE terminal_id = in_terminal_id;

    RETURN v_result;
  END check_terminal;

FUNCTION get_duration(
    in_arrival_time IN TIMESTAMP,
    in_departure_time IN TIMESTAMP
) RETURN NUMBER IS
    v_duration_in_minutes NUMBER;
BEGIN
    IF in_departure_time >= in_arrival_time THEN
        RAISE_APPLICATION_ERROR(-20001, 'Arrival time must be after departure time');
    END IF;
    
    SELECT (EXTRACT(DAY FROM (in_arrival_time - in_departure_time)) * 24 * 60) +
           (EXTRACT(HOUR FROM (in_arrival_time - in_departure_time)) * 60) +
            EXTRACT(MINUTE FROM (in_arrival_time - in_departure_time))
    INTO v_duration_in_minutes
    FROM dual;
    
    RETURN v_duration_in_minutes;
END get_duration;
  
  PROCEDURE INSERT_FLIGHT(
    p_flight_type IN VARCHAR2,
    p_departure_time IN TIMESTAMP,
    p_arrival_time IN TIMESTAMP,
    p_destination IN VARCHAR2,
    p_source IN VARCHAR2,
    p_status IN VARCHAR2,
    p_no_pax IN NUMBER,
    p_airline_id IN NUMBER,
    p_seats_filled IN NUMBER,
    p_terminal_id IN NUMBER
  ) AS
    l_d_airport_count NUMBER;
    l_s_airport_count NUMBER;
    l_duration NUMBER;
    l_airline_count NUMBER;
    l_terminal_count NUMBER;
    l_flight_count NUMBER;
    l_flight_id NUMBER := ADMIN.flight_seq.NEXTVAL;
    INVALID_INPUTS EXCEPTION;
    invalid_flight_id EXCEPTION;
    invalid_flight_type EXCEPTION;
    invalid_status EXCEPTION;
    invalid_no_pax EXCEPTION;
    invalid_seats_filled EXCEPTION;
    invalid_duration EXCEPTION;
    
  BEGIN
    
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

    l_terminal_count := ONBOARD_FLIGHT_PKG.check_terminal(p_terminal_id);
    DBMS_OUTPUT.PUT_LINE('Output value for terminal: ' || l_terminal_count);

    IF l_terminal_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Terminal does not exist in terminal table');
      RETURN;
    END IF;

     l_duration := ONBOARD_FLIGHT_PKG.get_duration(p_arrival_time, p_departure_time);
    DBMS_OUTPUT.PUT_LINE('Duration Got: ' || l_duration);

    IF l_duration = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Duration is Wrong');
      RETURN;
    END IF;
    
    l_flight_count:= check_terminal_busy(p_terminal_id, p_departure_time);
    DBMS_OUTPUT.PUT_LINE('flight count: ' || l_flight_count);
    
    IF l_flight_count > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Terminal is Busy');
      RETURN;
    END IF;

    -- Insert flight record
    INSERT INTO flight (
      flight_id,
      duration,
      flight_type,
      destination,
      source,
      status,
      no_pax,
      airline_id,
      seats_filled
    ) VALUES (
      l_flight_id,
      l_duration,
      p_flight_type,
      p_destination,
      p_source,
      p_status,
      p_no_pax,
      p_airline_id,
      p_seats_filled
    );
    COMMIT;

--insert a schedule for the flight
    INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time) 
    VALUES (ADMIN.schedule_seq.NEXTVAL, l_flight_id, p_terminal_id, p_arrival_time ,p_departure_time);       --insert a schedule sequence
    COMMIT;
EXCEPTION
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

  END INSERT_FLIGHT;
END ONBOARD_FLIGHT_PKG;
/