
-- CampusPay: Campus Prepaid Wallet System
-- Creating the tables required for the system

-- Stores student details. The roll number remains the primary key
-- even if a student replaces their RFID card.
CREATE TABLE users (
    roll_no NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone VARCHAR2(15) UNIQUE NOT NULL,
    card_uid VARCHAR2(20) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL
);

-- Stores merchant details and bank information required for settlement.
CREATE TABLE merchants (
    merchant_id VARCHAR2(20) PRIMARY KEY,
    merchant_name VARCHAR2(100) NOT NULL,
    location VARCHAR2(100) NOT NULL,
    bank_account VARCHAR2(50) NOT NULL,
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    settlement_frequency VARCHAR2(20) NOT NULL,
    CHECK (is_active IN (0, 1))
);

-- Each student has one wallet.
-- The balance cannot become negative, and inactive wallets cannot be used.
CREATE TABLE wallets (
    wallet_id NUMBER PRIMARY KEY,
    roll_no NUMBER NOT NULL UNIQUE,
    balance NUMBER(10,2) DEFAULT 0 NOT NULL,
    transaction_counter NUMBER DEFAULT 0,
    last_updated TIMESTAMP NOT NULL,
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    FOREIGN KEY (roll_no) REFERENCES users(roll_no),
    CHECK (balance >= 0),
    CHECK (is_active IN (0, 1))
);

-- Stores the balance collected by each merchant through student payments.
CREATE TABLE merchant_wallets (
    merchant_wallet_id NUMBER PRIMARY KEY,
    merchant_id VARCHAR2(20) NOT NULL UNIQUE,
    balance NUMBER(10,2) DEFAULT 0 NOT NULL,
    is_active NUMBER(1) DEFAULT 1 NOT NULL,
    last_updated TIMESTAMP NOT NULL,
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id),
    CHECK (balance >= 0),
    CHECK (is_active IN (0, 1))
);

-- Each scanner is linked to a merchant so that a payment
-- can be credited to the correct merchant.
CREATE TABLE scanners (
    device_id VARCHAR2(50) PRIMARY KEY,
    merchant_id VARCHAR2(20) NOT NULL,
    location VARCHAR2(100) NOT NULL,
    added_on TIMESTAMP NOT NULL,
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
);

-- Records merchant settlements.
-- Transactions are linked to a settlement after being included in it.
CREATE TABLE settlements (
    settlement_id NUMBER PRIMARY KEY,
    merchant_id VARCHAR2(20) NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    gross_amount NUMBER(12,2) DEFAULT 0 NOT NULL,
    adjustment_amount NUMBER(12,2) DEFAULT 0 NOT NULL,
    net_amount NUMBER(12,2) DEFAULT 0 NOT NULL,
    status VARCHAR2(20) DEFAULT 'PENDING' NOT NULL,
    bank_reference_id VARCHAR2(100),
    settlement_time TIMESTAMP,
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id),
    CHECK (status IN ('PENDING', 'APPROVED', 'COMPLETED', 'FAILED')),
    CHECK (period_end >= period_start),
    CHECK (gross_amount >= 0 AND net_amount >= 0)
);

-- Stores payments made by students using their RFID cards.
-- A NULL settlement_id means that the transaction has not been settled yet.
CREATE TABLE transactions (
    txn_id NUMBER PRIMARY KEY,
    roll_no NUMBER NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    txn_time TIMESTAMP NOT NULL,
    txn_counter NUMBER NOT NULL,
    device_id VARCHAR2(50) NOT NULL,
    settlement_id NUMBER DEFAULT NULL,
    FOREIGN KEY (roll_no) REFERENCES users(roll_no),
    FOREIGN KEY (device_id) REFERENCES scanners(device_id),
    FOREIGN KEY (settlement_id) REFERENCES settlements(settlement_id),
    CHECK (amount > 0)
);

-- Stores wallet top-up requests.
-- The wallet is credited only after the top-up is verified.
CREATE TABLE topups (
    topup_id NUMBER PRIMARY KEY,
    roll_no NUMBER NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    payment_method VARCHAR2(50) NOT NULL,
    ref_txn_id VARCHAR2(50) UNIQUE NOT NULL,
    topup_time TIMESTAMP NOT NULL,
    topup_status VARCHAR2(20) DEFAULT 'PENDING' NOT NULL,
    FOREIGN KEY (roll_no) REFERENCES users(roll_no),
    CHECK (amount > 0),
    CHECK (topup_status IN ('PENDING', 'VERIFIED', 'REJECTED'))
);

