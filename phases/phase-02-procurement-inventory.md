# Phase 2 — Procurement & Inventory (Weeks 4-6)
## Version: `v0.2.0`

---

## 🎨 UI Reference (Search on Google/Dribbble)
- "Supplier management dashboard dark theme UI"
- "Purchase order form modern design dark mode"
- "Inventory management grid cards responsive"
- "Stock tracking warehouse dashboard UI 2025"
- "QR scanner mobile Flutter design"

---

## 🔑 Role Access for This Module

| Feature | Owner | Manager | Supervisor | Accountant | Operator | Worker |
|---|---|---|---|---|---|---|
| View suppliers | ✅ | ✅ | ❌ | ✅ (read) | ❌ | ❌ |
| Create/edit suppliers | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Create purchase orders | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Approve purchases | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| View inventory | ✅ | ✅ | ✅ | ✅ (read) | ❌ | ❌ |
| Adjust stock | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Stock audit | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## Week 4: Supplier Management & Purchase Orders

### Day 1-2: Supplier Pages
**Pages to Build:**
- [ ] **Supplier List Page:**
  - Desktop: Data table with columns (Name, Location, Rating, Total Purchased, Last PO Date, Status)
  - Tablet: Compact table with fewer columns
  - Mobile: Card list with key info + tap for detail
  - Search bar + filter chips (Active/Inactive, Rating, Location)
  - "Add Supplier" FAB → opens form
  - Bulk actions: export, deactivate selected
- [ ] **Supplier Detail Page:**
  - Header card: Name, location, contact, rating stars
  - Tab bar: Info | Purchase History | Payment History | Stats
  - Info tab: Full details, bank info (masked, "Tap to reveal" with auth)
  - Purchase History tab: List of all POs with status badges
  - Stats tab: Charts — total purchased (bar), avg moisture (line), quality grade (pie)
  - Edit button → opens edit form
- [ ] **Add/Edit Supplier Form Page:**
  - Sections: Basic Info | Contact | Bank Details | Notes
  - Bank details field shows 🔐 encrypted badge
  - **Confirmation popup before save:**
    ```
    Create Supplier: Rajan Cashew Farm
    Location: Kollam, Kerala
    Contact: +91 98765 43210
    Bank: XXXX XXXX 1234 (encrypted)
    [Cancel]  [Confirm ✓]
    ```

### Day 3-4: Purchase Order Pages
- [ ] **Purchase List Page:**
  - Status tab bar: All | Draft | Confirmed | In Transit | Received | Closed
  - Each PO card: PO#, supplier name, date, qty, amount, status badge
  - Desktop: full data table; Mobile: card list
  - Quick actions: Edit (draft only), View, Receive
- [ ] **Create Purchase Order Page:**
  - Supplier dropdown (searchable)
  - Fields: Date, RCN Quantity (kg), Price per kg, Moisture %, Quality Grade (A/B/C)
  - Auto-calculate: Total Amount = qty × price
  - Transport section: Vehicle, Driver, Freight Cost
  - Advance section: Previous advance balance shown, new advance input
  - **Confirmation popup with full summary before creating**
- [ ] **Purchase Detail Page:**
  - Status timeline (Draft → Confirmed → In Transit → Received → Closed)
  - PO details card with all fields
  - Payment history section with "Add Payment" button
  - "Receive Goods" button (for confirmed/in-transit POs)
- [ ] **Goods Receipt Page:**
  - Pre-filled from PO (expected qty, supplier)
  - Input: Actual weight, Actual moisture %, Gate quality check
  - Auto-calculate variance: (actual - expected)
  - Variance highlighted: green (within 2%), yellow (2-5%), red (>5%)
  - Photo capture for quality documentation
  - **Confirmation popup showing:** Actual vs Expected comparison table
  - On confirm: auto-create RCN inventory entry + update supplier stats

### Day 5: Payment Tracking
- [ ] **Payment Recording Dialog:**
  - Amount, Mode (Cash/Bank/UPI/Cheque), Reference number, Date
  - Shows: Total PO amount, Previously paid, This payment, Balance
  - **Confirmation popup** with payment details
- [ ] **Advance Management Page** (under Supplier Detail):
  - List of advances given, EMI deductions, current balance
  - "Give Advance" form with confirmation
  - Auto-adjust: advance deducted from next PO payment

