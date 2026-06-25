# Backend Phase 6 — Advanced Analytics & Offline Sync Resolution
## Version: `b0.6.0`

---

## 🎯 Objective
Create complex SQL aggregations to serve the 30+ reports required by the frontend Dashboard. Most importantly, implement the **Offline Sync Resolver** endpoint that processes queues of data sent by the mobile app when it reconnects to the internet.

## 📝 Step-by-Step Implementation

### Step 1: Analytics & Reports Endpoints
- [ ] **GET `/api/reports/production-yield`:** Aggregate `StageLog` and `GradingRecord` data to calculate the overall outturn percentage per lot.
- [ ] **GET `/api/reports/financial-pnl`:** Aggregate `Transaction` data (Revenues minus Expenses). **Crucial:** Because amounts are encrypted, the backend MUST decrypt all relevant amounts in memory using the Encrypt Engine to perform the math, then return the total. (Consider optimizing this by securely storing a daily aggregated hash, depending on performance).
- [ ] **GET `/api/reports/machine-uptime`:** Calculate percentage uptime based on `MachineTelemetry` and `MaintenanceLog` history.
- [ ] **GET `/api/dashboard/owner`:** Return all top-level KPIs for the Owner Dashboard (revenue, production today, attendance %).

### Step 2: The Offline Sync Engine (`src/controllers/syncController.ts`)
- [ ] **POST `/api/sync/push`:** Endpoint to receive an array of operations performed offline by the mobile app.
  - Payload structure: `[ { entity: "Attendance", action: "CREATE", data: {...}, timestamp: 123456 }, ... ]`
  - The server must process this array in order of timestamp.
  - **Conflict Resolution:** If updating a record that has already been modified on the server (check updated_at timestamps), the server-wins rule applies. Return a list of conflicts to the app.
  - Ensure all incoming PII/Financials in the sync payload are immediately piped to the Encrypt Engine before saving.
- [ ] **GET `/api/sync/pull`:** Endpoint for the mobile app to fetch all changes since its last `syncToken`. Return updated Inventory, Employees, and active Processing Lots.

### Step 3: Websocket Real-time Notifications
- [ ] Implement `Socket.io` or standard `ws`.
- [ ] Emit events on critical actions: `inventory.low`, `machine.breakdown`, `approval.pending`.
- [ ] Ensure the mobile app receives these push alerts instantly when online.

### Step 4: Unit Testing & Validation
- [ ] Write a test simulating a mobile app pushing 5 offline attendance records. Verify they are inserted correctly.
- [ ] Write a conflict test: App pushes an update to a Lot that has already been advanced by another user. Verify the server rejects the update and returns a conflict error.
- [ ] Test the P&L report math by creating 10 dummy encrypted transactions, calling the report, and verifying the decrypted total sum is correct.

## ✅ Completion Criteria
- Dashboard reports return accurate aggregated data.
- The `/sync/push` endpoint successfully resolves offline data queues without data corruption.
- In-memory decryption math works flawlessly for financial reports.
