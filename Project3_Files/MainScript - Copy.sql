-- connect AirportAdminGuy/AirportMainGuy2024;
-- ENSURE THIS SCRIPT IS EXECUTED BY AIRPORT ADMIN
WHENEVER SQLERROR EXIT SQL.SQLCODE
show user;
--CLEANUP SCRIPT
set serveroutput on
--Alter the sequences used in the script

-- Reset Sequences
alter sequence ADMIN.my_sequence restart start with 1;
alter sequence ADMIN.airline_route_sequence restart start with 10;
alter sequence ADMIN.orders_seq restart start with 1;
--alter sequence flight_seq restart start with 1;
alter sequence ADMIN.passenger_seq restart start with 1;
alter sequence ADMIN.baggage_id_seq restart start with 1;

/*
The Below block of code checks if the tables FLIGHT and PASSENGER
are present in the database. If present the tables are dropped and 
a message indicating the success is the output. In the case of any errors
a custom error message is displayed.
*/
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (
             select 'PASSENGER' table_name from dual UNION ALL
             select 'BAGGAGE' table_name from dual UNION ALL
             select 'TICKET' table_name from dual UNION ALL
             select 'ORDERS' table_name from dual UNION ALL
             select 'SCHEDULE' table_name from dual union all             
             select 'FLIGHT' table_name from dual UNION ALL
             select 'AIRPORT' table_name from dual union all
             select 'AIRLINE_STAFF' table_name from dual union all
             select 'TERMINAL' table_name from dual union all 
             select 'AIRLINES' table_name from dual                          
   )
   loop
   dbms_output.put_line('....Drop table '||i.table_name);
   begin
       select 'Y' into v_table_exists
       from USER_TABLES
       where TABLE_NAME=i.table_name;

       v_sql := 'drop table '||i.table_name;
       execute immediate v_sql;
       dbms_output.put_line('........Table '||i.table_name||' dropped successfully');
       
   exception
       when no_data_found then
           dbms_output.put_line('........Table already dropped');
   end;
   end loop;
   dbms_output.put_line('Schema cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Error with the table:'||sqlerrm);
end;
/

DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'PASSENGER';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE passenger (
          passenger_id NUMBER PRIMARY KEY,
          age NUMBER,
          address VARCHAR2(100),
          sex VARCHAR2(10),
          govt_id_nos VARCHAR2(10),
          first_name VARCHAR2(20),
          last_name VARCHAR2(20),
          dob DATE,
          contact_number NUMBER,
          email VARCHAR2(100)
        )';
    dbms_output.put_line('Table Passenger has been created');
  ELSE
    dbms_output.put_line('Table Passenger already exists');
  END IF;
END;
/
CREATE OR REPLACE PROCEDURE insert_passengers IS
BEGIN
    INSERT INTO passenger (passenger_id, age, address, sex, govt_id_nos, first_name, last_name, dob, contact_number, email)
    SELECT 1, 25, '123 Main St, Anytown, USA', 'Male', 'ABC123', 'John', 'Doe', TO_DATE('1997-05-22', 'YYYY-MM-DD'), 1234567890, 'johndoe@example.com' FROM DUAL
    UNION ALL
    SELECT 2, 35, '456 Oak St, Anytown, USA', 'Female', 'DEF456', 'Jane', 'Smith', TO_DATE('1987-08-15', 'YYYY-MM-DD'), 2345678901, 'janesmith@example.com' FROM DUAL
    UNION ALL
    SELECT 3, 42, '789 Maple Ave, Anytown, USA', 'Male', 'GHI789', 'Bob', 'Johnson', TO_DATE('1980-02-10', 'YYYY-MM-DD'), 3456789012, 'bobjohnson@example.com' FROM DUAL
    UNION ALL
    SELECT 4, 30, '321 Elm St, Anytown, USA', 'Female', 'JKL012', 'Maria', 'Garcia', TO_DATE('1992-11-01', 'YYYY-MM-DD'), 4567890123, 'mariagarcia@example.com' FROM DUAL
    UNION ALL
    SELECT 5, 50, '789 Oak St, Anytown, USA', 'Male', 'MNO345', 'David', 'Lee', TO_DATE('1973-06-12', 'YYYY-MM-DD'), 5678901234, 'davidlee@example.com' FROM DUAL
    UNION ALL
    SELECT 6, 27, '456 Maple Ave, Anytown, USA', 'Female', 'PQR678', 'Emily', 'Wang', TO_DATE('1996-02-29', 'YYYY-MM-DD'), 6789012345, 'emilywang@example.com' FROM DUAL
    UNION ALL
    SELECT 7, 40, '123 Cherry St, Anytown, USA', 'Male', 'STU901', 'Michael', 'Smith', TO_DATE('1981-09-17', 'YYYY-MM-DD'), 7890123456, 'michaelsmith@example.com' FROM DUAL
    UNION ALL
    SELECT 8, 22, '789 Pine St, Anytown, USA', 'Female', 'VWX234', 'Ava', 'Brown', TO_DATE('2000-03-25', 'YYYY-MM-DD'), 8901234567, 'avabrown@example.com' FROM DUAL;    
    commit;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error inserting Passenger: ' || SQLERRM);
