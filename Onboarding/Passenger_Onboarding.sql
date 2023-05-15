/*
This Package is used for inserting Passenger data
After a passenger signs up an Order gets generated in the order table
if he is an existing customer his details do not get added again
*/
--ALTER TABLE ticket
--  PARALLEL(DEGREE 1);
CREATE OR REPLACE PACKAGE PASSENGER_ONBOARDING_PKG AS
  PROCEDURE INSERT_PASSENGER(
    P_AGE IN NUMBER,
    P_ADDRESS IN VARCHAR2,
    P_SEX IN VARCHAR2,
    P_GOVT_ID_NOS IN VARCHAR2,
    P_FIRST_NAME IN VARCHAR2,
    P_LAST_NAME IN VARCHAR2,
    P_DOB IN DATE,
    P_CONTACT_NUMBER IN VARCHAR2,
    P_EMAIL IN VARCHAR2
  );
END PASSENGER_ONBOARDING_PKG;
/

CREATE OR REPLACE PACKAGE BODY PASSENGER_ONBOARDING_PKG AS
  PROCEDURE INSERT_PASSENGER(
    P_AGE IN NUMBER,
    P_ADDRESS IN VARCHAR2,
    P_SEX IN VARCHAR2,
    P_GOVT_ID_NOS IN VARCHAR2,
    P_FIRST_NAME IN VARCHAR2,
    P_LAST_NAME IN VARCHAR2,
    P_DOB IN DATE,
    P_CONTACT_NUMBER IN VARCHAR2,
    P_EMAIL IN VARCHAR2
  ) IS
    V_PASSENGER_ID NUMBER;
  BEGIN
 -- validate input parameters
    IF P_AGE IS NULL OR P_ADDRESS IS NULL OR P_SEX IS NULL OR P_GOVT_ID_NOS IS NULL OR P_FIRST_NAME IS NULL OR P_LAST_NAME IS NULL OR P_DOB IS NULL OR P_CONTACT_NUMBER IS NULL OR P_EMAIL IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('All input parameters must be specified');
      RETURN;
    END IF;
    IF P_SEX NOT IN ('Male', 'Female', 'Other') THEN
      DBMS_OUTPUT.PUT_LINE('Sex must be specified as male, female, or other');
      RETURN;
    END IF;
    IF LENGTH(P_GOVT_ID_NOS) != 10 THEN
      DBMS_OUTPUT.PUT_LINE('Govt ID Number must be a 10-digit value');
      RETURN;
    END IF;
    IF LENGTH(P_CONTACT_NUMBER) != 10 THEN
      DBMS_OUTPUT.PUT_LINE('Contact Number must be a 10-digit value');
      RETURN;
    END IF;
    IF REGEXP_LIKE(P_EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Invalid email format');
      RETURN;
    END IF;
 -- check if email is already present in passenger table
    SELECT
      PASSENGER_ID INTO V_PASSENGER_ID
    FROM
      PASSENGER
    WHERE
      EMAIL = P_EMAIL;
 -- if email is already present, insert a new order for the existing passenger
    INSERT INTO ORDERS (
      ORDER_ID,
      PASSENGER_ID,
      AMOUNT,
      STATUS
    ) VALUES (
      ADMIN.ORDERS_SEQ.NEXTVAL,
      V_PASSENGER_ID,
      0,
      'SUCCESS'
    );
    DBMS_OUTPUT.PUT_LINE('Welcome back your Order was created successfully');
    COMMIT;
  EXCEPTION
 -- if email is not present, insert a new passenger and then insert a new order
    WHEN NO_DATA_FOUND THEN
      INSERT INTO PASSENGER (
        PASSENGER_ID,
        AGE,
        ADDRESS,
        SEX,
        GOVT_ID_NOS,
        FIRST_NAME,
        LAST_NAME,
        DOB,
        CONTACT_NUMBER,
        EMAIL
      ) VALUES (
        ADMIN.PASSENGER_SEQ.NEXTVAL,
        P_AGE,
        P_ADDRESS,
        P_SEX,
        P_GOVT_ID_NOS,
        P_FIRST_NAME,
        P_LAST_NAME,
        P_DOB,
        P_CONTACT_NUMBER,
        P_EMAIL
      );
      SELECT
        ADMIN.PASSENGER_SEQ.CURRVAL INTO V_PASSENGER_ID
      FROM
        DUAL;
      INSERT INTO ORDERS (
        ORDER_ID,
        PASSENGER_ID,
        AMOUNT,
        STATUS
      ) VALUES (
        ADMIN.ORDERS_SEQ.NEXTVAL,
        V_PASSENGER_ID,
        0,
        'SUCCESS'
      );
      DBMS_OUTPUT.PUT_LINE('You are now registered and your order was created successfully');
      COMMIT;
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred while inserting data');
      ROLLBACK;
  END INSERT_PASSENGER;
END PASSENGER_ONBOARDING_PKG;
/

SHOW ERRORS;