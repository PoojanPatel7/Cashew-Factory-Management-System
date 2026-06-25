# Integration Phase 2 — Procurement & Live Inventory
## Version: `i2.0.0`

---

## 🎯 Objective
Connect the Procurement module and the Factory Stock views to the real database. Factory managers must see real-time Kg metrics of raw cashew nuts (RCN) and finished goods.

## 📝 Step-by-Step Implementation

### Step 1: Inventory Connection
- [ ] Create `InventoryRepository` calling `GET /api/inventory/stock`.
- [ ] Update `InventoryDashboardPage`. Remove the static dummy lists (`_mockItems`) and replace them with a `FutureBuilder` or state watcher that fetches data via `InventoryRepository`.

### Step 2: Supplier & PO Connection
- [ ] Create `SupplierRepository` calling `/api/suppliers`.
- [ ] Update `AddSupplierPage` to call `POST /api/suppliers` instead of just using `Navigator.pop`. Show a success snackbar on `201 Created`.
- [ ] Create `ProcurementRepository` calling `/api/procurement/pos`.
- [ ] Update the UI where the Manager receives a PO. Clicking "Receive Goods" must call `PUT /api/procurement/pos/:id/receive` to automatically increase the real stock level.

## ✅ Completion Criteria
- Creating a Supplier in Flutter immediately writes to the PostgreSQL DB via the Encrypt Engine.
- Marking a PO as "Received" successfully updates the live Inventory Dashboard amounts.
