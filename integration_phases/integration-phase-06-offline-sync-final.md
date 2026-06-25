# Integration Phase 6 — Offline Sync Engine & Final Polish
## Version: `i6.0.0`

---

## 🎯 Objective
Complete the Offline-First capability of the Flutter app. When the tablet loses Wi-Fi on the factory floor, it must queue actions locally and push them automatically upon reconnection.

## 📝 Step-by-Step Implementation

### Step 1: The Local Queue (Drift/Hive)
- [ ] Implement a local `SyncQueue` using Hive or Drift.
- [ ] Update the `ApiClient`. If a `POST` or `PUT` fails due to `SocketException` (no internet), intercept it and save the payload to the `SyncQueue`.
- [ ] Show the user a visual indicator (the orange cloud icon in the top bar) when there are items in the queue.

### Step 2: The Push/Pull Resolver
- [ ] Create `SyncService` that monitors network connectivity.
- [ ] When internet returns:
  - Call `POST /api/sync/push` sending the entire local queue array.
  - On success, clear the local queue.
  - Immediately call `GET /api/sync/pull` to download any updates made by other supervisors while this device was offline.
- [ ] Update the UI to show the green checkmark when sync is resolved.

### Step 3: Final Production Checklist
- [ ] **Data Security:** Ensure no PII is left unencrypted in plain text logs on the device.
- [ ] **APK Generation:** Run `flutter build apk --release`.
- [ ] **Docker Deployment:** Ensure `docker-compose up -d` is running stably on the production server.
- [ ] **Handover:** Present the final application to the Factory Owner.

## ✅ Completion Criteria
- Turning off Wi-Fi on the device, checking in an employee, and turning Wi-Fi back on successfully updates the server without user intervention.
- The system is 100% production-ready.
