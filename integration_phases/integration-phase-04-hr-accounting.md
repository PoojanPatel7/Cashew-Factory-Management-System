# Integration Phase 4 — HR Payroll & Accounting Ledger
## Version: `i4.0.0`

---

## 🎯 Objective
Connect the worker check-in system, piece-rate logging, and double-entry accounting screens to the backend API.

## 📝 Step-by-Step Implementation

### Step 1: Employee Check-In & Piece Work
- [ ] Create `HrRepository` pointing to `/api/hr`.
- [ ] Update `SelfCheckinPage` to send `POST /api/hr/attendance/check-in`.
- [ ] Update `PieceWorkDailyLogPage`. Submitting the kg shelled must hit `POST /api/hr/piece-work`.
- [ ] Wire up the `PayrollGenerationPage` to fetch the real aggregated payroll numbers from the backend.

### Step 2: Double-Entry Accounting
- [ ] Create `AccountingRepository` pointing to `/api/accounting`.
- [ ] Update the `AddExpensePage`. When creating an expense, automatically map it to a Debit (Expense Account) and Credit (Cash Account) and send to `POST /api/accounting/transactions`.
- [ ] Ensure that the `CashBookPage` correctly fetches and decodes the general ledger.

## ✅ Completion Criteria
- Worker attendance directly updates the backend.
- Creating an expense in the UI creates two balanced, encrypted ledger entries in the database.
