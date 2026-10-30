
-- CampusPay
-- Queries to check wallet balances, payments and top-ups

-- 1. View all students and their wallet balances
SELECT u.roll_no, u.name, w.balance, w.is_active
FROM users u
JOIN wallets w ON u.roll_no = w.roll_no
ORDER BY u.roll_no;


-- 2. Check the balance of a particular student
SELECT u.roll_no, u.name, w.balance
FROM users u
JOIN wallets w ON u.roll_no = w.roll_no
WHERE u.roll_no = 1;


-- 3. View transaction history of a student
SELECT t.txn_id, t.roll_no, t.amount, t.txn_time,
       s.location, t.txn_counter
FROM transactions t
JOIN scanners s ON t.device_id = s.device_id
WHERE t.roll_no = 1
ORDER BY t.txn_time DESC;


-- 4. Find students with a wallet balance below Rs. 900
SELECT u.roll_no, u.name, w.balance
FROM users u
JOIN wallets w ON u.roll_no = w.roll_no
WHERE w.balance < 900
ORDER BY w.balance;


-- 5. View transactions made through a particular scanner
SELECT t.txn_id, u.name, t.amount, t.txn_time, s.location
FROM transactions t
JOIN users u ON t.roll_no = u.roll_no
JOIN scanners s ON t.device_id = s.device_id
WHERE t.device_id = 'SCANNER_001'
ORDER BY t.txn_time DESC;


-- 6. View all transactions made between 4 PM and 7 PM
SELECT t.txn_id, t.roll_no, t.amount, t.txn_time, s.location
FROM transactions t
JOIN scanners s ON t.device_id = s.device_id
WHERE TO_CHAR(t.txn_time, 'HH24:MI') >= '16:00'
  AND TO_CHAR(t.txn_time, 'HH24:MI') < '19:00'
ORDER BY t.txn_time;


-- 7. View top-up history with student details
SELECT tp.topup_id, u.roll_no, u.name, tp.amount,
       tp.payment_method, tp.ref_txn_id, tp.topup_status,
       tp.topup_time
FROM topups tp
JOIN users u ON tp.roll_no = u.roll_no
ORDER BY tp.topup_time DESC;


-- 8. Find top-ups waiting for verification
SELECT topup_id, roll_no, amount, payment_method,
       ref_txn_id, topup_time
FROM topups
WHERE topup_status = 'PENDING'
ORDER BY topup_time;


-- 9. Total amount spent by each student
SELECT u.roll_no, u.name, NVL(SUM(t.amount), 0) AS total_spent
FROM users u
LEFT JOIN transactions t ON u.roll_no = t.roll_no
GROUP BY u.roll_no, u.name
ORDER BY total_spent DESC;


-- 10. Total sales recorded by each merchant
SELECT m.merchant_id, m.merchant_name,
       NVL(SUM(t.amount), 0) AS total_sales
FROM merchants m
LEFT JOIN scanners s ON m.merchant_id = s.merchant_id
LEFT JOIN transactions t ON s.device_id = t.device_id
GROUP BY m.merchant_id, m.merchant_name
ORDER BY total_sales DESC;


-- 11. Check the current balance of each merchant wallet
SELECT m.merchant_id, m.merchant_name, mw.balance,
       mw.is_active
FROM merchants m
JOIN merchant_wallets mw ON m.merchant_id = mw.merchant_id
ORDER BY m.merchant_name;


-- 12. Find transactions that have not been settled yet
SELECT t.txn_id, t.amount, t.txn_time,
       m.merchant_name, t.settlement_id
FROM transactions t
JOIN scanners s ON t.device_id = s.device_id
JOIN merchants m ON s.merchant_id = m.merchant_id
WHERE t.settlement_id IS NULL
ORDER BY t.txn_time;

