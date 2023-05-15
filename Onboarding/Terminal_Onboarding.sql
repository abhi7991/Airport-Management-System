/*
This Package is used for inserting Terminal data
change below
Once airport is added, different terminals are added to the airport
*/
CREATE OR REPLACE PACKAGE TERMINAL_PKG AS
  PROCEDURE INSERT_TERMINAL(
    IN_TERMINAL_NAME IN VARCHAR2
  );
END TERMINAL_PKG;
/

CREATE OR REPLACE PACKAGE BODY TERMINAL_PKG AS
  PROCEDURE INSERT_TERMINAL(
    IN_TERMINAL_NAME IN VARCHAR2
  ) IS
  BEGIN
 --validate terminal name is null
    IF IN_TERMINAL_NAME IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('All input parameters must be specified');
      RETURN;
    END IF;
 --validate terminal name is not a special character
    IF REGEXP_LIKE(IN_TERMINAL_NAME, '^[a-zA-Z0-9 ]+$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Invalid terminal name');
      RETURN;
    END IF;
    INSERT INTO TERMINAL (
      TERMINAL_ID,
      TERMINAL_NAME
    ) VALUES (
      ADMIN.TERMINAL_SEQ.NEXTVAL,
      IN_TERMINAL_NAME
    );
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred while inserting data');
      ROLLBACK;
  END INSERT_TERMINAL;
END TERMINAL_PKG;
/

SHOW ERRORS;