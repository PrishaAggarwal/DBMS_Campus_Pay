
-- CampusPay
-- Inserting sample data for students, merchants, wallets and transactions

-- 1. Student details
INSERT ALL
    INTO users VALUES (1, 'Aarav Sharma', 'aarav@example.com', '9876500001', '04AA11BB', SYSTIMESTAMP)
    INTO users VALUES (2, 'Ananya Gupta', 'ananya@example.com', '9876500002', '04AA22BB', SYSTIMESTAMP)
    INTO users VALUES (3, 'Rohan Verma', 'rohan@example.com', '9876500003', '04AA33BB', SYSTIMESTAMP)
    INTO users VALUES (4, 'Ishita Kapoor', 'ishita@example.com', '9876500004', '04AA44BB', SYSTIMESTAMP)
    INTO users VALUES (5, 'Arjun Mehta', 'arjun@example.com', '9876500005', '04AA55BB', SYSTIMESTAMP)
    INTO users VALUES (6, 'Diya Singh', 'diya@example.com', '9876500006', '04AA66BB', SYSTIMESTAMP)
    INTO users VALUES (7, 'Kabir Malhotra', 'kabir@example.com', '9876500007', '04AA77BB', SYSTIMESTAMP)
    INTO users VALUES (8, 'Meera Joshi', 'meera@example.com', '9876500008', '04AA88BB', SYSTIMESTAMP)
    INTO users VALUES (9, 'Aditya Rao', 'aditya@example.com', '9876500009', '04AA99BB', SYSTIMESTAMP)
    INTO users VALUES (10, 'Sana Khan', 'sana@example.com', '9876500010', '04AABBCC', SYSTIMESTAMP)
SELECT 1 FROM dual;


-- 2. Merchant details
-- Demo bank account values are used instead of real account details.
INSERT ALL
    INTO merchants VALUES ('M001', 'Kravings - Dominoes', 'Campus Food Court', 'DEMO-ACCT-M001', 1, 'DAILY')
    INTO merchants VALUES ('M002', 'Aahar', 'Campus Canteen', 'DEMO-ACCT-M002', 1, 'DAILY')
    INTO merchants VALUES ('M003', 'TSLAS Canteen', 'Academic Block', 'DEMO-ACCT-M003', 1, 'DAILY')
    INTO merchants VALUES ('M004', 'Library Kiosk', 'Library', 'DEMO-ACCT-M004', 1, 'WEEKLY')
    INTO merchants VALUES ('M005', 'Just Foodz', 'Campus Market', 'DEMO-ACCT-M005', 1, 'DAILY')
    INTO merchants VALUES ('M006', 'Bombay Munchery', 'Campus Market', 'DEMO-ACCT-M006', 1, 'DAILY')
    INTO merchants VALUES ('M007', 'Shadowz Saloon', 'Campus Market', 'DEMO-ACCT-M007', 1, 'WEEKLY')
    INTO merchants VALUES ('M008', 'Hostel C Mess', 'Hostel C', 'DEMO-ACCT-M008', 1, 'DAILY')
    INTO merchants VALUES ('M009', 'Waterfront Cafe', 'Campus Cafe', 'DEMO-ACCT-M009', 1, 'DAILY')
    INTO merchants VALUES ('M010', 'Jaggi', 'Campus Market', 'DEMO-ACCT-M010', 1, 'DAILY')
SELECT 1 FROM dual;


-- 3. Student wallets
INSERT ALL
    INTO wallets VALUES (101, 1, 892, 2, SYSTIMESTAMP, 1)
    INTO wallets VALUES (102, 2, 1250, 3, SYSTIMESTAMP, 1)
    INTO wallets VALUES (103, 3, 450, 1, SYSTIMESTAMP, 1)
    INTO wallets VALUES (104, 4, 1750, 2, SYSTIMESTAMP, 1)
    INTO wallets VALUES (105, 5, 300, 1, SYSTIMESTAMP, 1)
    INTO wallets VALUES (106, 6, 980, 2, SYSTIMESTAMP, 1)
    INTO wallets VALUES (107, 7, 2100, 4, SYSTIMESTAMP, 1)
    INTO wallets VALUES (108, 8, 650, 1, SYSTIMESTAMP, 1)
    INTO wallets VALUES (109, 9, 1100, 3, SYSTIMESTAMP, 1)
    INTO wallets VALUES (110, 10, 750, 2, SYSTIMESTAMP, 1)
SELECT 1 FROM dual;


