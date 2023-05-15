-- TEST CASES FOR AN ACCOUNTANT
set serveroutput on;
EXECUTE airportadmin.acct_pkg.update_order_status(50006,'Completed1');
EXECUTE airportadmin.acct_pkg.update_order_status(50006,'Completed');
select airportadmin.acct_pkg.calculate_total_revenue() from dual;
execute airportadmin.acct_pkg.update_order_amount(50006,-10000);


/*
VIEW 1 
*/
BEGIN
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW  flight_revenue AS
    select sum(a.amount) as Revenue, g.airline_name from airportadmin.orders a
    JOIN airportadmin.ticket t on t.order_id = a.order_id
    JOIN airportadmin.Flight f on f.flight_id = t.flight_id
    JOIN airportadmin.airlines g on g.airline_id = f.airline_id group by g.airline_name order by Revenue desc
    ';
    DBMS_OUTPUT.PUT_LINE('The Flight Schedule was created successfully');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/

-- TEST VIEWS FOR AN ACCOUNTANT
select * from flight_revenue;

-- TEST VIEWS FOR CANCELLED FLIGHTS
select * from airportadmin.flight_schedule where status = 'Cancelled';
select * from airportadmin.flight_schedule;
    

    