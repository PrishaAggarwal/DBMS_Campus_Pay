
-- CampusPay
-- Processes a payment using the student's RFID card

CREATE OR REPLACE PROCEDURE process_payment (
    p_device_id IN VARCHAR2,
    p_card_uid IN VARCHAR2,
    p_amount IN NUMBER
)
AS
    v_roll_no users.roll_no%TYPE;
    v_merchant_id scanners.merchant_id%TYPE;
    v_balance wallets.balance%TYPE;
    v_is_active wallets.is_active%TYPE;
    v_txn_counter wallets.transaction_counter%TYPE;
    v_wallet_id wallets.wallet_id%TYPE;
    v_merchant_active merchants.is_active%TYPE;
BEGIN
    -- Check the payment amount
    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Payment amount must be greater than zero.');
    END IF;

    -- Identify the merchant using the scanner
    BEGIN
        SELECT merchant_id
        INTO v_merchant_id
        FROM scanners
        WHERE device_id = p_device_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid scanner/device ID.');
    END;

    -- Check whether the merchant is active
    SELECT is_active
    INTO v_merchant_active
    FROM merchants
    WHERE merchant_id = v_merchant_id;

    IF v_merchant_active <> 1 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Merchant is inactive.');
    END IF;

    -- Find the student using the RFID card UID
    BEGIN
        SELECT roll_no
        INTO v_roll_no
        FROM users
        WHERE card_uid = p_card_uid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Student card not found.');
    END;

    -- Lock the student's wallet while processing the payment
    BEGIN
        SELECT wallet_id, balance, is_active, transaction_counter
        INTO v_wallet_id, v_balance, v_is_active, v_txn_counter
        FROM wallets
        WHERE roll_no = v_roll_no
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20005, 'Student wallet not found.');
    END;

    IF v_is_active <> 1 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Student wallet is inactive.');
    END IF;

    IF v_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20007, 'Insufficient wallet balance.');
    END IF;

    -- Lock the merchant wallet before crediting it
    BEGIN
        SELECT balance
        INTO v_balance
        FROM merchant_wallets
        WHERE merchant_id = v_merchant_id
          AND is_active = 1
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20008, 'Merchant wallet not found or inactive.');
    END;

    -- Debit the student's wallet
    UPDATE wallets
    SET balance = balance - p_amount,
        transaction_counter = transaction_counter + 1,
        last_updated = SYSTIMESTAMP
    WHERE wallet_id = v_wallet_id;

    -- Credit the merchant wallet
    UPDATE merchant_wallets
    SET balance = balance + p_amount,
        last_updated = SYSTIMESTAMP
    WHERE merchant_id = v_merchant_id
      AND is_active = 1;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Unable to credit merchant wallet.');
    END IF;

    -- Record the payment
    INSERT INTO transactions (
        txn_id, roll_no, amount, txn_time,
        txn_counter, device_id, settlement_id
    )
    VALUES (
        transactions_seq.NEXTVAL, v_roll_no, p_amount,
        SYSTIMESTAMP, v_txn_counter + 1, p_device_id, NULL
    );

    DBMS_OUTPUT.PUT_LINE('Payment successful.');
    DBMS_OUTPUT.PUT_LINE('Student roll number: ' || v_roll_no);
    DBMS_OUTPUT.PUT_LINE('Amount paid: ' || p_amount);

    -- Commit or rollback is handled by the caller.

EXCEPTION
    WHEN OTHERS THEN
        -- The caller can roll back if an error occurs.
        RAISE;
END;
/

