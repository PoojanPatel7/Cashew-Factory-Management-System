# Phase 6 — Accounting & Finance (Weeks 12-13)
## Version: `v0.6.0`

---

## 🎨 UI Reference
- "Accounting dashboard dark theme finance"
- "Profit loss statement UI modern design"
- "Expense tracker mobile dark mode"
- "GST invoice template India design"

## 🔑 Role Access — Accountant-Specific Module

| Feature | Owner | Manager | Supervisor | Accountant | Operator | Worker |
|---|---|---|---|---|---|---|
| Full accounting | ✅ | Read only | ❌ | ✅ | ❌ | ❌ |
| Create expenses | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| Approve expenses | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| View P&L | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| GST reports | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |

---

## Week 12: Ledgers, Expenses & Cash/Bank

### Day 1-2: Ledger & Expense Pages
- [ ] **Accounting Dashboard Page:** Revenue vs Expense bar chart, Cash/Bank balances, Outstanding receivables/payables, Recent transactions
- [ ] **Ledger Page:** Account tree (expandable), tap account → shows all entries with running balance. Date range filter. Export button
- [ ] **Expense List Page:** Category filter chips, date range, status tabs (Pending/Approved/Rejected). "Add Expense" FAB
- [ ] **Add Expense Page:** Category dropdown, amount, description, date, payment mode. Camera for receipt photo upload. **Confirmation popup** with all details. Approval flow: submitted → Manager/Owner approves

### Day 3-4: Cash/Bank Pages
- [ ] **Cash Book Page:** Daily cash in/out entries, running balance. "Add Entry" form with confirmation popup
- [ ] **Bank Account Page:** List bank accounts, current balance per account. Tap → transaction history. Bank reconciliation tool: match statement with ledger entries

### Day 5: Trial Balance
- [ ] **Trial Balance Page:** Auto-generated from ledger. Debit/Credit columns, totals match check. Export to Excel/PDF

---

## Week 13: GST, P&L & Reports

### Day 1-2: GST Pages
- [ ] **GST Dashboard Page:** HSN mapping display (08013100, 08013200). Tax summary: CGST, SGST, IGST totals. Input vs Output credit. GSTR-1 / GSTR-3B data preview. Export buttons for CA
- [ ] **GST Invoice Page:** Auto-generate GST-compliant invoice with all mandatory fields. Preview + PDF download

### Day 3-4: Financial Report Pages
- [ ] **P&L Page:** Expandable sections: Revenue (grade-wise), COGS, Gross Profit, Operating Expenses (category-wise), Net Profit. Period selector (monthly/quarterly/annual). Comparison with previous period
- [ ] **Lot Profitability Page:** Per-lot P&L — what you bought vs what you sold, processing costs. Color-coded: green=profit, red=loss
- [ ] **Grade Profitability Page:** Which grade makes most money (bar chart). Cost vs Revenue per grade
- [ ] **Outstanding Page:** Receivables aging (0-30, 30-60, 60-90, 90+ days). Payables aging. Send reminder button

### Day 5: Testing
- [ ] Auto-ledger entries from procurement/sales modules
- [ ] Expense approval flow with confirmation popup
- [ ] GST calculation accuracy on invoices
- [ ] P&L report matches manual calculation
- [ ] Accountant sees full accounting; Manager sees read-only
- [ ] All confirmation popups working
- [ ] Responsive on all screen sizes

## Git Commit
```bash
git add .
git commit -m "v0.6.0: Accounting - Double-entry ledger, expenses with approval, cash/bank, GST compliance, P&L, financial reports, accountant role views"
git tag v0.6.0
git push origin main --tags
```
