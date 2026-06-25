# Integration Phase 3 — Processing Pipeline & Grading
## Version: `i3.0.0`

---

## 🎯 Objective
Wire up the complex 12-stage manufacturing Kanban board. As supervisors drag-and-drop batches or enter yields, real data must hit the backend to update live statuses.

## 📝 Step-by-Step Implementation

### Step 1: Kanban Board Connection
- [ ] Create `ProcessingRepository` pointing to `/api/processing`.
- [ ] Update `LiveProcessingScreen`. Fetch all active `ProcessingLot`s from the backend and populate the Kanban columns.
- [ ] Implement the Stage Advance logic: When a supervisor submits a stage's yield and waste, trigger `POST /api/processing/lots/:id/stages`. Reload the board on success.

### Step 2: Quality Control Integration
- [ ] Create `QualityRepository` pointing to `/api/quality`.
- [ ] Update `GradingHubScreen`. When QC submits the final distribution of W320/W240/Splits, trigger `POST /api/quality/grades`.
- [ ] Ensure that after successful grading, the lot disappears from the active processing dashboard and the Finished Goods inventory increments.

## ✅ Completion Criteria
- The Kanban board dynamically builds columns based on the backend data.
- Yield and Waste inputs are successfully transmitted to the API to be encrypted and stored.
