CREATE OR REPLACE TRIGGER INSERT_TICKET_TRG
BEFORE INSERT ON TICKET
FOR EACH ROW
DECLARE
  l_now TIMESTAMP := SYSTIMESTAMP;
BEGIN
    -- Check if date_of_travel are in the future
    IF :NEW.date_of_travel <= l_now THEN
        RAISE_APPLICATION_ERROR(-20003, 'Date_of_travel should be in the future');
    END IF;
END;
/

--CREATE OR REPLACE TRIGGER validate_flight_location
--BEFORE INSERT OR UPDATE ON ticket
--FOR EACH ROW
--DECLARE
--    location_exists NUMBER;
--BEGIN
--    SELECT COUNT(*) INTO location_exists FROM ticket 
--    WHERE flight_id = :NEW.flight_id 
--    AND source = :NEW.source 
--    AND destination = :NEW.destination;
--    IF location_exists > 0 THEN
--        RAISE_APPLICATION_ERROR(-20001, 'Cannot add new source and destination for this flight ID');
--    END IF;
--END;
--/
--CREATE UNIQUE INDEX ticket_index
--ON ticket(flight_id, source,destination);

/*
Stored Procedure for updating baggage weight based on the class
*/
 CREATE OR REPLACE PROCEDURE insert_baggage (
    in_baggage_id IN NUMBER,
    in_ticket_id IN NUMBER
)
IS
    v_weight FLOAT;
    v_ticket_class VARCHAR2(20);
    BEGIN

    SELECT class INTO v_ticket_class FROM ticket WHERE ticket_id = in_ticket_id;
    
 IF v_ticket_class = 'Business' THEN
    v_weight := 200.00;
END IF;
IF v_ticket_class = 'Business Pro' THEN
    v_weight := 300.00;
END IF;
IF v_ticket_class = 'First Class' THEN
    v_weight := 400.00;
END IF;
IF v_ticket_class = 'Economy' THEN
    v_weight := 100.00;
END IF;
    
    INSERT INTO baggage (
        baggage_id,
        ticket_id,
        weight
    ) VALUES (
        in_baggage_id,
        in_ticket_id,
        v_weight
    );
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Baggage ' || in_baggage_id || ' weight updated to ' || v_weight);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No ticket found with ID ' || in_ticket_id);
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inserting baggage record: ' || SQLERRM);
    ROLLBACK;
    END insert_baggage;
/

CREATE OR REPLACE PACKAGE ONBOARD_TICKET_PKG AS
  FUNCTION check_flight_exists(p_flight_id IN NUMBER,p_source IN VARCHAR2,p_destination IN VARCHAR2) RETURN BOOLEAN;
  FUNCTION check_airport(in_airport_name IN VARCHAR2) RETURN NUMBER;

  FUNCTION check_flight(in_flight_id IN NUMBER) RETURN NUMBER;

  PROCEDURE INSERT_TICKET(
    in_order_id IN NUMBER,
    in_flight_id IN NUMBER,
    in_seat_no IN VARCHAR2,
    in_meal_preferences IN VARCHAR2,
    in_source IN VARCHAR2,
    in_destination IN VARCHAR2,
    in_date_of_travel IN DATE,
    in_class IN VARCHAR2,
    in_payment_type IN VARCHAR2,
    in_member_id IN NUMBER,
    in_transaction_amount IN FLOAT
);

END ONBOARD_TICKET_PKG;
/

CREATE OR REPLACE PACKAGE BODY ONBOARD_TICKET_PKG AS
    FUNCTION check_flight_exists(
      p_flight_id IN NUMBER,
      p_source IN VARCHAR2,p_destination IN VARCHAR2
    ) RETURN BOOLEAN
    IS
      l_flight_exists NUMBER;
      l_flight_count NUMBER;
    BEGIN
      -- Check if a flight record exists with the given flight_id, source, and destination
      
      SELECT COUNT(*)
      INTO l_flight_count
      FROM ticket;
      
      SELECT COUNT(*) INTO l_flight_exists
      FROM flight
      WHERE flight_id = p_flight_id
        AND source = p_source
        AND destination = p_destination;
     select count(*) into l_flight_exists from ticket 
     where flight_id = p_flight_id and source = p_source and destination = p_destination;

--        SELECT COUNT(*)
--        INTO l_flight_count
--        FROM ticket
--        WHERE passenger_id = p_passenger_id
--        AND source = p_source
--        AND dest = p_dest;
        SELECT COUNT(*)
        INTO l_flight_count
        FROM ticket
        WHERE flight_id = p_flight_id
        AND (source != p_source OR destination != p_destination);   
     IF (l_flight_count > 0)  THEN
       Return True;
     else
       Return False;
