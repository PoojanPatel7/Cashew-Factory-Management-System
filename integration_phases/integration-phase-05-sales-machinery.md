# Integration Phase 5 — Sales, Dispatch & Machinery IoT
## Version: `i5.0.0`

---

## 🎯 Objective
Connect the Sales Hub to real customer data, process dispatches, and hook up the Machinery Portal to listen to real-time WebSockets from the backend.

## 📝 Step-by-Step Implementation

### Step 1: Sales Hub Integration
- [ ] Create `SalesRepository` pointing to `/api/sales`.
- [ ] Update `CreateDispatchPage`. Submitting the vehicle number must hit `PUT /api/sales/orders/:id/dispatch`.
- [ ] Ensure the total sales calculations on the UI pull the decrypted order totals from the API.

### Step 2: Machinery WebSocket Telemetry
- [ ] Install `web_socket_channel` or `socket_io_client` in the Flutter app.
- [ ] Update the `MachineryDashboardPage`. Instead of generating random mock data, connect the gauge charts directly to the backend WebSocket stream emitting `telemetry_update` events.

## ✅ Completion Criteria
- Sales dispatches successfully update backend statuses.
- Machinery gauges flutter and animate based on actual data pushed from the server.
