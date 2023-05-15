set serveroutput on

--- TEST CASES FOR FLIGHT INSERTS;

--flight type null
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('',  TO_TIMESTAMP('2023-04-21 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-04-22 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOM', 'LHR', 'On Time', 300, 3, 0, 6001);
--source and destination null
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Boeing 737',  TO_TIMESTAMP('2023-04-17 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-04-18 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), '', 'BOS', 'Delayed', 150, 2, 0, 6002);
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Boeing 747',  TO_TIMESTAMP('2023-04-23 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-04-24 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SIN', '', 'On Time', 300, 1, 0, 6000);
--previous deptarture and arrival
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Embraer E175',  TO_TIMESTAMP('2023-05-21 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-05-22 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'DXB', 'BOS', 'Cancelled', 80, 3, 0, 6002);
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Airbus A320',  TO_TIMESTAMP('2023-04-24 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-04-25 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'LHR', 'BOS', 'On Time', 300, 2, 0, 6001);

--Test case with valid inputs:
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Boeing 747', TO_TIMESTAMP('2023-05-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-05-02 06:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'LHR', 'JFK', 'Delayed', 400, 1, 0, 6000);
--Test case with departure time after arrival time:
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Airbus A380', TO_TIMESTAMP('2023-06-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-06-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SYD', 'LAX', 'On Time', 500, 2, 0, 6001);
--Test case with invalid destination airport code:
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Boeing 737', TO_TIMESTAMP('2023-07-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-07-01 18:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'XYZ', 'LAX', 'On Time', 200, 3, 0, 6002);
--Test case with invalid source airport code:
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Airbus A330', TO_TIMESTAMP('2023-08-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-08-02 12:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOM', 'XYZ', 'Delayed', 300, 4, 0, 6001);
--Test case with empty flight type:
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('', TO_TIMESTAMP('2023-09-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-09-02 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOM', 'LHR', 'On Time', 300, 5, 5, 6000);
--Test case with negative number of passengers:
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Airbus A340', TO_TIMESTAMP('2023-10-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-10-02 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOM', 'LHR', 'On Time', -100, 6, 0, 6002);
--Test case with negative airline ID:
EXECUTE airportadmin.ONBOARD_FLIGHT_PKG.INSERT_FLIGHT('Boeing 767', TO_TIMESTAMP('2023-11-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2023-11-02 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'BOM', 'LHR', 'Delayed', 100, -6, 0, 6000);


--TEST CASES FOR FLIGHT UPDATES;


EXECUTE airportadmin.flight_updating_pkg.update_flight(4004, 'Airbus A380', 'LHR', 'BOS', 'Delayed', 300, 2, 0);
--inavlid source
EXECUTE airportadmin.flight_updating_pkg.update_flight(4004, 'Airbus A380', 'XAT', 'BOS', 'On Time', 300, 2, 0);
--inavlid destination
EXECUTE airportadmin.flight_updating_pkg.update_flight(4004, 'Airbus A380', 'LHR', 'TAP', 'On Time', 300, 2, 0);
--invalid flight id
EXECUTE airportadmin.flight_updating_pkg.update_flight(4, 'Airbus A380', 'LHR', 'TAP', 'On Time', 300, 2, 0);
--invalid pax
EXECUTE airportadmin.flight_updating_pkg.update_flight(4004, 'Airbus A380', 'LHR', 'TAP', 'On Time', 0, 2, 0);
--invalid pax
EXECUTE airportadmin.flight_updating_pkg.update_flight(4003, '', 'LHR', 'TAP', 'On Time', 0, 2, 0);


--TEST CASES FOR FLIGHT DELETE

EXECUTE airportadmin.FLIGHT_DELETE_PKG.delete_flight(4003);
/



--TEST CASES FOR TICKET INSERT

EXECUTE airportadmin.ONBOARD_TICKET_PKG.INSERT_TICKET(50008, 4004, 'B7', 'Vegetarian', 'LHR', 'BOS', TO_DATE('2023-04-25', 'YYYY-MM-DD'), 'Business Pro', 'Cash', 2345,350.00);

--invalid source and destination
EXECUTE airportadmin.ONBOARD_TICKET_PKG.INSERT_TICKET(50002, 4000, 'P6', 'Gluten Free', 'ABC', 'LHR', TO_DATE('2023-04-16', 'YYYY-MM-DD'), 'Business', 'Cash', 2345, 250.00);
EXECUTE airportadmin.ONBOARD_TICKET_PKG.INSERT_TICKET(50003, 4001, 'P5', 'Vegetarian', 'BOM', 'THE', TO_DATE('2023-04-17', 'YYYY-MM-DD'), 'Business Pro', 'Cash', 2345, 350.00);
--invalid class
EXECUTE airportadmin.ONBOARD_TICKET_PKG.INSERT_TICKET(50003, 4002, 'E6', 'Non-Vegetarian', 'SIN', 'LAX', TO_DATE('2023-04-19', 'YYYY-MM-DD'), '', 'Cash', 2345, 150.00);
--invalid cash
EXECUTE airportadmin.ONBOARD_TICKET_PKG.INSERT_TICKET(50004, 4004, 'A6', 'Vegan', 'DXB', 'BOS', TO_DATE('2023-04-25', 'YYYY-MM-DD'), 'First Class', 'Cash', 2345, 0.0);
--invalid order_id
EXECUTE airportadmin.ONBOARD_TICKET_PKG.INSERT_TICKET(0, 4004, 'B7', 'Vegetarian', 'LHR', 'BOS', TO_DATE('2023-04-25', 'YYYY-MM-DD'), 'Business Pro', 'Cash', 2345, 350.00);
--previous date
EXECUTE airportadmin.ONBOARD_TICKET_PKG.INSERT_TICKET(0, 4004, 'B7', 'Vegetarian', 'LHR', 'BOS', TO_DATE('2023-04-11', 'YYYY-MM-DD'), 'Business Pro', 'Cash', 2345, 350.00);

--TEST CASES FOR TICKET UPDATE
--update class
EXECUTE airportadmin.UPDATE_TICKET_PKG.update_ticket(7001, 50002, 4000, 'P6', 'Gluten Free', 'BOM', 'LHR', TO_DATE('2023-04-16', 'YYYY-MM-DD'), 'Business Pro', 'Cash', 2345);
--invalid class
EXECUTE airportadmin.UPDATE_TICKET_PKG.update_ticket(7001, 50002, 4000, 'P6', 'Gluten Free', 'BOM', 'LHR', TO_DATE('2023-04-16', 'YYYY-MM-DD'), '', 'Cash', 2345);
--previos source and destination
EXECUTE airportadmin.UPDATE_TICKET_PKG.update_ticket(7001, 50002, 4000, 'P6', 'Gluten Free', 'ABC', 'LHR', TO_DATE('2023-04-16', 'YYYY-MM-DD'), 'Business', 'Cash', 2345);
EXECUTE airportadmin.UPDATE_TICKET_PKG.update_ticket(7002, 50003, 4002, 'E6', 'Non-Vegetarian', 'SIN', 'THE', TO_DATE('2023-04-19', 'YYYY-MM-DD'), 'Economy', 'Cash', 2345);
--invalid cash
EXECUTE airportadmin.UPDATE_TICKET_PKG.update_ticket(7002, 50004, 4004, 'A6', 'Vegan', 'DXB', 'BOS', TO_DATE('2023-04-25', 'YYYY-MM-DD'), 'First Class', 'Cash', 2345);
--invalid order_id/

--TEST CASES FOR DELETE TICKET
EXECUTE airportadmin.ORDER_DELETE_PKG.delete_order(50008);
--EXECUTE airportadmin.ORDER_DELETE_PKG.delete_order(5000);


