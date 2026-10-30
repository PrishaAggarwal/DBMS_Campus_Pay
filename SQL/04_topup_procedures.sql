
-- CampusPay
-- Procedures for adding money to a student wallet

-- Creates a top-up request.
-- The wallet is not credited at this stage.
CREATE OR REPLACE PROCEDURE create_topup (
    p_roll_no IN NUMBER,
    p_amount IN NUMBER,
    p_payment_method IN VARCHAR2,
    p_ref_txn_id IN VARCHAR2
)
AS
    v_roll_no NUMBER;
BEGIN
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Amount must be greater than zero.');
    END IF;

    IF p_payment_method IS NULL OR p_ref_txn_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20011, 'Payment method and reference ID are required.');
    END IF;

    -- Check whether the student exists
    SELECT roll_no
    INTO v_roll_no
    FROM users
    WHERE roll_no = p_roll_no;

    INSERT INTO topups (
        topup_id, roll_no, amount, payment_method,
        ref_txn_id, topup_time, topup_status
    )
    VALUES (
        topups_seq.NEXTVAL, p_roll_no, p_amount,
        p_payment_method, p_ref_txn_id,
        SYSTIMESTAMP, 'PENDING'
    );

    DBMS_OUTPUT.PUT_LINE('Top-up request created. Waiting for verification.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20012, 'Student does not exist.');
END;
/
 

-- Verifies or rejects a pending top-up.
CREATE OR REPLACE PROCEDURE verify_topup (
    p_topup_id IN NUMBER,
    p_decision IN VARCHAR2
)
AS
    v_roll_no topups.roll_no%TYPE;
    v_amount topups.amount%TYPE;
    v_status topups.topup_status%TYPE;
    v_wallet_balance wallets.balance%TYPE;
    v_wallet_active wallets.is_active%TYPE;
BEGIN
    IF UPPER(p_decision) NOT IN ('VERIFIED', 'REJECTED') THEN
        RAISE_APPLICATION_ERROR(-20013, 'Decision must be VERIFIED or REJECTED.');
    END IF;

    -- Lock the top-up so it cannot be processed twice simultaneously
    SELECT roll_no, amount, topup_status
    INTO v_roll_no, v_amount, v_status
    FROM topups
    WHERE topup_id = p_topup_id
    FOR UPDATE;

    IF v_status <> 'PENDING' THEN
        RAISE_APPLICATION_ERROR(-20014, 'Top-up has already been processed.');
    END IF;

    IF UPPER(p_decision) = 'REJECTED' THEN
        UPDATE topups
        SET topup_status = 'REJECTED'
        WHERE topup_id = p_topup_id;

        DBMS_OUTPUT.PUT_LINE('Top-up rejected.');
        RETURN;
    END IF;

    -- Lock the student's wallet before updating the balance
    SELECT balance, is_active
    INTO v_wallet_balance, v_wallet_active
    FROM wallets
    WHERE roll_no = v_roll_no
    FOR UPDATE;

    IF v_wallet_active <> 1 THEN
        RAISE_APPLICATION_ERROR(-20015, 'Student wallet is inactive.');
    END IF;

    -- Credit the wallet only after verification
    UPDATE wallets
    SET balance = balance + v_amount,
        last_updated = SYSTIMESTAMP
    WHERE roll_no = v_roll_no;

    UPDATE topups
    SET topup_status = 'VERIFIED'
    WHERE topup_id = p_topup_id;

    DBMS_OUTPUT.PUT_LINE('Top-up verified and wallet credited.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20016, 'Top-up or student wallet not found.');
END;
/

