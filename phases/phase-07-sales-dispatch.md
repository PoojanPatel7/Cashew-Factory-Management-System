# Phase 7 — Sales & Dispatch (Weeks 14-15)
## Version: `v0.7.0`

---

## 🎨 UI Reference
- "Sales order management dashboard dark UI"
- "Invoice generator modern design dark mode"
- "Dispatch tracking timeline UI design"
- "Export documentation form design"

## 🔑 Role Access

| Feature | Owner | Manager | Supervisor | Accountant | Operator | Worker |
|---|---|---|---|---|---|---|
| Manage customers | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| Create sales orders | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| Generate invoices | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| Manage dispatch | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Export documents | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |

---

## Week 14: Sales Orders & Invoicing

### Day 1-2: Customer & Order Pages
- [ ] **Customer List Page:** Search, credit status indicators (green=good, red=overdue). Desktop: table; Mobile: cards
- [ ] **Customer Detail Page:** Info, order history, outstanding balance, payment history tabs
- [ ] **Create Sales Order Page:** Select customer, add grades × quantities × prices. Auto-total. Delivery date. **Confirmation popup** with full order summary
- [ ] **Sales Order Detail Page:** Status timeline (Draft→Confirmed→Packed→Dispatched→Delivered), items table, invoice link, dispatch link

### Day 3-4: Invoice & Payment Pages
- [ ] **Invoice Generation Page:** Auto from order — GST calculation, HSN codes, factory header, buyer details. Preview PDF in-app. **Confirmation popup** before generating
- [ ] **Invoice PDF:** Professional template — logo, address, GSTIN, item table, tax breakdown, bank details, terms, QR code
- [ ] **Payment Recording:** Amount, mode, reference. Shows outstanding balance. **Confirmation popup**
- [ ] **Credit/Debit Note Page:** For returns/disputes with reason and confirmation

### Day 5: Packing & Price Lists
- [ ] **Packing Slip Page:** Auto-generate with lot traceability, weights, grade. PDF download
- [ ] **Price List Page:** Grade × customer pricing matrix. Bulk update. **Confirmation popup** on price changes

---

## Week 15: Dispatch & Export Docs

### Day 1-2: Dispatch Pages
- [ ] **Dispatch Dashboard Page:** Pending dispatches, today's dispatches, in-transit count
- [ ] **Create Dispatch Page:** Select order, vehicle, driver, route. Auto-deduct from finished goods inventory. **Confirmation popup:** "Dispatch 500kg W320 to XYZ Trading? This will deduct from stock."
- [ ] **Dispatch Tracking Page:** Timeline (Packed→Dispatched→In Transit→Delivered). Delivery proof: photo + e-signature upload

### Day 3-4: Export Documentation Pages
- [ ] **Export Document Generator Page:** Select order → choose documents needed (checkboxes):
  - Commercial Invoice (international USD/EUR format)
  - Packing List
  - Certificate of Origin
  - Phytosanitary Certificate template
  - Bill of Lading
- [ ] Generate all selected as ZIP. PDF preview per document
- [ ] Multi-currency support: USD, EUR exchange rate input

### Day 5: Testing
- [ ] Full flow: Customer → Order → Invoice → Dispatch → Delivery → Payment
- [ ] Confirmation popups on every action
- [ ] Stock deduction on dispatch
- [ ] Role access: Accountant can create orders but not dispatch
- [ ] Responsive: all pages on 3 breakpoints
- [ ] PDF generation working correctly

## Git Commit
```bash
git add .
git commit -m "v0.7.0: Sales & Dispatch - Orders, GST invoicing, dispatch tracking, delivery proof, export documents, confirmation popups"
git tag v0.7.0
git push origin main --tags
```
