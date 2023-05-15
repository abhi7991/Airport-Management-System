# Panchatantra

For Project Submission 3, we have combined all the scripts into one file. Additionally there is an **Admin.sql** file which has to be run.
This enables the role of `Airport Admin` who handles all the data flowing through the system, this role is created by the database administrator. 
The `Airport Admin`is one of the roles under the system. Additionally the Admin file also creates sequences 
and assigns it to `Airport_Admin`.  The final script is called `MainScript` which
**CREATE** tables, **INSERT** sample data into tables, **UPDATE** which updates records. The **DDL** and **DML** scripts have been written in
PL/SQL with in the form of stored procedures. Additionally **VIEWS** have been created with the tables created. The following steps have to be taken
to ensure the script runs with out errors
 
1. Run Admin.sql file - This files creates the role of `Airport_Admin` and adds `sequences` which are used in the code. The file also grants the necessary
priviliges to the user.

2. Run MainScript.sql - This file contains code to clean and create the entire database schema

*Roles are created and the necessary grants and priviliges are performed by the airport admin and the script is present in the secondary file*
