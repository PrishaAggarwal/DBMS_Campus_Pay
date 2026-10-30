# CampusPay – Campus Prepaid Wallet System

## Overview

CampusPay is a database-driven prepaid wallet system designed for college campuses. Students use RFID cards to identify their accounts and make payments at campus merchants.

The system maintains student wallet balances, records transactions, verifies top-ups and tracks merchant settlements.

This project focuses on the database and backend logic using Oracle SQL and PL/SQL. RFID hardware, the POS interface and actual bank transfers are outside the current implementation.

## Features

* Student registration and RFID card mapping
* Individual student wallets
* Wallet balance and transaction history
* Top-up requests with verification
* RFID-based student payments
* Automatic debit from student wallets and credit to merchant wallets
* Active and inactive wallet management
* Merchant settlement tracking
* SQL queries for transaction and wallet analysis

## Database Design

The project uses eight tables.

| Table              | Purpose                                   |
| ------------------ | ----------------------------------------- |
| `users`            | Stores student details and RFID card UIDs |
| `wallets`          | Maintains student wallet balances         |
| `merchants`        | Stores merchant information               |
| `merchant_wallets` | Tracks money collected by merchants       |
| `scanners`         | Maps scanner devices to merchants         |
| `transactions`     | Records student payments                  |
| `topups`           | Records wallet top-up requests            |
| `settlements`      | Tracks merchant settlement records        |

## Payment Workflow

1. The student presents their RFID card.
2. The scanner identifies the merchant.
3. The card UID is mapped to the student's roll number.
4. The system checks whether the student wallet is active.
5. The system checks whether sufficient balance is available.
6. The amount is deducted from the student's wallet.
7. The merchant wallet is credited.
8. The transaction is recorded.

The payment procedure uses row locking to protect wallet updates from conflicting transactions.

## Top-up Workflow

1. A top-up request is created with `PENDING` status.
2. The payment details are verified by an administrator.
3. If approved, the wallet is credited and the status changes to `VERIFIED`.
4. If rejected, the status changes to `REJECTED` and the wallet is not credited.

## Merchant Settlement

Unsettled transactions are grouped into a settlement record. Each transaction is linked to a settlement using `settlement_id`, preventing it from being included in another settlement.

Settlements can be approved and marked completed after the external bank transfer has been confirmed. Actual bank integration is not implemented.

## Project Structure

```text
DBMS_Campus_Pay/
├── README.md
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_insert_sample_data.sql
│   ├── 03_views_and_queries.sql
│   ├── 04_topup_procedures.sql
│   ├── 05_payment_procedures.sql
│   ├── 06_merchant_settlement.sql
│   └── 07_test_cases.sql
├── docs/
│   ├── CampusPay_Design.docx
│   └── CampusPay_Report.pdf
├── .gitignore
└── .gitattributes
```

## Technologies Used

* Oracle SQL
* PL/SQL
* Relational database design
* Primary keys, foreign keys and constraints
* Stored procedures
* Transactions and row locking

## Running the Project

Run the SQL files in the following order using an Oracle database:

1. `01_create_tables.sql`
2. `02_insert_sample_data.sql`
3. `03_views_and_queries.sql`
4. `04_topup_procedures.sql`
5. `05_payment_procedures.sql`
6. `06_merchant_settlement.sql`
7. `07_test_cases.sql`

The first file creates the tables, and the second inserts sample data. The procedure files create the backend operations. The test file contains example queries and procedure calls.

The scripts are intended for a fresh database schema. Do not rerun the table creation and sample data scripts after successful execution without resetting the schema.

## Limitations

* RFID hardware and POS integration are not implemented.
* Top-up verification is represented through a database procedure.
* Actual bank transfers are external to the system.
* Sample data is for demonstration purposes.

## Future Scope

* Integration with RFID readers and POS devices
* Secure payment gateway integration
* Automated top-up verification
* Merchant settlement automation
* A web interface for students and administrators

