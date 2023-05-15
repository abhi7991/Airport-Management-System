
---Admin Scripts
show user;
-- create a new user - Airport_Admin
--CREATE USER AirportAdmin IDENTIFIED BY AirportMainGuy2024;
---- grant necessary system privileges
--GRANT CREATE SESSION TO AirportAdmin;
--GRANT UNLIMITED TABLESPACE TO AirportAdmin;
--GRANT CREATE TABLE TO AirportAdmin;
--GRANT CREATE PROCEDURE TO AirportAdmin;
--GRANT CREATE SEQUENCE TO AirportAdmin;
--GRANT CREATE TRIGGER TO AirportAdmin;
--GRANT CREATE ANY VIEW TO AirportAdmin;  
--SELECT count(*) FROM dba_users WHERE username = 'AIRPORTADMIN';
DECLARE
   v_count INTEGER;
BEGIN
   SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'AIRPORTADMIN';
   IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE USER AirportAdmin IDENTIFIED BY AirportMainGuy2024';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO AirportAdmin WITH ADMIN OPTION';
        EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO AirportAdmin';
        EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO AirportAdmin';
        EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO AirportAdmin';
        EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO AirportAdmin';
        EXECUTE IMMEDIATE 'GRANT CREATE TRIGGER TO AirportAdmin';
        EXECUTE IMMEDIATE 'GRANT CREATE ANY VIEW TO AirportAdmin WITH ADMIN OPTION';      
        EXECUTE IMMEDIATE 'GRANT CREATE ROLE TO AirportAdmin';
        EXECUTE IMMEDIATE 'GRANT CREATE USER TO AirportAdmin';        
        EXECUTE IMMEDIATE 'GRANT SELECT on dba_roles to AirportAdmin';
        EXECUTE IMMEDIATE 'GRANT SELECT ON dba_users to AirportAdmin;'; 
        EXECUTE IMMEDIATE 'GRANT DROP USER TO AirportAdmin';
        EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO AirportAdmin with ADMIN OPTION';-- CHECK IF THIS CONDITION IS OKAY - FORN WITH GRANT OPTION
        DBMS_OUTPUT.PUT_LINE('User CREATED and assigned the necessary priviliges SUCCESSFULLY');
   ELSE
        DBMS_OUTPUT.PUT_LINE('User already exists');
   END IF;
END;
/

/*
The below Code Deletes all Sequences
*/
BEGIN
   FOR seq IN (SELECT sequence_name FROM user_sequences) LOOP
      EXECUTE IMMEDIATE 'DROP SEQUENCE ' || seq.sequence_name;
   END LOOP;
END;
/
-- -- CREATE A SEQUENCE FOR FLIGHT
-- CREATE SEQUENCE flight_seq
--   MINVALUE 100
--   MAXVALUE 10000
--   START WITH 100
--   INCREMENT BY 1
--   CACHE 1000;

-- CREATE A SEQUENCE FOR PASSENGER
CREATE SEQUENCE passenger_seq
  MINVALUE 1000
  MAXVALUE 1000000
  START WITH 1000
  INCREMENT BY 1
  CACHE 1000;
-- CHECK  
--SELECT passenger_seq.NEXTVAL FROM DUAL;
--select * from dba_tab_privs<<<<<<< where table_name = 'passenger_seq';
-- DROP SEQUENCE airline_seq;
--DROP SEQUENCE airline_seq;
-- CREATE A SEQUENCE FOR AIRLINE
CREATE SEQUENCE airline_seq 
START WITH 1 
INCREMENT BY 1 
MAXVALUE 1000 
NOCYCLE 
CACHE 20; 

-- CREATE A SEQUENCE FOR AIRLINE ROUTE
CREATE SEQUENCE airline_route_sequence 
START WITH 600 
INCREMENT BY 50 
MAXVALUE 100000 
NOCYCLE 
CACHE 20; 