END insert_passengers;
/
EXECUTE insert_passengers;

--creating orders table and checking if the table already exists, if it does exist
-- display that the table already exists
DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'ORDERS';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE orders ( 
      order_id NUMBER PRIMARY KEY, 
      passenger_id NUMBER, 
      amount FLOAT, 
      status VARCHAR2(20) 
    )';
    dbms_output.put_line('Table order has been created');
  ELSE
    dbms_output.put_line('Table order already exists');
  END IF;
END;
/

-- A loop to insert 10 values into the orders table, it uses
-- a sequence called orders_seq for the order_id
DECLARE 
  passenger_id NUMBER := 1; 
BEGIN 
  FOR i IN 1..10 LOOP 
    INSERT INTO orders (order_id, passenger_id, amount, status) 
    VALUES (ADMIN.orders_seq.NEXTVAL, passenger_id, 100.00, 'Pending'); 
    passenger_id := passenger_id + 1; 
  END LOOP; 
END; 
/

/*
The Below block of code creates the Airport table. As an additional layer of
validation, the script is executed only if the table does not exist.
*/
DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'AIRPORT';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE airport (
          airport_id NUMBER UNIQUE,
          airport_name VARCHAR2(3) CONSTRAINT airport_name_pk PRIMARY KEY,
          city VARCHAR(20),
          state VARCHAR2(20),
          country VARCHAR2(50)
        )';
    dbms_output.put_line('Table Airport has been created');
  ELSE
    dbms_output.put_line('Table Airport already exists');
  END IF;
END;
/

/*
The Below block of code is a stored procedure for inserting
data into the Aiport table , it is called  insert_airport
and the execution line is present after the block. Once
the data is inserted it is commited to the database. In
the event of any errors a rollback is performed.
*/
CREATE OR REPLACE PROCEDURE insert_airport IS
BEGIN
    INSERT INTO airport (airport_id, airport_name, city, state, country)
    SELECT 1, 'LAX', 'Los Angeles', 'California', 'United States' FROM dual
    UNION ALL
    SELECT 2, 'JFK', 'New York City', 'New York', 'United States' FROM dual
    UNION ALL
    SELECT 3, 'LHR', 'London', null, 'United Kingdom' FROM dual
    UNION ALL
    SELECT 4, 'CDG', 'Paris', null, 'France' FROM dual
    UNION ALL
    SELECT 5, 'NRT', 'Narita', 'Chiba', 'Japan' FROM dual
    UNION ALL
    SELECT 6, 'SYD', 'Sydney', 'New South Wales', 'Australia' FROM dual
    UNION ALL
    SELECT 7, 'AMS', 'Amsterdam', null, 'Netherlands' FROM dual
    UNION ALL
    SELECT 8, 'ICN', 'Incheon', null, 'South Korea' FROM dual
    UNION ALL
    SELECT 9, 'HND', 'Haneda', 'Tokyo', 'Japan' FROM dual
    UNION ALL
    SELECT 10, 'YYZ', 'Toronto', 'Ontario', 'Canada' FROM dual
    UNION ALL
    SELECT 11, 'FRA', 'Frankfurt', null, 'Germany' FROM dual
    UNION ALL
    SELECT 12, 'DXB', 'Dubai', null, 'United Arab Emirates' FROM dual
    UNION ALL
    SELECT 13, 'HKG', 'Hong Kong', null, 'China' FROM dual
    UNION ALL
    SELECT 14, 'PEK', 'Beijing', null, 'China' FROM dual
    UNION ALL
    SELECT 15, 'SVO', 'Moscow', null, 'Russia' FROM dual
    UNION ALL
    SELECT 16, 'MAD', 'Madrid', null, 'Spain' FROM dual
    UNION ALL
    SELECT 17, 'BCN', 'Barcelona', null, 'Spain' FROM dual
    UNION ALL
    SELECT 18, 'BOM', 'Mumbai', 'Maharashtra', 'India' FROM dual
    UNION ALL
    SELECT 19, 'BOS', 'Boston', null, 'United States of America' FROM dual
    UNION ALL
    SELECT 20, 'CGK', 'Jakarta', null, 'Indonesia' FROM dual
    UNION ALL
    SELECT 21, 'SIN', 'Singapore', null, 'Singapore' FROM dual
    UNION ALL
    SELECT 22, 'BER','Berlin',null,'Germany' FROM dual
    UNION ALL
    SELECT 23, 'MIA' , 'Miami', 'Florida', 'United States of America' from DUAL;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Data Inserted into airport table');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error inserting airport: ' || SQLERRM);