---

## Week 5: Inventory Management

### Day 1-2: Stock Dashboard & List Pages
- [ ] **Inventory Dashboard Page:**
  - Top: Category cards (RCN, WIP, Finished, Byproduct, Packaging, Consumable) with total kg/units
  - Donut chart: Stock distribution by category
  - Alert list: Low stock items (red), Expiring items (orange)
  - Quick actions: Add Stock, Transfer, Audit
- [ ] **Stock List Page:**
  - Filter bar: Category | Warehouse | Grade | Search
  - Desktop: sortable data table (Item, Category, Qty, Unit, Warehouse, Lot#, Last Updated)
  - Mobile: card list with category color stripe
  - Tap item → Stock Detail Page
- [ ] **Stock Detail Page:**
  - Item info card: Name, category, current qty, min stock, warehouse, lot#
  - Movement history timeline (In/Out/Transfer/Adjust) with date, qty, user, reference
  - Line chart: Stock level over time
  - Quick actions: Adjust, Transfer

### Day 3: Stock Operations Pages
- [ ] **Stock Adjustment Page:**
  - Select item, New quantity, Reason (mandatory dropdown: Damage, Counting Error, Theft, Natural Loss, Other)
  - Auto-calculate: difference shown (green +, red -)
  - **Confirmation popup:**
    ```
    Adjust Stock: Packaging Tins
    Current: 200 units → New: 185 units
    Difference: -15 units
    Reason: Damage
    [Cancel]  [Confirm ✓]
    ```
- [ ] **Stock Transfer Page:**
  - From Warehouse → To Warehouse
  - Select items + quantities
  - Transfer requires Manager/Owner approval
  - **Confirmation popup** with transfer details
  - Notification sent to approver

### Day 4: QR/Barcode & Stock Audit
- [ ] **QR Scanner Page:**
  - Full-screen camera view with scan overlay
  - On scan: slide-up bottom sheet with item details
  - Quick actions from scan: View detail, Adjust stock, Transfer
  - Generate QR: for lots, items, machines
- [ ] **Stock Audit Page:**
  - Select warehouse → loads all items in that warehouse
  - Scrollable list: Item | System Qty | Counted Qty (input) | Variance
  - Color-coded rows: green (match), yellow (minor), red (major variance)
  - "Complete Audit" button
  - **Confirmation popup:** Shows summary of all variances, auto-adjustment count
  - On confirm: create adjustment entries + audit log

### Day 5: Multi-Warehouse & Alerts
- [ ] **Warehouse Management Page:**
  - List of warehouses with stock summary per warehouse
  - Add/Edit warehouse: name, type (Raw Store/Process Floor/Finished Godown), location
- [ ] **Alert Configuration Page:**
  - Set min-stock levels per item
  - Alert channels: Push notification, SMS, in-app
  - Cron job checks hourly → creates alerts
- [ ] **Low Stock Alert Card** on dashboard (role: Owner, Manager, Supervisor)

---

## Week 6: Testing & Polish

### Day 1-3: Integration Testing
- [ ] Full flow: Create supplier → Create PO → Confirm → Receive goods → Verify inventory auto-created
- [ ] Stock adjustment with confirmation popup → verify ledger entry
- [ ] Stock transfer with approval workflow
- [ ] QR scan → shows correct item details
- [ ] Audit flow → variance calculation → adjustments
- [ ] Payment tracking → advance deduction
- [ ] Responsive: all pages tested on mobile/tablet/desktop
- [ ] Role check: Supervisor CAN view inventory, CANNOT create supplier
- [ ] Role check: Accountant CAN view supplier (read), CANNOT edit

### Day 4-5: UI Polish
- [ ] Empty states for all lists (illustration + "No suppliers yet" + Add button)
- [ ] Loading shimmer skeletons for all list pages
- [ ] Error states with retry button
- [ ] Pull-to-refresh on mobile
- [ ] Smooth page transitions (slide/fade)
- [ ] Form validation with inline error messages
- [ ] All confirmation popups consistent style

## Git Commit
```bash
git add .
git commit -m "v0.2.0: Procurement (suppliers, POs, receipts, payments) + Inventory (stock tracking, QR, audits, warehouses, alerts) with role-based access and confirmation popups"
git tag v0.2.0
git push origin main --tags
```
