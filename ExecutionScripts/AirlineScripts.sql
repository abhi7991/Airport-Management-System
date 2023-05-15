set serveroutput on;

--Testing onboarding airline
EXECUTE airline_pkg.insert_airline('6E', 'Indigo');
EXECUTE airline_pkg.insert_airline('AI', 'Air India');
EXECUTE airline_pkg.insert_airline(null, 'Air Asia');
EXECUTE airline_pkg.insert_airline('khj', 'Air Asia');
EXECUTE airline_pkg.insert_airline('6E', 'jjr');
EXECUTE airline_pkg.insert_airline('EK', 'jjr');
EXECUTE airline_pkg.insert_airline('SJ', 'Spicejet');
EXECUTE airline_pkg.insert_airline('Wy', '');
EXECUTE airline_pkg.insert_airline('WW', ' ');
select * from airlines;
select * from passenger;
--Testing update airline
EXECUTE update_airline_pkg.update_airline_name(10, '');
EXECUTE update_airline_pkg.update_airline_name(NULL, 'WD6');
--Testing delete airline
EXECUTE delete_airline_pkg.delete_airline(1);
EXECUTE delete_airline_pkg.delete_airline(2);
EXECUTE delete_airline_pkg.delete_airline(4);
EXECUTE delete_airline_pkg.delete_airline(6);