END insert_airport;
/
EXECUTE insert_airport;

--creating airlines table, if it doesn't already exist, if it does exist
-- display that the table already exists
DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'AIRLINES';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE airlines ( 
  airline_id NUMBER PRIMARY KEY, 
  route_number NUMBER, 
  airline_code VARCHAR2(10), 
  airline_name VARCHAR2(20) 
)';
    dbms_output.put_line('Table airline has been created');
  ELSE
    dbms_output.put_line('Table airline already exists');
  END IF;
END;
/

--inserting values into airlines table and using a sequence called
-- my_sequence for the airline_id
BEGIN
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1001, ADMIN.airline_route_sequence.NEXTVAL, 'AA', 'American Airlines');
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1002,ADMIN.airline_route_sequence.NEXTVAL, 'DL', 'Delta Air Lines');
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1003, ADMIN.airline_route_sequence.NEXTVAL, 'UA', 'United Airlines') ;
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1004, ADMIN.airline_route_sequence.NEXTVAL, 'WN', 'Southwest Airlines') ;
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1005, ADMIN.airline_route_sequence.NEXTVAL, 'AS', 'Alaska Airlines') ;
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1006, ADMIN.airline_route_sequence.NEXTVAL, 'B6', 'JetBlue Airways');
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1007, ADMIN.airline_route_sequence.NEXTVAL, 'NK', 'Spirit Airlines');
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1008, ADMIN.airline_route_sequence.NEXTVAL, 'F9', 'Frontier Airlines');
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1009, ADMIN.airline_route_sequence.NEXTVAL, 'G4', 'Allegiant Air');
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)  
    VALUES (1010, ADMIN.airline_route_sequence.NEXTVAL, 'SY', 'IndiGo Airlines');
    commit;
    dbms_output.put_line('Data Inserted Successfully into Airlines');
END;
/

DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'AIRLINE_STAFF';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE airline_staff (
    staff_id       NUMBER PRIMARY KEY,
    airline_id     NUMBER REFERENCES airlines(airline_id) ON DELETE CASCADE,
    first_name     VARCHAR2(20),
    last_name      VARCHAR2(20),
    address        VARCHAR2(100),
    ssn            VARCHAR2(12),
    email_id       VARCHAR2(20),
    contact_number NUMBER,
    job_group      VARCHAR2(10),
    gender         VARCHAR2(10)
)';
    dbms_output.put_line('Table Airline_staff has been created');
  ELSE
    dbms_output.put_line('Table Airline_staff already exists');
  END IF;
