# Phase 9 — Machinery Portal (Weeks 17-18)
## Version: `v0.9.0`

---

## 🎨 UI Reference
- "Machine monitoring dashboard IoT dark UI 2025"
- "Factory floor map equipment layout design"
- "Maintenance scheduler calendar dark theme"
- "Industrial IoT sensor gauge widgets design"
- "Equipment detail page dashboard dark"

## 🔑 Role Access — Operator Gets Own Portal

| Feature | Owner | Manager | Supervisor | Accountant | Operator | Worker |
|---|---|---|---|---|---|---|
| View all machines | ✅ | ✅ | ✅ | ❌ | Assigned only | ❌ |
| Add/edit machines | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| View live sensors | ✅ | ✅ | ✅ | ❌ | Assigned only | ❌ |
| Log machine work | ✅ | ✅ | ✅ | ❌ | ✅ (assigned) | ❌ |
| Report breakdown | ✅ | ✅ | ✅ | ❌ | ✅ (assigned) | ❌ |
| Schedule maintenance | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Manage spare parts | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| View analytics | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## Week 17: Machine Registry & Live Dashboard

### Day 1-2: Machine Registry Pages
- [ ] **Machine List Page:**
  - Desktop: Grid of machine cards (3-4 per row) with photo, name, status badge (animated pulse for Running)
  - Tablet: 2-column grid
  - Mobile: Single column card list
  - Filter chips: All | Running | Idle | Maintenance | Breakdown
  - "Add Machine" FAB
- [ ] **Add Machine Page:**
  - Sections: Basic Info (name, type dropdown, model, manufacturer, serial no) | Purchase Info (date, cost, warranty) | Specifications (rated capacity kg/hr, power kW) | Location (floor position)
  - Photo upload for machine
  - Document uploads: Manual PDF, warranty card, AMC contract
  - Auto-generate QR code on save
  - **Confirmation popup:**
    ```
    Add Machine: Borma Dryer #3
    Type: Borma Dryer
    Model: BD-5000
    Capacity: 500 kg/hr
    Cost: ₹4,50,000
    Warranty until: 2028-06-15
    [Cancel]  [Confirm ✓]
    ```
- [ ] **Machine Detail Portal Page (Per Machine):**
  - Hero header: Large photo, name, model, animated status badge (pulsing green dot for running)
  - **Tab 1 — Live Status:**
    - Sensor gauge widgets: Temperature (radial gauge), Pressure (radial gauge), RPM (arc gauge)
    - Power consumption meter, Vibration level indicator
    - Running hours today / total lifetime counter
    - Current operator assigned
  - **Tab 2 — Today's Work:**
    - Lots processed list: Lot#, input kg, output kg, time
    - Total output today counter (animated)
    - Efficiency % = actual output / rated capacity
    - Line chart: hourly output through the day
  - **Tab 3 — Production History:**
    - Date range picker
    - Daily output bar chart
    - Cumulative output line chart
    - Top operator leaderboard for this machine
  - **Tab 4 — Maintenance:**
    - Next scheduled maintenance date with countdown
    - Maintenance history timeline
    - Total maintenance cost to date
    - Spare parts used list
  - **Tab 5 — Documents:**
    - Manual PDF viewer, warranty card, AMC details
- [ ] **QR Code Page:** Display machine QR (full screen), print option. Scan QR → opens machine detail portal

### Day 3-4: Live Dashboard & IoT Integration
- [ ] **Machinery Dashboard Page (Overview):**
  - Summary row: Running count, Idle count, Maintenance count, Breakdown count (animated counters)
  - **Factory Floor Map View:**
    - Visual layout of factory floor (draggable machine icons on grid)
    - Each machine: icon + status color (green/yellow/orange/red)
    - Tap machine on map → bottom sheet with quick status + "View Detail" link
    - Desktop only: full floor map; Mobile: machine list view instead
  - Alert panel: Machines needing attention (overdue maintenance, sensor warnings)
- [ ] **IoT Integration Backend:**
  - MQTT subscriber: `machines/{id}/sensors/{type}` → store in `sensor_readings` table
  - Threshold alerts: if reading > max or < min → create notification + push alert
  - WebSocket: real-time sensor data to Flutter dashboard
  - For non-IoT machines: manual data entry form
