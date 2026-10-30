
-- CampusPay
-- Testing queries and procedures

-- 1. Check student wallet balance
SELECT roll_no, balance, is_active
FROM wallets
WHERE roll_no = 1;


-- 2. Create a top-up request
EXEC create_topup(1, 500, 'UPI', 'TESTREF001');


-- 3. Verify a top-up
EXEC verify_topup(314, 'VERIFIED');


-- 4. Process a payment
EXEC process_payment('SCANNER_001', '04AA11BB', 200);


-- 5. View student transactions
SELECT txn_id, roll_no, amount, txn_time, device_id, settlement_id
FROM transactions
WHERE roll_no = 1
ORDER BY txn_time DESC;


-- 6. Check merchant wallet balance
SELECT merchant_id, balance, is_active
FROM merchant_wallets
ORDER BY merchant_id;


-- 7. Create a merchant settlement
EXEC create_settlement('M001', DATE '2026-01-01', DATE '2026-12-31');


-- 8. View settlement details
SELECT settlement_id, merchant_id, gross_amount, net_amount, status
FROM settlements
ORDER BY settlement_id;


-- 9. View unsettled transactions
SELECT txn_id, amount, txn_time, device_id
FROM transactions
WHERE settlement_id IS NULL
ORDER BY txn_time;

