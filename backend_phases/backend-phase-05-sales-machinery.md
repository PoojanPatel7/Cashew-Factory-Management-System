# Backend Phase 5 — Sales, Byproducts & Machinery API
## Version: `b0.5.0`

---

## 🎯 Objective
Finalize the core operational modules: Sales Orders and container dispatch, Byproducts (CNSL, Waste), and the Machinery Portal (IoT telemetry logging and maintenance). Customer PII and Sales Pricing must be encrypted.

## 📝 Step-by-Step Implementation

### Step 1: Sales & Dispatch Endpoints
- [ ] Add Models: `Customer` (encrypted PII), `SalesOrder`, `DispatchLog`.
- [ ] **POST / GET `/api/sales/customers`:** Standard CRUD. Encrypt PII.
- [ ] **POST `/api/sales/orders`:** Create sales order. Deduct from `InventoryItem` (Finished Goods) immediately to reserve stock.
- [ ] **PUT `/api/sales/orders/:id/dispatch`:** Mark order as dispatched. Create `DispatchLog` with container/vehicle number. Automatically trigger an Accounting `Transaction` (Credit Revenue, Debit Accounts Receivable).

### Step 2: Byproducts & Compliance Endpoints
- [ ] Add Models: `ByproductLog`, `ComplianceDoc`.
- [ ] **POST `/api/byproducts/cnsl`:** Log cashew nut shell liquid extraction. Add to inventory.
- [ ] **POST `/api/byproducts/waste`:** Log final waste disposal.
- [ ] **POST `/api/compliance/docs`:** Log compliance document metadata and expiry date.
- [ ] **GET `/api/compliance/alerts`:** Return documents expiring within the next 30 days.

### Step 3: Machinery & IoT Portal Endpoints
- [ ] Add Models: `Machine`, `MaintenanceLog`, `MachineTelemetry`.
- [ ] **POST / GET `/api/machinery`:** Register and list factory machines.
- [ ] **POST `/api/machinery/telemetry`:** (High frequency endpoint for IoT sensors)
  - Accepts `{ machineId, temperature, pressure, power, status }`.
  - Store in `MachineTelemetry` (consider using TimescaleDB if scaling PostgreSQL, or simply standard table for now with index on `timestamp`).
  - Broadcast via WebSocket to connected clients (Frontend Dashboard).
- [ ] **POST `/api/machinery/maintenance`:** Log a maintenance event.
  - Automatically deduct spare parts from `InventoryItem`.

### Step 4: Unit Testing & Validation
- [ ] Integration Test: Creating a Sales Order triggers inventory deduction and creates an Accounting Revenue transaction.
- [ ] Test IoT telemetry endpoint for fast ingestion response times (< 50ms).
- [ ] Verify WebSockets correctly emit telemetry updates.

## ✅ Completion Criteria
- Sales lifecycle (Order -> Dispatch -> Accounting Ledger) is fully linked.
- Machinery telemetry endpoint is capable of accepting mock IoT sensor data.
- Compliance expiry alerts correctly identify expiring documents.
