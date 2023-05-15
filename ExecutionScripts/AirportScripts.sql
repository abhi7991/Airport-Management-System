set serveroutput on;

--- TEST CASES FOR AIRPORT INSERTS;
EXECUTE airport_pkg.insert_airport('LOG', NULL, 'MA', 'USA');
EXECUTE airport_pkg.insert_airport('LOG 123', 'Boston', 'MA', 'USA');
EXECUTE airport_pkg.insert_airport('LOG', 'Boston', 'MA', 'USA');
EXECUTE airport_pkg.insert_airport('LAX', 'Los Angeles', 'California', 'United States');
select * from airport;

--- TEST CASES FOR AIRPORT UPDATES;
EXECUTE airport_updating_pkg.update_airport(NULL, 'CDN', 'Texas', 'TX', 'USA');
EXECUTE airport_updating_pkg.update_airport(31, 'CDN', 'Texas', 'TX', 'USA');
EXECUTE airport_updating_pkg.update_airport(1, 'CDN', 'Texas 123', 'TX', 'USA');
EXECUTE airport_updating_pkg.update_airport(1, 'CDN', 'Texas', 'TX', 'USA');
select * from airport;

--- TEST CASES FOR AIRPORT DELETES;
EXECUTE airport_deleting_pkg.delete_airport(56);
EXECUTE airport_deleting_pkg.delete_airport(2);
select * from airport;

COMMIT;