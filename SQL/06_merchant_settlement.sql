
-- CampusPay
-- Procedures for merchant settlement

-- Creates a settlement using transactions that have not been settled.
CREATE OR REPLACE PROCEDURE create_settlement (
    p_merchant_id IN VARCHAR2,
    p_period_start IN DATE,
    p_period_end IN DATE
)
AS
    v_settlement_id NUMBER;
    v_gross_amount NUMBER(12,2);
    v_merchant_active merchants.is_active%TYPE;
BEGIN
    IF p_period_start IS NULL OR p_period_end IS NULL
       OR p_period_end < p_period_start THEN
        RAISE_APPLICATION_ERROR(-20020, 'Invalid settlement period.');
    END IF;

    -- Check whether the merchant exists and is active
    SELECT is_active
    INTO v_merchant_active
    FROM merchants
    WHERE merchant_id = p_merchant_id;

    IF v_merchant_active <> 1 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Merchant is inactive.');
    END IF;

    -- Calculate sales that have not been settled yet
    SELECT NVL(SUM(t.amount), 0)
    INTO v_gross_amount
    FROM transactions t
    JOIN scanners s ON t.device_id = s.device_id
    WHERE s.merchant_id = p_merchant_id
      AND t.settlement_id IS NULL
      AND t.txn_time >= CAST(p_period_start AS TIMESTAMP)
      AND t.txn_time < CAST(p_period_end + 1 AS TIMESTAMP);

    IF v_gross_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20022, 'No unsettled transactions found.');
    END IF;

    v_settlement_id := settlements_seq.NEXTVAL;

    -- Create a pending settlement record
    INSERT INTO settlements (
        settlement_id, merchant_id, period_start, period_end,
        gross_amount, adjustment_amount, net_amount,
        status, bank_reference_id, settlement_time
    )
    VALUES (
        v_settlement_id, p_merchant_id, p_period_start, p_period_end,
        v_gross_amount, 0, v_gross_amount,
        'PENDING', NULL, NULL
    );

    -- Link each transaction to this settlement
    UPDATE transactions t
    SET settlement_id = v_settlement_id
    WHERE t.settlement_id IS NULL
      AND t.device_id IN (
          SELECT device_id
          FROM scanners
          WHERE merchant_id = p_merchant_id
      )
      AND t.txn_time >= CAST(p_period_start AS TIMESTAMP)
      AND t.txn_time < CAST(p_period_end + 1 AS TIMESTAMP);

    DBMS_OUTPUT.PUT_LINE('Settlement created.');
    DBMS_OUTPUT.PUT_LINE('Settlement ID: ' || v_settlement_id);
    DBMS_OUTPUT.PUT_LINE('Gross amount: ' || v_gross_amount);
END;
/

-- Approves a pending settlement.
CREATE OR REPLACE PROCEDURE approve_settlement (
    p_settlement_id IN NUMBER
)
AS
    v_status settlements.status%TYPE;
BEGIN
    SELECT status
    INTO v_status
    FROM settlements
    WHERE settlement_id = p_settlement_id
    FOR UPDATE;

    IF v_status <> 'PENDING' THEN
        RAISE_APPLICATION_ERROR(-20023, 'Settlement is not pending approval.');
    END IF;

    UPDATE settlements
    SET status = 'APPROVED'
    WHERE settlement_id = p_settlement_id;

    DBMS_OUTPUT.PUT_LINE('Settlement approved.');
END;
/

-- Records completion after the external bank transfer is confirmed.
CREATE OR REPLACE PROCEDURE complete_settlement (
    p_settlement_id IN NUMBER,
    p_bank_reference_id IN VARCHAR2
)
AS
    v_status settlements.status%TYPE;
    v_merchant_id settlements.merchant_id%TYPE;
    v_net_amount settlements.net_amount%TYPE;
    v_wallet_balance merchant_wallets.balance%TYPE;
BEGIN
    IF p_bank_reference_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20024, 'Bank reference ID is required.');
    END IF;

    SELECT status, merchant_id, net_amount
    INTO v_status, v_merchant_id, v_net_amount
    FROM settlements
    WHERE settlement_id = p_settlement_id
    FOR UPDATE;

    IF v_status <> 'APPROVED' THEN
        RAISE_APPLICATION_ERROR(-20025, 'Settlement must be approved first.');
    END IF;

    -- Lock the merchant wallet before reducing its balance
    SELECT balance
    INTO v_wallet_balance
    FROM merchant_wallets
    WHERE merchant_id = v_merchant_id
      AND is_active = 1
    FOR UPDATE;

    IF v_wallet_balance < v_net_amount THEN
        RAISE_APPLICATION_ERROR(-20026, 'Insufficient merchant wallet balance.');
    END IF;

    -- Record the settlement as completed after the transfer is confirmed
    UPDATE merchant_wallets
    SET balance = balance - v_net_amount,
        last_updated = SYSTIMESTAMP
    WHERE merchant_id = v_merchant_id
      AND is_active = 1;

    UPDATE settlements
    SET status = 'COMPLETED',
        bank_reference_id = p_bank_reference_id,
        settlement_time = SYSTIMESTAMP
    WHERE settlement_id = p_settlement_id;

    DBMS_OUTPUT.PUT_LINE('Settlement completed.');
END;
/