END;
/
BEGIN
  INSERT INTO airline_staff (staff_id, airline_id, first_name, last_name, address, ssn, email_id, contact_number, job_group, gender) VALUES
    (1, 1001, 'John', 'Doe', '123 Main St', '123-45-6789', 'jdoe@email.com', 5551234, 'Group1', 'Male');
  INSERT INTO airline_staff (staff_id, airline_id, first_name, last_name, address, ssn, email_id, contact_number, job_group, gender) VALUES
    (2, 1002, 'Jane', 'Smith', '456 Elm St', '234-56-7890', 'jsmith@email.com', 5552345, 'Group2', 'Female');
  INSERT INTO airline_staff (staff_id, airline_id, first_name, last_name, address, ssn, email_id, contact_number, job_group, gender) VALUES
    (3, 1003, 'Bob', 'Johnson', '789 Oak St', '345-67-8901', 'bjohnson@email.com', 5553456, 'Group3', 'Male');
  INSERT INTO airline_staff (staff_id, airline_id, first_name, last_name, address, ssn, email_id, contact_number, job_group, gender) VALUES
    (4, 1004, 'Mary', 'Lee', '12 Pine St', '456-78-9012', 'mlee@email.com', 5554567, 'Group4', 'Female');
  INSERT INTO airline_staff (staff_id, airline_id, first_name, last_name, address, ssn, email_id, contact_number, job_group, gender) VALUES
    (5, 1005, 'Tom', 'Wilson', '345 Maple St', '567-89-0123', 'twilson@email.com', 5555678, 'Group5', 'Male');
  dbms_output.put_line('Data Successfully Inserted into Airline Staff');
END;
/

-- CREATING VIEW - no of staff in each airline
/*
The Below block of code creates views from the airline_staff table
-- View 1: number of staff in each airline
*/
CREATE OR REPLACE VIEW airline_staff_counts AS
SELECT airline_name, COUNT(*) AS num_staff
FROM airline_staff
JOIN airlines ON airline_staff.airline_id = airlines.airline_id
GROUP BY airline_name;

/*
The Below block of code creates the FLIGHTS table. As an additional layer of
validation, the script is executed only if the table does not exist.
*/
DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'FLIGHT';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE flight (
      flight_id NUMBER PRIMARY KEY,
      duration NUMBER,
      flight_type VARCHAR2(100),
      departure_time TIMESTAMP,
      arrival_time TIMESTAMP,
      destination VARCHAR2(3) REFERENCES AIRPORT(airport_name) ON DELETE CASCADE,
      source VARCHAR2(3) REFERENCES AIRPORT(airport_name) ON DELETE CASCADE,
      status VARCHAR2(10) ,
      no_pax NUMBER,
      airline_id NUMBER REFERENCES airlines(airline_id) ON DELETE CASCADE
    )';
    dbms_output.put_line('Table flight has been created');
  ELSE
    dbms_output.put_line('Table flight already exists');
  END IF;
