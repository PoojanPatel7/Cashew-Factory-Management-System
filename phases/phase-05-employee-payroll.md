# Phase 5 — Employee & Payroll (Weeks 10-11)
## Version: `v0.5.0`

---

## 🎨 UI Reference
- "Employee directory dashboard dark UI"
- "Attendance calendar mobile app design"
- "Payroll management payslip design dark"
- "Worker self-service portal mobile UI"

## 🔑 Role Access — Special: Worker Self-Service Portal

| Feature | Owner | Manager | Supervisor | Accountant | Operator | Worker |
|---|---|---|---|---|---|---|
| View all employees | ✅ | ✅ | Own team | Names only | ❌ | ❌ |
| Create/edit employees | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| View PII (Aadhaar/Bank) | ✅ | ❌ | ❌ | ❌ | ❌ | Own (masked) |
| Mark attendance (team) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Self check-in | — | — | — | — | ✅ | ✅ |
| View own payslip | — | — | — | — | ✅ | ✅ |
| Generate payroll | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| Approve payroll | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Log piece-work | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## Week 10: Employee Management

### Day 1-2: Employee Pages
- [ ] **Employee List Page:** Photo, name, type badge, department, status. Search + filter by type/dept/status. Desktop: data table with sortable columns; Mobile: avatar card list
- [ ] **Employee Detail Page:** Photo + name header. Tabs: Profile | Attendance | Earnings | Payslips | Advances. PII fields masked (XXXX-1234) with "Tap to reveal" → requires Owner auth. 🔐 Encrypted badge on sensitive fields
- [ ] **Add/Edit Employee Page:** Sections: Personal Info | Employment | Bank Details | Documents. Aadhaar/PAN with encryption badge. Photo upload. **Confirmation popup** with all details (PII masked)

### Day 3-4: Attendance Pages
- [ ] **Attendance Dashboard Page:** Date picker, present/absent/late counts, progress ring. Grid view: employee rows × status toggles. Supervisor can bulk-mark attendance
- [ ] **Self Check-In Page (Worker/Operator Portal):** GPS location capture + selfie camera. Timestamp display. "Check In" / "Check Out" big buttons. Today's status card. **Confirmation popup:** "Check in at 8:02 AM? Location: Factory Floor A"
- [ ] **Attendance Calendar Page (Per Employee):** Month calendar view with colored dots (green/red/yellow/blue). Summary: Present days, Absent, Half-days, Overtime hours

### Day 5: Leave & Advance
- [ ] **Leave Application Page (Worker):** Select type (Casual/Sick/Earned), date range, reason. **Confirmation popup** before submit. Manager/Owner approval flow with notification
- [ ] **Advance Management Page:** Give advance form: amount, purpose, EMI months. Current balance display. Repayment history. **Confirmation popup:** "Give ₹10,000 advance to Ramesh? EMI: ₹2,500/month for 4 months"

---

## Week 11: Payroll

### Day 1-2: Piece-Rate & Wage Pages
- [ ] **Piece-Work Entry Page:** Select employee, task type (Shelling/Peeling), lot, quantity kg. Rate auto-filled from employee profile. Earnings auto-calculated. **Confirmation popup** with earnings
- [ ] **Piece-Work Daily Log Page:** Date selector, table of all entries. Edit/delete (supervisor only). Daily totals per worker

### Day 3-4: Payroll Pages
- [ ] **Payroll Generation Page:** Select month → preview all employees with calculated amounts. Columns: Employee | Basic | Piece Earnings | OT | Gross | PF | ESI | Advance EMI | Net Pay. Green/red highlighting for anomalies. "Generate All" button. **Confirmation popup:** Summary — total payout, employee count, breakdown
- [ ] **Payslip Page:** Professional PDF payslip: Factory logo, employee name, month, earnings table, deductions table, net pay. View in-app + download/share. Worker can access own payslips only
- [ ] **Worker Self-Service Portal:** Minimal view for Workers — own attendance calendar, piece-work earnings chart (weekly/monthly), payslip list, leave balance

### Day 5: Testing
- [ ] Create employee → verify Aadhaar encrypted in DB, searchable by hash
- [ ] Attendance: self check-in with GPS → calendar view shows correctly
- [ ] Piece-work → monthly summary → payroll generation
- [ ] Worker login → sees ONLY own data (attendance, earnings, payslip)
- [ ] Operator login → sees own data + assigned machine
- [ ] Confirmation popups on all create/update actions
- [ ] Responsive: all pages tested on 3 breakpoints

## Git Commit
```bash
git add .
git commit -m "v0.5.0: Employee & Payroll - Encrypted PII, attendance (GPS+selfie), piece-rate, payroll, worker self-service portal, confirmation popups"
git tag v0.5.0
git push origin main --tags
```
