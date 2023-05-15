/*
This Package is used for onboarding airline_staff data
Airline staff is onboarded once airport and airline is added. Each staff has a unique ID.
*/

CREATE OR REPLACE PACKAGE AIRLINE_STAFF_PKG AS
  FUNCTION CHECK_AIRLINE_ID_EXISTS(
    IN_AIRLINE_ID IN NUMBER
  ) RETURN NUMBER;
  PROCEDURE INSERT_AIRLINE_STAFF(
    IN_AIRLINE_ID IN NUMBER,
    IN_FIRST_NAME IN VARCHAR2,
    IN_LAST_NAME IN VARCHAR2,
    IN_ADDRESS IN VARCHAR2,
    IN_SSN IN VARCHAR2,
    IN_EMAIL_ID IN VARCHAR2,
    IN_CONTACT_NUMBER IN NUMBER,
    IN_JOB_GROUP IN NUMBER,
    IN_GENDER IN VARCHAR2
  );
END AIRLINE_STAFF_PKG;
/

CREATE OR REPLACE PACKAGE BODY AIRLINE_STAFF_PKG AS
  FUNCTION CHECK_AIRLINE_ID_EXISTS(
    IN_AIRLINE_ID NUMBER
  ) RETURN NUMBER AS
    V_AIRLINE_COUNT NUMBER;
  BEGIN
    SELECT
      COUNT(*) INTO V_AIRLINE_COUNT
    FROM
      AIRLINES
    WHERE
      AIRLINE_ID = IN_AIRLINE_ID;
    IF V_AIRLINE_COUNT > 0 THEN
      RETURN IN_AIRLINE_ID;
    ELSE
      RETURN NULL;
    END IF;
  END CHECK_AIRLINE_ID_EXISTS;
  PROCEDURE INSERT_AIRLINE_STAFF(
    IN_AIRLINE_ID IN NUMBER,
    IN_FIRST_NAME IN VARCHAR2,
    IN_LAST_NAME IN VARCHAR2,
    IN_ADDRESS IN VARCHAR2,
    IN_SSN IN VARCHAR2,
    IN_EMAIL_ID IN VARCHAR2,
    IN_CONTACT_NUMBER IN NUMBER,
    IN_JOB_GROUP IN NUMBER,
    IN_GENDER IN VARCHAR2
  ) IS
    INVALID_INPUTS EXCEPTION;
    AIRLINE_ID_EXISTS NUMBER;
  BEGIN
    IF IN_AIRLINE_ID IS NULL OR IN_GENDER IS NULL OR IN_FIRST_NAME IS NULL OR IN_LAST_NAME IS NULL OR IN_ADDRESS IS NULL OR IN_SSN IS NULL OR IN_EMAIL_ID IS NULL OR IN_CONTACT_NUMBER IS NULL OR IN_JOB_GROUP IS NULL THEN
      RAISE INVALID_INPUTS;
    END IF;
 --validate if airline ID exists before pushing into airline staff table
    AIRLINE_ID_EXISTS := CHECK_AIRLINE_ID_EXISTS(IN_AIRLINE_ID);
    IF AIRLINE_ID_EXISTS IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('Airline ID does not exist');
      RETURN;
    END IF;
 -- Validate gender
    IF IN_GENDER NOT IN ('Male', 'Female', 'Other') THEN
      DBMS_OUTPUT.PUT_LINE('Sex must be specified as male, female, or other');
      RETURN;
    END IF;
 -- Validate job group
    IF IN_JOB_GROUP NOT IN (1, 2, 3, 4, 5) THEN
      DBMS_OUTPUT.PUT_LINE('Incorrect job group');
      RETURN;
    END IF;
 -- Validate SSN input
    IF NOT REGEXP_LIKE(IN_SSN, '^[[:digit:]]{3}-[[:digit:]]{2}-[[:digit:]]{4}$') THEN
      DBMS_OUTPUT.PUT_LINE('Invalid SSN format');
      RETURN;
    END IF;
 -- Validate first name input
    IF REGEXP_LIKE(IN_FIRST_NAME, '^[a-zA-Z ]+$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Invalid first name');
      RETURN;
    END IF;
 -- Validate last name input
    IF REGEXP_LIKE(IN_LAST_NAME, '^[a-zA-Z ]+$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Invalid last name');
      RETURN;
    END IF;
 -- Validate contact_number input
    IF LENGTH(IN_CONTACT_NUMBER) != 10 THEN
      DBMS_OUTPUT.PUT_LINE('Contact Number must be a 10-digit value');
      RETURN;
    END IF;
 -- Validate address input
    IF REGEXP_LIKE(IN_ADDRESS, '^[0-9]{1,5} [a-zA-Z0-9\s]{1,50}, [a-zA-Z\s]{2,50}, [A-Z]{2} [0-9]{5}$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Address must be in the format ex., 23 XYZ, Boston, MA 02115');
      RETURN;
    END IF;
 -- Validate email input
    IF REGEXP_LIKE(IN_EMAIL_ID, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Invalid email format');
      RETURN;
    END IF;
    INSERT INTO AIRLINE_STAFF (
      STAFF_ID,
      AIRLINE_ID,
      FIRST_NAME,
      LAST_NAME,
      ADDRESS,
      SSN,
      EMAIL_ID,
      CONTACT_NUMBER,
      JOB_GROUP,
      GENDER
    ) VALUES (
      ADMIN.AIRLINE_STAFF_SEQ.NEXTVAL,
      IN_AIRLINE_ID,
      IN_FIRST_NAME,
      IN_LAST_NAME,
      IN_ADDRESS,
      IN_SSN,
      IN_EMAIL_ID,
      IN_CONTACT_NUMBER,
      IN_JOB_GROUP,
      IN_GENDER
    );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred while inserting data');
      ROLLBACK;
      RETURN;
  END INSERT_AIRLINE_STAFF;
END AIRLINE_STAFF_PKG;
/

SHOW ERRORS;