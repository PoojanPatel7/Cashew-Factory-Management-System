# Phase 10 — Reports & Dashboard (Weeks 19-20)
## Version: `v0.10.0`

---

## 🎨 UI Reference
- "Analytics dashboard dark mode charts KPI 2025"
- "Role based dashboard different views design"
- "Data visualization dark theme business intelligence"
- "Report export PDF Excel design UI"

## 🔑 Role-Specific Dashboards — Each Role Gets Their Own View

| Role | Dashboard Shows |
|---|---|
| **Owner** | Full factory: Revenue, P&L, Production, Inventory, Employees, Machines, Alerts, Compliance |
| **Manager** | Operations: Production summary, Inventory alerts, Pending approvals, Employee attendance, Machine status |
| **Supervisor** | Floor: Active lots per stage, Today's output, Worker performance, Machine status (assigned) |
| **Accountant** | Finance: Revenue, Expenses, Outstanding, GST summary, Cash balance, Payment due |
| **Operator** | Machine: Assigned machine status, Today's work log, Maintenance alerts |
| **Worker** | Self: Today's attendance, This month earnings, Payslip link, Leave balance |

---

## Week 19: Role-Based Dashboards

### Day 1-2: Owner & Manager Dashboards
- [ ] **Owner Dashboard Page:**
  - **Row 1 — Key Stats:** Revenue (month), Net Profit, Production (today kg), Outturn %, Attendance %, Machine Uptime %
  - Each stat: GlassCard with icon, value (animated counter), trend arrow, sparkline
  - **Row 2 — Charts:**
    - Revenue trend (area chart, 30-day)
    - Grade-wise stock (horizontal bar)
    - Expense breakdown (donut)
  - **Row 3 — Pipeline + Alerts:**
    - Processing pipeline (horizontal stage flow with lot counts)
    - Recent alerts: Low stock, Maintenance due, Compliance expiry, Breakdowns
  - **Row 4 — Quick Actions:**
    - Pending approvals count (purchases, payroll, expenses, leave)
    - Machine status grid (green/yellow/red counts)
    - Top 5 workers today (piece-rate leaderboard)
  - Configurable: Owner can drag/reorder widgets
  - Real-time updates via WebSocket (auto-refresh every 30s)
- [ ] **Manager Dashboard Page:**
  - Same structure, minus P&L details and security metrics
  - Emphasis on: Pending approvals (badge counts), Today's operations, Inventory alerts

### Day 3-4: Supervisor, Accountant, Operator, Worker Dashboards
- [ ] **Supervisor Dashboard Page:**
  - Active lots grid: stage × status (Kanban mini-view)
  - Today's production: input/output/wastage with yield %
  - Worker attendance: present/absent grid for own team
  - Machine status cards (assigned machines only)
  - Quick action: Log stage completion, Mark attendance
- [ ] **Accountant Dashboard Page:**
  - Revenue today/week/month cards
  - Cash + Bank balance cards
  - Outstanding receivables aging chart
  - Outstanding payables aging chart
  - Recent transactions list
  - GST summary mini (input vs output credit)
  - Quick action: Create expense, Generate invoice
- [ ] **Operator Dashboard Page:**
  - Assigned machine card: status, live sensor mini-gauges, running hours today
  - Today's work logs list (start/end/output per lot)
  - "Start Work" / "Report Issue" big buttons
  - Maintenance alert if due soon
- [ ] **Worker Dashboard Page:**
  - Today's status: Checked in at ___
  - This month: X days present, ₹X earned, X kg processed
  - Mini attendance calendar (last 30 days colored dots)
  - Latest payslip card (tap to view/download)
  - Leave balance card
  - "Check In" / "Check Out" button

---

## Week 20: Reports Module

### Day 1-2: Report Generator Pages
- [ ] **Reports Hub Page:**
  - Category cards: Production | Inventory | Financial | Employee | Quality | Machinery | Compliance
  - Each card: icon, report count, tap → opens report list for that category
  - Favorite reports section at top (user-pinned)
  - Recent reports section
- [ ] **Report Viewer Page (Reusable for all reports):**
  - Date range picker at top
  - Filter chips (varies by report)
  - Data visualization: chart + data table below
  - Desktop: chart and table side-by-side
  - Mobile: chart on top, scrollable table below
  - Export buttons: PDF | Excel | Print
  - "Add to Favorites" star icon
  - Share button

### Day 3-4: All Report Pages (30+ reports)
**Production Reports:**
- [ ] Daily production summary (date-wise totals, chart)
- [ ] Stage-wise output report (which stage processed how much)
- [ ] Yield/outturn report (per lot, per supplier, per period)
- [ ] Shift-wise comparison (morning vs evening vs night bar chart)
- [ ] Wastage analysis (stage-wise wastage % vs benchmark)

**Inventory Reports:**
- [ ] Current stock position (all categories, exportable)
- [ ] Stock movement report (in/out/transfer per period)
- [ ] Stock aging report (how long items sitting)
- [ ] Wastage report (total loss at each stage)

**Financial Reports:**
- [ ] Profit & Loss statement (expandable sections)
- [ ] Cash flow statement (in vs out line chart)
- [ ] Expense analysis by category (pie + table)
- [ ] Outstanding receivables with aging buckets
- [ ] Outstanding payables with aging buckets
- [ ] Lot-wise profitability (green/red per lot)
- [ ] Grade-wise profitability (which grade earns most)

**Employee Reports:**
- [ ] Attendance summary (monthly, employee-wise grid)
- [ ] Piece-rate earnings (monthly rankings, chart)
- [ ] Productivity report (kg per worker per day)
- [ ] Overtime report
- [ ] Payroll summary per month

**Quality Reports:**
- [ ] Grade distribution (per lot, per period — pie charts)
- [ ] QC pass/fail ratio (bar chart)
- [ ] Moisture trend analysis (line chart)

**Machinery Reports:**
- [ ] Machine uptime report (% per machine bar chart)
- [ ] Maintenance cost report (per machine, trend)
- [ ] Energy consumption report
- [ ] Machine efficiency comparison

**Compliance Reports:**
- [ ] Upcoming renewals (next 90 days)
- [ ] Compliance health score trend

### Day 5: Testing
- [ ] Each role's dashboard shows correct widgets
- [ ] Owner dashboard has all widgets; Worker has minimal
- [ ] All 30+ reports generate with accurate data
- [ ] PDF/Excel export working for every report
- [ ] Date range filtering on all reports
- [ ] Reports responsive: chart+table on desktop, stacked on mobile
- [ ] WebSocket real-time dashboard updates
- [ ] Favorite reports persist per user

## Git Commit
```bash
git add .
git commit -m "v0.10.0: Reports & Dashboards - 6 role-specific dashboards, 30+ reports, PDF/Excel export, real-time WebSocket updates, configurable widgets"
git tag v0.10.0
git push origin main --tags
```
