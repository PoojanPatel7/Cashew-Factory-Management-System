# Backend Phase 2 — Procurement & Inventory API
## Version: `b0.2.0`

---

## 🎯 Objective
Build the REST APIs for managing suppliers, purchase orders (POs), and warehouse inventory. Ensure all supplier contact details and pricing data are encrypted via the Encrypt Engine.

## 📝 Step-by-Step Implementation

### Step 1: Database Schema Additions
- [ ] Add `Supplier` model: `id`, `encryptedName`, `encryptedPhone`, `encryptedBankDetails`, `gstin`, `status`.
- [ ] Add `PurchaseOrder` model: `id`, `supplierId`, `date`, `itemType`, `quantity`, `pricePerKg` (encrypted), `status`.
- [ ] Add `InventoryItem` model: `id`, `category`, `itemName`, `currentStock`, `unit`, `minThreshold`.
- [ ] Add `StockLog` model for tracking in/out movements (audit trail).
- [ ] Run `npx prisma migrate dev`.

### Step 2: Supplier Endpoints (`src/controllers/supplierController.ts`)
- [ ] **POST `/api/suppliers`:** Validate input via Zod. Encrypt name, phone, and bank details before saving to Prisma.
- [ ] **GET `/api/suppliers`:** Fetch all suppliers. Pass encrypted fields to `decryptService` before returning JSON to frontend. (Implement pagination: `?page=1&limit=20`).
- [ ] **GET `/api/suppliers/:id`:** Fetch single supplier with decrypted details.
- [ ] **PUT `/api/suppliers/:id`:** Update and re-encrypt modified fields.

### Step 3: Purchase Order (PO) & Goods Receipt Endpoints
- [ ] **POST `/api/procurement/pos`:** Create PO. Calculate total value.
- [ ] **PUT `/api/procurement/pos/:id/receive`:** Mark PO as received. This must run in a **Database Transaction**:
  1. Update PO status to `RECEIVED`.
  2. Create a `StockLog` entry.
  3. Increment `currentStock` in `InventoryItem`.

### Step 4: Inventory Endpoints
- [ ] **GET `/api/inventory/stock`:** Return current stock levels. Add query param `?lowStock=true` to filter items below `minThreshold`.
- [ ] **POST `/api/inventory/adjust`:** Manual stock adjustment (requires Manager/Owner role). Creates `StockLog`.

### Step 5: Unit Testing & Validation
- [ ] Write Jest tests for Supplier CRUD operations, verifying that database directly holds cipher text, but API returns plain text.
- [ ] Write integration test for the PO Receipt transaction (ensuring inventory increments correctly).

## ✅ Completion Criteria
- CRUD APIs for Suppliers and Inventory are functional.
- Stock increments accurately upon receiving a PO.
- Encrypt Engine correctly handles supplier PII dynamically on API calls.