--       if (l_flight_exists = 0) THEN
--         Return False;
--        else  
--         return true;
--       end if; 
     END IF;
      --RETURN l_flight_exists;
      
    END check_flight_exists;

  FUNCTION check_airport(in_airport_name IN VARCHAR2) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_result
    FROM airport
    WHERE airport_name = in_airport_name;

    RETURN v_result;
  END check_airport;

  FUNCTION check_flight(in_flight_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_result
    FROM flight
    WHERE flight_id = in_flight_id;

    RETURN v_result;
  END check_flight;
  
  PROCEDURE INSERT_TICKET(
    in_order_id IN NUMBER,
    in_flight_id IN NUMBER,
    in_seat_no IN VARCHAR2,
    in_meal_preferences IN VARCHAR2,
    in_source IN VARCHAR2,
    in_destination IN VARCHAR2,
    in_date_of_travel IN DATE,
    in_class IN VARCHAR2,
    in_payment_type IN VARCHAR2,
    in_member_id IN NUMBER,
    in_transaction_amount IN FLOAT
  ) AS
    l_d_airport_count NUMBER;
    l_s_airport_count NUMBER;
    l_flight_count NUMBER;
    l_flight_exists BOOLEAN;
    l_ticket_id NUMBER := ADMIN.ticket_seq.NEXTVAL; --seq
    -- INVALID_INPUTS EXCEPTION;
    invalid_ticket_id EXCEPTION;
    invalid_order_id EXCEPTION;
    invalid_flight_id EXCEPTION;
    invalid_seat_no EXCEPTION;
    invalid_meal_preferences EXCEPTION;
    invalid_source EXCEPTION;
    invalid_destination EXCEPTION;
    invalid_date_of_travel EXCEPTION;
    invalid_class EXCEPTION;
    invalid_payment_type EXCEPTION;
    invalid_member_id EXCEPTION;
    invalid_transaction_amount EXCEPTION;
  
BEGIN
     -- Validate inputs
    IF in_flight_id IS NULL OR in_flight_id <= 0 THEN
      RAISE invalid_flight_id;
    END IF;

    IF in_order_id IS NULL OR in_order_id <= 0 THEN
      RAISE invalid_order_id;
    END IF;
    
    IF LENGTH(in_seat_no) <= 0 OR in_seat_no IS NULL THEN
      RAISE invalid_seat_no;
    END IF;
    
    IF LENGTH(in_meal_preferences) <= 0 OR in_meal_preferences IS NULL THEN
      RAISE invalid_meal_preferences;
    END IF;
    
    IF LENGTH(in_source) <= 0 THEN
      RAISE invalid_source;
    END IF;

    IF LENGTH(in_destination) <= 0 THEN
      RAISE invalid_destination;
    END IF;

    IF LENGTH(in_class) <= 0 OR in_class IS NULL THEN
      RAISE invalid_class;
    END IF;

    IF LENGTH(in_member_id) <= 0 THEN
      RAISE invalid_member_id;
    END IF;

    IF LENGTH(in_transaction_amount) <= 0.0 THEN
      RAISE invalid_transaction_amount;
    END IF;

     IF LENGTH(in_payment_type) <= 0 OR in_payment_type IS NULL THEN
      RAISE invalid_payment_type;
    END IF;

    l_flight_count := ONBOARD_TICKET_PKG.check_flight(in_flight_id);
    DBMS_OUTPUT.PUT_LINE('Output value for flight: ' || l_flight_count);

    IF l_flight_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Flight_id does not exist in flight table');
      RETURN;
    END IF;

      l_d_airport_count := ONBOARD_FLIGHT_PKG.check_airport(in_destination);
    DBMS_OUTPUT.PUT_LINE('Output value for destination: ' || l_d_airport_count);

    IF l_d_airport_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Destination airport does not exist in airport table');
      RETURN;
    END IF;

    l_s_airport_count := ONBOARD_FLIGHT_PKG.check_airport(in_source);
    DBMS_OUTPUT.PUT_LINE('Output value for source: ' || l_s_airport_count);

    IF l_s_airport_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Source airport does not exist in airport table');
      RETURN;
    END IF;
    
    l_flight_exists := check_flight_exists(in_flight_id, in_source, in_destination);
    IF l_flight_exists THEN 
      DBMS_OUTPUT.PUT_LINE('The Source and Destination is not matching');
      RETURN;
    END IF;    
    -- Insert ticket record
    INSERT INTO ticket (
     ticket_id, order_id, flight_id, seat_no, meal_preferences, source, destination, date_of_travel, class, payment_type, member_id
    ) VALUES (
    l_ticket_id,
    in_order_id,
    in_flight_id,
    in_seat_no,
    in_meal_preferences,
    in_source,
    in_destination,
    in_date_of_travel,
    in_class,
    in_payment_type,
    in_member_id
    );

    UPDATE ORDERS SET amount = in_transaction_amount WHERE order_id = in_order_id;

    UPDATE FLIGHT f
      SET f.SEATS_FILLED = f.SEATS_FILLED + 1
      WHERE f.flight_id = in_flight_id;
      COMMIT;

    --insert a schedule for the flight
    insert_baggage(ADMIN.baggage_id_seq.NEXTVAL, l_ticket_id);
    
  EXCEPTION
    WHEN invalid_ticket_id THEN 
      dbms_output.put_line('Invalid Ticket id');
    WHEN invalid_order_id THEN 
      dbms_output.put_line('Invalid order id');
    WHEN invalid_flight_id THEN 
      dbms_output.put_line('Invalid flight id');
    WHEN invalid_seat_no THEN 
      dbms_output.put_line('Invalid seat no');
    WHEN invalid_meal_preferences THEN 
      dbms_output.put_line('Invalid meal_preferences');
    WHEN invalid_source THEN 
      dbms_output.put_line('Invalid source');
    WHEN invalid_destination THEN 
      dbms_output.put_line('Invalid destination');
    WHEN invalid_date_of_travel THEN 
      dbms_output.put_line('Invalid date_of_travel');
    WHEN invalid_class THEN 
      dbms_output.put_line('Invalid class');
    WHEN invalid_payment_type THEN 
      dbms_output.put_line('Invalid payment_type');
    WHEN invalid_member_id THEN 
      dbms_output.put_line('Invalid member id');

  END INSERT_TICKET;
END ONBOARD_TICKET_PKG;
/

