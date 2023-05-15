CREATE OR REPLACE PACKAGE acct_pkg AS
  FUNCTION calculate_total_revenue RETURN FLOAT;
  PROCEDURE update_order_amount(p_order_id IN NUMBER, p_amount IN FLOAT);  
  PROCEDURE update_order_status(p_order_id IN NUMBER, p_status IN VARCHAR2);
END acct_pkg;
/

CREATE OR REPLACE PACKAGE BODY acct_pkg AS
  FUNCTION calculate_total_revenue RETURN FLOAT AS
    total_revenue FLOAT := 0;
  BEGIN
    SELECT SUM(amount) INTO total_revenue
    FROM ORDERS
    WHERE status = 'Completed' or status = 'SUCCESS'; -- you can adjust the status criteria to your specific needs
    
    IF total_revenue IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('No completed orders found.');
    END IF;
    
    RETURN total_revenue;
  END calculate_total_revenue;

  PROCEDURE update_order_amount(p_order_id IN NUMBER, p_amount IN FLOAT) IS
  BEGIN
    IF p_order_id IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('Order ID cannot be null.');
      RETURN;
    END IF;
    
    IF p_amount IS NULL OR p_amount <= 0 THEN
      DBMS_OUTPUT.PUT_LINE('Amount must be a positive value.');
      RETURN;
    END IF;
    
    UPDATE orders
    SET amount = p_amount
    WHERE order_id = p_order_id;
    
    COMMIT;
  END update_order_amount;

  
  PROCEDURE update_order_status(p_order_id IN NUMBER, p_status IN VARCHAR2)
  IS
  BEGIN
    IF p_status NOT IN ('Completed', 'Failed', 'Pending', 'Cancelled') THEN
        DBMS_OUTPUT.PUT_LINE('Invalid status value. Valid values are "completed", "failed", "pending", or "cancelled".'); 
        RETURN;
    END IF;  
  
    UPDATE orders
    SET status = p_status
    WHERE order_id = p_order_id;

    COMMIT;
  END update_order_status;  
END acct_pkg;
/