- [ ] **Operator Portal (Operator Role View):**
  - Shows ONLY assigned machine(s)
  - Quick actions: Start Work Log, End Work Log, Report Issue
  - **Start Work Log Dialog:** Select lot, record start time. **Confirmation popup**
  - **End Work Log Dialog:** Input output kg, notes. Auto-calculate duration. **Confirmation popup:**
    ```
    Complete Work Log
    Machine: Shelling Line A
    Lot: LOT-2026-015
    Duration: 2h 35m
    Output: 340 kg
    [Cancel]  [Confirm ✓]
    ```
  - **Report Breakdown Button:** Issue description, urgency (Low/Medium/High/Critical), photo upload
    - Auto-updates machine status to "Breakdown"
    - Push notification to Owner + Manager
    - **Confirmation popup** with breakdown details

### Day 5: Operator Assignment
- [ ] **Assign Operator Page:** Machine × Employee × Shift matrix. Drag-drop or dropdown assignment
- [ ] **Shift Schedule View:** Calendar grid showing operator assignments per machine per shift
- [ ] **Confirmation popup** on each assignment change

---

## Week 18: Maintenance & Analytics

### Day 1-2: Maintenance Pages
- [ ] **Maintenance Calendar Page:**
  - Month view with colored dots: green (completed), yellow (upcoming), red (overdue)
  - Click date → shows maintenance tasks for that day
  - Desktop: split view (calendar + task list)
  - Mobile: calendar top, scrollable task list bottom
- [ ] **Schedule Maintenance Page:**
  - Machine dropdown, maintenance type (Preventive/Condition-based)
  - Trigger: By Hours (every X running hours) | By Calendar (every X days) | By Condition (sensor threshold)
  - Description, assigned technician/vendor
  - **Confirmation popup** with schedule details
- [ ] **Maintenance Log Entry Page:**
  - Select machine, type (Scheduled/Breakdown), date
  - Description, cost, parts used (select from spare parts inventory)
  - Technician name, downtime hours
  - Photo/video upload
  - **Confirmation popup:**
    ```
    Log Maintenance: Steam Boiler
    Type: Scheduled - Monthly Service
    Cost: ₹8,500
    Parts Used: Oil filter (₹1,200), Gasket set (₹800)
    Downtime: 4 hours
    Technician: Vinod Electric Works
    [Cancel]  [Confirm ✓]
    ```
  - On confirm: deduct spare parts from inventory, update machine status

### Day 3: Spare Parts Pages
- [ ] **Spare Parts List Page:** Name, part#, compatible machines, qty, min stock, vendor, unit cost. Low stock highlighted red
- [ ] **Add Spare Part Page:** Details + link to compatible machine types. **Confirmation popup**
- [ ] **Parts Usage History Page:** Per part or per machine — when used, quantity, maintenance event

### Day 4: Machine Analytics Pages
- [ ] **Machine Analytics Dashboard:**
  - Uptime % gauges per machine (target: 90%+)
  - Efficiency % bars per machine
  - Cost per kg processed per machine (bar chart comparison)
  - Energy consumption trend (line chart)
  - MTBF (Mean Time Between Failures) per machine
- [ ] **Machine Comparison Page:**
  - Side-by-side table: Machine | Uptime | Efficiency | Maintenance Cost | Output/hr | Energy
  - Sortable by any column
  - Best/worst highlighted
- [ ] **Machine ROI Page:**
  - Per machine: Purchase cost, total revenue generated, total maintenance cost, net ROI
  - ROI % calculation with timeline chart

### Day 5: Testing
- [ ] Register machine → QR generated → scan QR → opens portal
- [ ] IoT: MQTT sensor readings → display on live gauges
- [ ] Manual work log: start → end → output recorded. Confirmation popup
- [ ] Breakdown report → status change → notification sent
- [ ] Maintenance schedule → auto-reminder before due date
- [ ] Spare parts deducted on maintenance log. Confirmation popup
- [ ] Operator login → sees ONLY assigned machines
- [ ] Factory floor map renders on desktop, list on mobile
- [ ] All analytics calculations accurate
- [ ] Responsive: all pages on 3 breakpoints

## Git Commit
```bash
git add .
git commit -m "v0.9.0: Machinery Portal - Machine registry, IoT live dashboard, operator portal, floor map, maintenance scheduler, spare parts, analytics, QR integration, confirmation popups"
git tag v0.9.0
git push origin main --tags
```
