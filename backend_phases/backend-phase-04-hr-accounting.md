# Backend Phase 4 — HR, Payroll & Accounting API
## Version: `b0.4.0`

---

## 🎯 Objective
Implement employee management, attendance, piece-rate payroll calculation, and general ledger accounting. Employee Personally Identifiable Information (PII) and salaries must be strictly routed through the Encrypt Engine.

## 📝 Step-by-Step Implementation

### Step 1: HR Database Schema Additions
- [ ] Add `Employee` model: `id`, `encryptedName`, `encryptedPhone`, `encryptedAadhar`, `encryptedBankDetails`, `role`, `department`, `dailyWage` (encrypted).
- [ ] Add `Attendance` model: `id`, `employeeId`, `date`, `checkIn`, `checkOut`, `status`.
- [ ] Add `PieceWork` model: `id`, `employeeId`, `date`, `stageName`, `kgProcessed`, `earnedAmount` (encrypted).
- [ ] Add `Payroll` model: `id`, `employeeId`, `month`, `year`, `totalEarned`, `advanceDeducted`, `netPay` (encrypted).
- [ ] Run `npx prisma migrate dev`.

### Step 2: Employee & Attendance Endpoints
- [ ] **POST / GET / PUT `/api/hr/employees`:** Standard CRUD. Encrypt PII on write, decrypt on read.
- [ ] **POST `/api/hr/attendance/check-in`:** Log worker attendance. Handle duplicate check-ins for the same day.
- [ ] **POST `/api/hr/piece-work`:** Log daily kg processed per worker. Calculate `earnedAmount` based on stage rates.

### Step 3: Payroll Generation Endpoints
- [ ] **POST `/api/hr/payroll/generate`:** (Cron-capable endpoint)
  - Aggregate all `Attendance` and `PieceWork` for a specific `month`/`year` per employee.
  - Calculate `netPay`.
  - Encrypt all financial totals and save to `Payroll` table.
- [ ] **GET `/api/hr/payroll/:employeeId`:** Fetch payslips.

### Step 4: Accounting Database Schema Additions
- [ ] Add `LedgerAccount` model: `id`, `accountName`, `type` (ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE), `balance` (encrypted).
- [ ] Add `Transaction` model: `id`, `date`, `description`, `debitAccountId`, `creditAccountId`, `amount` (encrypted), `referenceId`.
- [ ] Run `npx prisma migrate dev`.

### Step 5: Accounting Endpoints (Double-Entry System)
- [ ] **POST `/api/accounting/transactions`:** Create a double-entry journal.
  - Must ensure `amount` is encrypted.
  - Must update the `balance` of both the Debit and Credit `LedgerAccount`s in a database transaction.
- [ ] **GET `/api/accounting/ledger`:** Fetch the general ledger. Decrypt balances.
- [ ] **POST `/api/accounting/expenses`:** Helper endpoint to log a factory expense (e.g., electricity). Automatically creates the underlying Debit (Expense Account) and Credit (Cash/Bank Account) transaction.

### Step 6: Unit Testing & Validation
- [ ] Test the double-entry accounting constraint (debit must equal credit).
- [ ] Test piece-rate aggregation: create 5 piece-work entries for an employee, call `/payroll/generate`, verify the total matches.
- [ ] Validate that all financial amounts (`amount`, `netPay`, `balance`) exist as cipher text in the DB.

## ✅ Completion Criteria
- Employee PII and salaries are securely encrypted.
- Piece-rate work logs successfully aggregate into monthly payroll.
- Double-entry accounting system correctly updates ledger balances.
