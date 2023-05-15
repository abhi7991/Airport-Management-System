CREATE OR REPLACE PACKAGE AIRLINE_PKG AS
  PROCEDURE INSERT_AIRLINE (
    V_AIRLINE_CODE IN VARCHAR2,
    V_AIRLINE_NAME IN VARCHAR2
  );
END AIRLINE_PKG;
/

--SELECT
--  ADMIN.AIRLINE_SEQ.NEXTVAL
--FROM
--  DUAL;

CREATE OR REPLACE PACKAGE BODY AIRLINE_PKG AS
  PROCEDURE INSERT_AIRLINE (
    V_AIRLINE_CODE IN VARCHAR2,
    V_AIRLINE_NAME IN VARCHAR2
  ) IS
  v_count NUMBER;
  BEGIN
    IF V_AIRLINE_CODE IS NULL OR V_AIRLINE_NAME IS NULL THEN
 --RAISE_APPLICATION_ERROR(-20001, 'All input parameters must be specified');
      DBMS_OUTPUT.PUT_LINE('All input parameters must be specified');
      return;
    END IF;
    IF REGEXP_LIKE(V_AIRLINE_CODE, '^[a-zA-Z0-9]{2}$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Invalid airline code format');
      return;
      --RAISE_APPLICATION_ERROR(-20006, 'Invalid airline code format');
    END IF;
    SELECT COUNT(*) INTO v_count FROM airlines WHERE airline_code = v_airline_code;
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Airline code already exists');
    RETURN;
    END IF;
    INSERT INTO airlines (airline_id, route_number, airline_code, airline_name)
    VALUES (admin.airline_seq.nextval, admin.airline_route_sequence.nextval, v_airline_code, v_airline_name);
    INSERT INTO AIRLINES (
      AIRLINE_ID,
      ROUTE_NUMBER,
      AIRLINE_CODE,
      AIRLINE_NAME
    ) VALUES (
      ADMIN.AIRLINE_SEQ.NEXTVAL,
      ADMIN.AIRLINE_ROUTE_SEQUENCE.NEXTVAL,
      V_AIRLINE_CODE,
      V_AIRLINE_NAME
    );
    COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occured while inserting airline');
    rollback;
  END insert_airline;

END airline_pkg;
/