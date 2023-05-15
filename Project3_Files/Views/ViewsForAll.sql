/*
View 1 for Passenger Schedule
*/

BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  flight_schedule AS
    select  b.AIRLINE_NAME, a.DESTINATION, a.SOURCE, a.STATUS,c.TERMINAL_ID,
    c.ARRIVAL_TIME,c.DEPARTURE_TIME from FLIGHT a JOIN AIRLINES b on a.AIRLINE_ID = b.AIRLINE_ID
    JOIN SCHEDULE c on a.FLIGHT_ID = c.FLIGHT_ID';
    DBMS_OUTPUT.PUT_LINE('The Flight Schedule was created successfully');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/
GRANT SELECT ON  AIRPORTADMIN.flight_schedule TO PASSENGERUSER;
GRANT SELECT ON  AIRPORTADMIN.flight_schedule TO ACCOUNTANT;
GRANT SELECT ON  AIRPORTADMIN.flight_schedule TO ANALYST;

/*
View 2 The Below block of code creates views from the airline_staff table
-- View 1: number of staff in each airline
*/






CREATE OR REPLACE VIEW airline_staff_counts AS
    SELECT airline_name, COUNT(*) AS num_staff
    FROM airline_staff
    JOIN airlines ON airline_staff.airline_id = airlines.airline_id
    GROUP BY airline_name;

GRANT SELECT ON  AIRPORTADMIN.flight_schedule TO ANALYST;

select * from airline_staff_counts;

/*
View 3 The Below block of code creates views from the ticket table
*/
CREATE OR REPLACE VIEW monthly_ticket_sales AS
SELECT TO_CHAR(date_of_travel, 'YYYY-MM') AS month,
       SUM(Transaction_amount) AS total_sales
FROM ticket
GROUP BY TO_CHAR(date_of_travel, 'YYYY-MM');

GRANT SELECT ON  AIRPORTADMIN.monthly_ticket_sales TO ACCOUNTANT;
GRANT SELECT ON  AIRPORTADMIN.monthly_ticket_sales TO ANALYST;

select * from monthly_ticket_sales;
select * from airlines;