-- 4. Scanner details
-- Each scanner is associated with the merchant receiving the payment.
INSERT ALL
    INTO scanners VALUES ('SCANNER_001', 'M001', 'Kravings - Dominoes', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_002', 'M002', 'Aahar', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_003', 'M003', 'TSLAS Canteen', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_004', 'M004', 'Library', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_005', 'M005', 'Just Foodz', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_006', 'M006', 'Bombay Munchery', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_007', 'M007', 'Shadowz Saloon', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_008', 'M008', 'Hostel C Mess', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_009', 'M009', 'Waterfront Cafe', SYSTIMESTAMP)
    INTO scanners VALUES ('SCANNER_010', 'M010', 'Jaggi', SYSTIMESTAMP)
SELECT 1 FROM dual;


-- 5. Merchant wallets
-- Initial balances represent the value of the sample transactions below.
INSERT ALL
    INTO merchant_wallets VALUES (1001, 'M001', 266, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1002, 'M002', 235, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1003, 'M003', 20, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1004, 'M004', 13, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1005, 'M005', 215, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1006, 'M006', 70, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1007, 'M007', 200, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1008, 'M008', 75, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1009, 'M009', 110, 1, SYSTIMESTAMP)
    INTO merchant_wallets VALUES (1010, 'M010', 140, 1, SYSTIMESTAMP)
SELECT 1 FROM dual;


-- 6. Sample payment transactions
-- NULL settlement_id means these transactions have not been settled yet.
INSERT ALL
    INTO transactions VALUES (201, 1, 108, SYSTIMESTAMP, 1, 'SCANNER_001', NULL)
    INTO transactions VALUES (202, 2, 158, SYSTIMESTAMP, 1, 'SCANNER_001', NULL)
    INTO transactions VALUES (203, 3, 130, SYSTIMESTAMP, 1, 'SCANNER_002', NULL)
    INTO transactions VALUES (204, 4, 105, SYSTIMESTAMP, 1, 'SCANNER_002', NULL)
    INTO transactions VALUES (205, 5, 20, SYSTIMESTAMP, 1, 'SCANNER_003', NULL)
    INTO transactions VALUES (206, 6, 13, SYSTIMESTAMP, 1, 'SCANNER_004', NULL)
    INTO transactions VALUES (207, 7, 215, SYSTIMESTAMP, 1, 'SCANNER_005', NULL)
    INTO transactions VALUES (208, 8, 70, SYSTIMESTAMP, 1, 'SCANNER_006', NULL)
    INTO transactions VALUES (209, 9, 200, SYSTIMESTAMP, 1, 'SCANNER_007', NULL)
    INTO transactions VALUES (210, 10, 75, SYSTIMESTAMP, 1, 'SCANNER_008', NULL)
    INTO transactions VALUES (211, 1, 30, SYSTIMESTAMP, 2, 'SCANNER_009', NULL)
    INTO transactions VALUES (212, 2, 65, SYSTIMESTAMP, 2, 'SCANNER_009', NULL)
    INTO transactions VALUES (213, 3, 15, SYSTIMESTAMP, 2, 'SCANNER_009', NULL)
    INTO transactions VALUES (214, 4, 35, SYSTIMESTAMP, 2, 'SCANNER_010', NULL)
    INTO transactions VALUES (215, 5, 60, SYSTIMESTAMP, 2, 'SCANNER_010', NULL)
    INTO transactions VALUES (216, 6, 45, SYSTIMESTAMP, 2, 'SCANNER_010', NULL)
SELECT 1 FROM dual;


-- 7. Sample top-up records
-- These are historical top-ups, so they are marked as VERIFIED.
INSERT ALL
    INTO topups VALUES (301, 1, 1000, 'UPI', 'REF301', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (302, 2, 1000, 'UPI', 'REF302', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (303, 3, 1000, 'UPI', 'REF303', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (304, 4, 1000, 'UPI', 'REF304', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (305, 5, 1000, 'UPI', 'REF305', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (306, 6, 1000, 'UPI', 'REF306', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (307, 7, 1000, 'UPI', 'REF307', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (308, 8, 1000, 'UPI', 'REF308', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (309, 9, 1000, 'UPI', 'REF309', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (310, 10, 1000, 'UPI', 'REF310', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (311, 1, 100, 'GPay', 'REF311', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (312, 2, 525, 'GPay', 'REF312', SYSTIMESTAMP, 'VERIFIED')
    INTO topups VALUES (313, 3, 300, 'UPI', 'REF313', SYSTIMESTAMP, 'VERIFIED')
SELECT 1 FROM dual;


-- 8. Sequences used to generate IDs for new records
CREATE SEQUENCE transactions_seq START WITH 217 INCREMENT BY 1;
CREATE SEQUENCE topups_seq START WITH 314 INCREMENT BY 1;
CREATE SEQUENCE wallets_seq START WITH 111 INCREMENT BY 1;
CREATE SEQUENCE merchant_wallets_seq START WITH 1011 INCREMENT BY 1;
CREATE SEQUENCE settlements_seq START WITH 5001 INCREMENT BY 1;

COMMIT;

