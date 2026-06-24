# Phase 3 — Live Processing Pipeline (Weeks 7-8)
## Version: `v0.3.0`

---

## 🎨 UI Reference
- "Kanban board dark theme production tracking"
- "Manufacturing pipeline dashboard UI 2025"
- "Process stage timeline tracker design"
- "Factory floor monitoring dashboard dark"

## 🔑 Role Access

| Feature | Owner | Manager | Supervisor | Accountant | Operator | Worker |
|---|---|---|---|---|---|---|
| View all lots/stages | ✅ | ✅ | ✅ | ❌ | Own stage | ❌ |
| Create processing lot | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Log stage completion | ✅ | ✅ | ✅ | ❌ | ✅ (own) | ❌ |
| Approve stage | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| View yield reports | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |

---

## Week 7: Processing Core

### Day 1-2: Lot Management Pages
- [ ] **Processing Dashboard Page:**
  - Pipeline overview: horizontal flow showing 12 stages with lot counts per stage
  - Active lots count, today's output (kg), overall yield %, shift selector
  - Quick create: "Start New Lot" FAB
- [ ] **Lot List Page:**
  - Filter: Status (Active/Paused/Completed), Date, Supplier
  - Desktop: table; Mobile: cards with stage progress bar
- [ ] **Create Lot Page:**
  - Select purchase/RCN batch (dropdown with available RCN stock)
  - Input: Quantity to process (kg)
  - Auto-deduct from RCN inventory
  - **Confirmation popup:** "Start processing 2,000 kg from Lot#LOT-2026-001? This will deduct from RCN stock."
- [ ] **Lot Detail Page:**
  - Visual pipeline: 12 stage dots connected by lines, colored by status
  - Each stage expandable: input/output/wastage/operator/time/machine/photos
  - Yield calculator at bottom: outturn % with industry benchmark comparison
  - History timeline of all actions

### Day 3-4: Stage Logging & Kanban
- [ ] **Kanban Board Page (Desktop/Tablet):**
  - Columns for each stage (scrollable horizontally)
  - Lot cards draggable between columns
  - Card shows: Lot#, qty, operator, elapsed time, color status
  - Drag to next stage → opens Stage Completion Form
- [ ] **Stage Completion Form (Bottom Sheet on Mobile / Dialog on Desktop):**
  - Pre-filled: Lot#, Stage name, Input kg (from previous stage output)
  - Input: Output kg (wastage auto-calculated), Operator (dropdown), Machine (dropdown)
  - Optional: Temperature, Pressure, Moisture %, Notes, Photo capture
  - Wastage alert: if wastage > benchmark → yellow warning
  - Timer: shows elapsed time since stage started
  - **Confirmation popup:**
    ```
    Complete Stage: Shelling
    Lot: LOT-2026-001
    Input: 1,800 kg → Output: 520 kg
    Wastage: 1,280 kg (71.1%) — Shells
    Operator: Rajesh Kumar
    Machine: Shelling Line A
    [Cancel]  [Confirm ✓]
    ```
- [ ] Supervisor approval workflow: stage marked "Pending Review" → supervisor approves/rejects

### Day 5: Yield & Shift
- [ ] **Yield Report Page:**
  - Outturn % per lot (bar chart), per supplier (comparison), per period (trend line)
  - Stage-wise wastage breakdown (stacked bar)
  - Industry benchmark line overlay
- [ ] **Shift Management:** Morning/Evening/Night toggles filter all data
- [ ] **Daily Production Summary Page:** Total input/output/wastage, lots processed, operator performance

---

## Week 8: Offline, Polish & Testing

### Day 1-2: Offline Processing
- [ ] SQLite mirrors processing tables locally
- [ ] Queue stage completions offline → sync indicator ⏳
- [ ] Conflict resolution on reconnect
- [ ] Supervisor can approve offline (syncs later)

### Day 3-5: Testing & Polish
- [ ] Full flow: Create lot → process through all 12 stages → verify yield
- [ ] Kanban drag-and-drop on desktop/tablet
- [ ] Mobile: list view with stage progress bars
- [ ] Confirmation popups on: create lot, complete stage, approve stage
- [ ] Role: Operator sees only assigned stage; Supervisor sees all
- [ ] WebSocket real-time updates between devices
- [ ] Empty state: "No active lots — Start processing"
- [ ] Loading shimmer, error retry, pull-to-refresh

## Git Commit
```bash
git add .
git commit -m "v0.3.0: Live Processing - 12-stage pipeline, Kanban board, yield tracking, shifts, supervisor approval, offline support, confirmation popups"
git tag v0.3.0
git push origin main --tags
```