-- CREATE A SEQUENCE FOR ORDER 
CREATE SEQUENCE orders_seq 
START WITH 50000 
INCREMENT BY 1; 

-- CREATE A SEQUENCE FOR BAGGAGE 
CREATE SEQUENCE baggage_id_seq 
START WITH 10 
INCREMENT BY 1; 

-- CREATE A SEQUENCE FOR AIRPORT
CREATE SEQUENCE airport_seq 
START WITH 1 
INCREMENT BY 1 
MAXVALUE 1000 
NOCYCLE 
CACHE 20; 

-- CREATE A SEQUENCE FOR FLIGHT
CREATE SEQUENCE flight_seq 
START WITH 4000
INCREMENT BY 1 
MAXVALUE 4999 
NOCYCLE 
CACHE 20; 

-- CREATE A SEQUENCE FOR SCHEDULE
CREATE SEQUENCE schedule_seq 
START WITH 5000
INCREMENT BY 1 
MAXVALUE 5999
NOCYCLE 
CACHE 20; 

-- CREATE A SEQUENCE FOR SCHEDULE
CREATE SEQUENCE terminal_seq 
START WITH 6000
INCREMENT BY 1 
MAXVALUE 6999
NOCYCLE 
CACHE 20; 

-- CREATE A SEQUENCE FOR SCHEDULE
CREATE SEQUENCE ticket_seq 
START WITH 7000
INCREMENT BY 1 
MAXVALUE 7999
NOCYCLE 
CACHE 20; 

-- CREATE A SEQUENCE FOR AIRLINE STAFF
CREATE SEQUENCE airline_staff_seq
START WITH 770
INCREMENT BY 1
MAXVALUE 100000
NOCYCLE
CACHE 20;


-- Granting Priviliges
grant select on airline_seq to AirportAdmin;  
grant select on airline_route_sequence to AirportAdmin;
grant select on orders_seq to AirportAdmin;
--grant select on flight_seq to AirportAdmin;  
grant select on passenger_seq to AirportAdmin;  
grant select on baggage_id_seq to AirportAdmin;
grant select on airport_seq to AirportAdmin;  

grant select on flight_seq to AirportAdmin;  
grant select on schedule_seq to AirportAdmin;  
grant select on terminal_seq to AirportAdmin; 
grant select on ticket_seq to AirportAdmin; 




grant select on airline_staff_seq to AirportAdmin;


grant alter on airline_staff_seq to AirportAdmin;
grant alter on airline_seq to AirportAdmin;
grant alter on airline_route_sequence to AirportAdmin;
grant alter on orders_seq to AirportAdmin;
--grant alter on flight_seq to AirportAdmin;  
grant alter on passenger_seq to AirportAdmin;
grant alter on baggage_id_seq to AirportAdmin;
grant alter on airport_seq to AirportAdmin;
grant alter on flight_seq to AirportAdmin;  
grant alter on schedule_seq to AirportAdmin;  
grant alter on terminal_seq to AirportAdmin; 
grant alter on ticket_seq to AirportAdmin; 
---- Reset Sequences
--alter sequence my_sequence restart start with 1;
--alter sequence airline_route_sequence restart start with 10;
--alter sequence orders_seq restart start with 1;
----alter sequence flight_seq restart start with 1;
--alter sequence passenger_seq restart start with 1;
--alter sequence baggage_id_seq restart start with 1;

--DELETE
--from user_constraints
--where table_name = 'FLIGHT';
--GRANT CREATE SESSION TO AirportAdmin
--GRANT UNLIMITED TABLESPACE TO AirportAdmin
--GRANT CREATE TABLE TO AirportAdmin
--GRANT CREATE PROCEDURE TO AirportAdmin
--GRANT CREATE SEQUENCE TO AirportAdmin
--GRANT CREATE TRIGGER TO AirportAdmin
--GRANT CREATE ANY VIEW TO AirportAdmin  
--GRANT CREATE ROLE TO AirportAdmin