END;
/
/*
The Below block of code is a stored procedure for inserting
data into the Flights table , it is called  insert_flight
and the execution line is present after the block. Once
the data is inserted it is commited to the database. In
the event of any errors a rollback is performed.
*/
CREATE OR REPLACE PROCEDURE insert_flight IS
BEGIN
    INSERT INTO flight (flight_id, duration, flight_type, departure_time, arrival_time, destination, source, status, no_pax, airline_id)
    SELECT 101, 120, 'Boeing 737', TO_TIMESTAMP('2023-03-21 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-21 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOS', 'LHR', 'On Time', 200, 1001 from dual union all
    SELECT 102, 180, 'Airbus A320', TO_TIMESTAMP('2023-03-22 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-22 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'LHR', 'BOS', 'Delayed', 150, 1002 from dual union all
    SELECT 103, 240, 'Boeing 747', TO_TIMESTAMP('2023-03-23 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-23 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOS', 'SIN', 'On Time', 400, 1003 from dual union all
    SELECT 104, 90, 'Embraer E175', TO_TIMESTAMP('2023-03-24 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-24 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOS', 'HKG', 'On Time', 80, 1004 from dual union all
    SELECT 105, 150, 'Boeing 737', TO_TIMESTAMP('2023-03-25 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-25 11:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'SIN', 'BOS', 'On Time', 180, 1005 from dual union all
    SELECT 106, 120, 'Airbus A320', TO_TIMESTAMP('2023-03-26 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-26 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOS', 'LAX', 'Delayed', 150, 1006 from dual union all
    SELECT 107, 180, 'Boeing 787', TO_TIMESTAMP('2023-03-27 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-27 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'DXB', 'BOS', 'On Time', 300,1007 from dual union all
    SELECT 108, 90, 'Embraer E175', TO_TIMESTAMP('2023-03-28 17:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-28 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SIN', 'BOS', 'On Time', 80, 1008 from dual union all
    SELECT 109, 120, 'Airbus A320', TO_TIMESTAMP('2023-03-29 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-29 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOS', 'LHR','Cancelled',100, 1009 from dual union all
    SELECT 110, 187, 'Airbus A380', TO_TIMESTAMP('2023-03-30 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-03-29 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'LHR', 'BOS','On Time',300, 1010 from dual;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Data Inserted into flights table');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error inserting flight: ' || SQLERRM);
END insert_flight;
/
EXECUTE insert_flight;

/*
The Below block of code creates the Ticket table. As an additional layer of
validation, the script is executed only if the table does not exist.
*/
DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'TICKET';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE ticket (
      ticket_id NUMBER PRIMARY KEY,
      order_id NUMBER REFERENCES orders(order_id) ON DELETE CASCADE,
      flight_id NUMBER REFERENCES flight(flight_id) ON DELETE CASCADE,
      seat_no VARCHAR2(10),
      meal_preferences VARCHAR2(20),
      source VARCHAR2(3) REFERENCES airport(airport_name) ON DELETE CASCADE,
      destination VARCHAR2(3)  REFERENCES airport(airport_name) ON DELETE CASCADE,
      date_of_travel DATE,
      class VARCHAR2(20),
      payment_type VARCHAR2(20),
      member_id NUMBER,
      transaction_amount FLOAT
      )';
    dbms_output.put_line('Table ticket has been created');
  ELSE
    dbms_output.put_line('Table ticket already exists');
  END IF;
END;
/

BEGIN
  INSERT INTO ticket (ticket_id, order_id, flight_id, seat_no, meal_preferences, source, destination, date_of_travel, class, payment_type, member_id, transaction_amount)
  VALUES (1001, 1, 101, 'A1', 'Vegetarian', 'LAX', 'BOS', TO_DATE('2023-04-15', 'YYYY-MM-DD'), 'Economy', 'Credit Card', 5678, 350.00);
  
  INSERT INTO ticket (ticket_id, order_id, flight_id, seat_no, meal_preferences, source, destination, date_of_travel, class, payment_type, member_id, transaction_amount)
  VALUES (1002, 2, 102, 'B2', 'Kosher', 'JFK', 'BOS', TO_DATE('2023-04-30', 'YYYY-MM-DD'), 'Business', 'PayPal', 1234, 750.00);
  
  INSERT INTO ticket (ticket_id, order_id, flight_id, seat_no, meal_preferences, source, destination, date_of_travel, class, payment_type, member_id, transaction_amount)
  VALUES (1003, 3, 103, 'C3', 'No Preference', 'HKG', 'BOS', TO_DATE('2023-05-01', 'YYYY-MM-DD'), 'Business', 'Debit Card', 9101, 1200.00);
  
  INSERT INTO ticket (ticket_id, order_id, flight_id, seat_no, meal_preferences, source, destination, date_of_travel, class, payment_type, member_id, transaction_amount)
  VALUES (1004, 4, 104, 'D4', 'Gluten Free', 'BOS', 'HKG', TO_DATE('2023-05-15', 'YYYY-MM-DD'), 'Economy', 'Cash', 2345, 250.00);
  
  INSERT INTO ticket (ticket_id, order_id, flight_id, seat_no, meal_preferences, source, destination, date_of_travel, class, payment_type, member_id, transaction_amount)
  VALUES (1005, 5, 105, 'E5', 'Vegetarian', 'BOS', 'JFK', TO_DATE('2023-05-30', 'YYYY-MM-DD'), 'Business', 'Credit Card', 6789, 850.00);
  
  COMMIT;
  dbms_output.put_line('Data Inserted Successfully into Tickets');
END;
/
CREATE OR REPLACE VIEW monthly_ticket_sales AS
SELECT 
  TO_CHAR(date_of_travel, 'YYYY-MM') AS month_of_travel,
  COUNT(*) AS num_tickets_sold,
  SUM(transaction_amount) AS total_sales_amount
FROM 
  ticket
GROUP BY 
  TO_CHAR(date_of_travel, 'YYYY-MM');
/
/*
The Below block of code creates the TERMINAL table. As an additional layer of
validation, the script is executed only if the table does not exist.
*/

DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'TERMINAL';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE terminal (
      terminal_id NUMBER PRIMARY KEY,
      terminal_name VARCHAR2(100)
    )';
    dbms_output.put_line('Table terminal has been created');
  ELSE
    dbms_output.put_line('Table terminal already exists');
  END IF;
END;
/
/*
The Below block of code is a stored procedure for inserting
data into the TERMINAL table , it is called  insert_terminal
and the execution line is present after the block. Once
the data is inserted it is commited to the database. In
the event of any errors a rollback is performed.
*/
CREATE OR REPLACE PROCEDURE insert_terminal IS
BEGIN
    INSERT INTO terminal (terminal_id, terminal_name)
    SELECT 1, 'Terminal A' from dual union all
    SELECT 2, 'Terminal B' from dual union all
    SELECT 3, 'Terminal C' from dual union all
    SELECT 4, 'Terminal D' from dual union all
    SELECT 5, 'Terminal E' from dual;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Data Inserted into terminal table');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error inserting terminal: ' || SQLERRM);
END insert_terminal;
/
EXECUTE insert_terminal;


DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'SCHEDULE';
  IF table_exists = 0 THEN
   EXECUTE IMMEDIATE 'CREATE TABLE schedule (
  schedule_id NUMBER PRIMARY KEY,
  flight_id NUMBER REFERENCES flight(flight_id) ON DELETE CASCADE,
  terminal_id NUMBER REFERENCES terminal(terminal_id) ON DELETE CASCADE,
  arrival_time DATE,
  departure_time DATE
)';
    dbms_output.put_line('Table Schedule has been created');
  ELSE
    dbms_output.put_line('Table Schedule already exists');
  END IF;
END;
/
DECLARE
  i NUMBER := 1;
BEGIN
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, Arrival_time, Departure_time) 
  VALUES (1, 101, 1, TO_DATE('2023-03-22 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-03-22 11:45:00', 'YYYY-MM-DD HH24:MI:SS'));

  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (2, 102,  1, TO_DATE('2023-03-22 12:15:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-03-22 13:30:00', 'YYYY-MM-DD HH24:MI:SS')); 
 
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (3, 103,  2, TO_DATE('2023-03-22 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-03-22 15:15:00', 'YYYY-MM-DD HH24:MI:SS')); 
 
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (4, 104,  3, TO_DATE('2023-03-23 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-03-23 11:45:00', 'YYYY-MM-DD HH24:MI:SS')); 
 
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (5, 105,  2, TO_DATE('2023-03-23 12:15:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-03-23 13:30:00', 'YYYY-MM-DD HH24:MI:SS')); 
 
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (6, 106,  3, TO_DATE('2023-04-01 08:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-04-01 09:45:00', 'YYYY-MM-DD HH24:MI:SS')); 
 
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (7, 107,  2, TO_DATE('2023-04-02 12:15:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-04-02 13:20:00', 'YYYY-MM-DD HH24:MI:SS')); 
 
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (8, 108,  1, TO_DATE('2023-04-03 16:45:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-04-03 18:10:00', 'YYYY-MM-DD HH24:MI:SS')); 
 
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (9, 109,  4,TO_DATE('2023-04-04 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-04-04 11:45:00', 'YYYY-MM-DD HH24:MI:SS')); 
 
  INSERT INTO schedule (schedule_id, flight_id, terminal_id, arrival_time, departure_time)  
  VALUES (10, 110,  2, TO_DATE('2023-04-05 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2023-04-05 15:05:00', 'YYYY-MM-DD HH24:MI:SS'));
  
  COMMIT;
END;
/

-- CREATING VIEW - scheduled flights at a terminal
/*
The Below block of code creates views from the SCHEDULE table
-- View 1: Retrieve all schedule details of flights taking off from a terminal
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  flight_per_terminal AS
    SELECT schedule_id, flight_id, terminal_id, arrival_time, departure_time
    FROM Schedule WHERE terminal_id = 2';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- CREATING VIEW - schedule before a date
/*
The Below block of code creates views from the SCHEDULE table
-- View 1: Retrieve all schedule details of flights taking off before a date
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  flight_at_aTime AS
    SELECT schedule_id, flight_id, terminal_id, arrival_time, departure_time
    FROM Schedule WHERE arrival_time < TO_DATE(''2023-04-02 12:15:00'', ''YYYY-MM-DD HH24:MI:SS'') ';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

DECLARE
  table_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO table_exists FROM user_tables WHERE table_name = 'BAGGAGE';
  IF table_exists = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE baggage (
    baggage_id       NUMBER PRIMARY KEY,
    ticket_id     NUMBER REFERENCES ticket(ticket_id) ON DELETE CASCADE,
    weight        FLOAT
)';
    dbms_output.put_line('Table Baggage has been created');
  ELSE
    dbms_output.put_line('Table Baggage already exists');
  END IF;
END;
/

/*
Stored Procedure for updating baggage weight based on the class
*/
 CREATE OR REPLACE PROCEDURE insert_baggage (
    p_baggage_id IN NUMBER,
    p_ticket_id IN NUMBER
)
IS
    v_weight FLOAT;
    v_ticket_class VARCHAR2(20);
    BEGIN
    SELECT class INTO v_ticket_class FROM ticket WHERE ticket_id = p_ticket_id;
    
    IF v_ticket_class = 'Business' THEN
        v_weight := 200.00;
    ELSE
        v_weight := 100.00;
    END IF;
    
    INSERT INTO baggage (
        baggage_id,
        ticket_id,
        weight
    ) VALUES (
        p_baggage_id,
        p_ticket_id,
        v_weight
    );
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Baggage ' || p_baggage_id || ' weight updated to ' || v_weight);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No ticket found with ID ' || p_ticket_id);
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inserting baggage record: ' || SQLERRM);
    ROLLBACK;
    END insert_baggage;
/

-- Generating 10 insert statements 
DECLARE 
  bag_id NUMBER := 1001; 
BEGIN 
  FOR i IN 1..5 LOOP 
    insert_baggage(ADMIN.baggage_id_seq.NEXTVAL, bag_id);
    bag_id := bag_id + 1;
  END LOOP; 
END; 
/

-- CREATING VIEW - baggage information
/*
The Below block of code creates views from the BAGGAGE table
-- View 1: Retrieve all baggage details
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  baggage_transaction AS
    SELECT baggage_id, weight, ticket_id
    FROM baggage';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/


-- CREATING VIEW -- flight
/*
The Below block of code creates views from the FLIGHT table
-- View 1: Retrieve flight information with the departure and arrival locations swapped
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  swapped_flight_info AS
    SELECT flight_id, duration, flight_type, arrival_time AS departure_time, departure_time AS arrival_time, source AS destination, destination AS source, status, no_pax
    FROM flight';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
/*
The Below block of code creates views from the FLIGHT table
-- View 2: Retrieve only delayed flights
*/

BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  delayed_flights AS
    SELECT *
    FROM flight
    WHERE status = ''Delayed''';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/


-- CREATING VIEW -- passenger

/*
The Below block of code creates views from the FLIGHT table
-- View 1: View Showing All the male passengers travelling through the airport.
*/

BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW male_passengers AS
    SELECT *
    FROM passenger
    WHERE sex = ''Male''';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
/*
The Below block of code creates views from the FLIGHT table
-- View 2: details of children travelling in the airport
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW underage_passengers AS
    SELECT age, email FROM passenger
    WHERE age < 18';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- CREATING VIEW
/*
The Below block of code creates views from the TERMINAL table
-- View 1: Retrieve all terminal details
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  terminal_info AS
    SELECT terminal_id, terminal_name
    FROM terminal';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
/*
The Below block of code creates views from the TERMINAL table
-- View 2: Retrieve the terminal details with longest name
*/

BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  longest_terminal_name_details AS
    SELECT *
    FROM terminal
    ORDER BY LENGTH(terminal_name) DESC
    FETCH FIRST 1 ROW ONLY';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- CREATING VIEW
/*
The Below block of code creates views from the AIRPORT table
-- View 1: Retrieve all airport details
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  airport_info AS
    SELECT airport_id, airport_name
    FROM airport';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
/*
The Below block of code creates views from the AIRPORT table
-- View 2: Retrieve count of the airports in each state
*/

BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  count_of_airport_in_each_country AS
    SELECT COUNT(*) as airport_count, country 
    FROM airport
    GROUP BY country';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

/*
The Below block of code creates views from the ticket table
-- View 2: Retrieve count of the cancelled flights in the airport
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW flight_cancellation_counts AS
    SELECT f.flight_id, COUNT(*) AS cancellation_count
    FROM ticket t
    JOIN flight f ON t.flight_id = f.flight_id
    WHERE f.status = ''Cancelled''
    GROUP BY f.flight_id';

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

/*
Stored Procedure for updating flight Status
*/

CREATE OR REPLACE PROCEDURE update_flight_status(
  p_flight_id IN NUMBER,
  p_status IN VARCHAR2
)
IS
BEGIN
  UPDATE flight
  SET status = p_status
  WHERE flight_id = p_flight_id;
  
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Flight ' || p_flight_id || ' status updated to ' || p_status);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Flight ' || p_flight_id || ' not found.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
--Execution 
--Select * from flight;
EXECUTE update_flight_status(101, 'Delayed');


--SELECT * FROM PASSENGER;
--SELECT * FROM BAGGAGE;
--SELECT * FROM TICKET;
--SELECT * FROM ORDERS;
--SELECT * FROM SCHEDULE;
--SELECT * FROM FLIGHT;
--SELECT * FROM TERMINAL;
--SELECT * FROM AIRPORT;
--SELECT * FROM AIRLINE_STAFF;
--SELECT * FROM TERMINAL;
--SELECT * FROM AIRLINES;
--select * from male_passengers;     


-- Create a role for passenger
-- Add a store procedure to check the paxs data point.
-- Grant necessary system priviliges
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM dba_roles
  WHERE role = 'PASSENGER';
  
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE ROLE passenger IDENTIFIED BY PassengerPrimaryGuy2024';
    EXECUTE IMMEDIATE 'GRANT select ON AirportAdmin.FLIGHT TO passenger';
    DBMS_OUTPUT.PUT_LINE('The passenger role was created successfully');
  ELSE
    DBMS_OUTPUT.PUT_LINE('The passenger role already exists');
  END IF;
END;
/
-- Create a role for Baggage Handler
-- Grant necessary system priviliges
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM dba_roles
  WHERE role = 'BAGGAGE_HANDLER';
  
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE ROLE baggage_handler IDENTIFIED BY BaggagePrimaryGuy2024';
    EXECUTE IMMEDIATE 'GRANT select ON AirportAdmin.FLIGHT TO baggage_handler';
    EXECUTE IMMEDIATE 'GRANT select ON AirportAdmin.BAGGAGE TO baggage_handler';    
    DBMS_OUTPUT.PUT_LINE('The baggage_handler role was created successfully');
  ELSE
    DBMS_OUTPUT.PUT_LINE('The baggage_handler role already exists');
  END IF;
END;
/

-- Create a role for Accounts Department
-- Add a store procedure to check the paxs data point.
-- Grant necessary system priviliges
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM dba_roles
  WHERE role = 'ACCOUNTS_DEPARTMENT';
  
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE ROLE accounts_department IDENTIFIED BY AccountsPrimaryGuy2024';
    EXECUTE IMMEDIATE 'GRANT select ON AirportAdmin.ORDERS TO accounts_department';
    EXECUTE IMMEDIATE 'GRANT select ON AirportAdmin.TICKET TO accounts_department';    
    DBMS_OUTPUT.PUT_LINE('The accounts_department role was created successfully');
  ELSE
    DBMS_OUTPUT.PUT_LINE('The accounts_department role already exists');
  END IF;
END;
/