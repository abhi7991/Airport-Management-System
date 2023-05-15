/*
This Package is used for updating terminal data
*/
CREATE OR REPLACE PACKAGE TERMINAL_UPDATING_PKG AS
  PROCEDURE UPDATE_TERMINAL(
    IN_TERMINAL_ID IN NUMBER,
    IN_TERMINAL_NAME IN VARCHAR2
  );
END TERMINAL_UPDATING_PKG;
/

CREATE OR REPLACE PACKAGE BODY TERMINAL_UPDATING_PKG AS
  PROCEDURE UPDATE_TERMINAL(
    IN_TERMINAL_ID IN NUMBER,
    IN_TERMINAL_NAME IN VARCHAR2
  ) IS
    V_COUNT NUMBER;
  BEGIN
    IF IN_TERMINAL_ID IS NULL OR IN_TERMINAL_NAME IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('All input parameters must be specified/can not be empty');
      RETURN;
    END IF;
    IF REGEXP_LIKE(IN_TERMINAL_NAME, '^[a-zA-Z0-9 ]+$') = FALSE THEN
      DBMS_OUTPUT.PUT_LINE('Invalid terminal name');
      RETURN;
    END IF;
    BEGIN
      SELECT
        COUNT(*) INTO V_COUNT
      FROM
        TERMINAL
      WHERE
        TERMINAL_ID = IN_TERMINAL_ID;
      IF V_COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No such terminal ID');
        RETURN;
      END IF;
      UPDATE TERMINAL
      SET
        TERMINAL_NAME = IN_TERMINAL_NAME
      WHERE
        TERMINAL_ID = IN_TERMINAL_ID;
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('Data updated successfully');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No terminal found with the given ID');
        RETURN;
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred while updating the terminal: '
          || SQLERRM);
        ROLLBACK;
        RETURN;
    END;
  END UPDATE_TERMINAL;
END TERMINAL_UPDATING_PKG;
/

SHOW ERRORS;