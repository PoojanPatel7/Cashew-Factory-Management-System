# Backend Phase 3 — Live Processing & Quality API
## Version: `b0.3.0`

---

## 🎯 Objective
Create the endpoints to track the 12-stage processing of raw cashew nuts (RCN), handle stage transitions, and log Quality Control (QC) grading data. Yield data is considered proprietary and must be encrypted.

## 📝 Step-by-Step Implementation

### Step 1: Database Schema Additions
- [ ] Add `ProcessingLot` model: `id`, `lotNumber`, `startDate`, `initialWeight`, `currentStage` (Enum), `status`.
- [ ] Add `StageLog` model: `id`, `lotId`, `stageName`, `startTime`, `endTime`, `inputWeight`, `outputWeight` (encrypted yield data), `wastageWeight`, `workerId`.
- [ ] Add `GradingRecord` model: `id`, `lotId`, `w320Weight`, `w240Weight`, `splitsWeight`, `qcNotes`, `certificateUrl`.
- [ ] Run `npx prisma migrate dev`.

### Step 2: Processing Lot Endpoints
- [ ] **POST `/api/processing/lots`:** Create a new lot. Decrement the raw RCN from the `InventoryItem` table (Transaction).
- [ ] **GET `/api/processing/lots`:** Fetch all active lots. Support filtering `?status=IN_PROGRESS`.
- [ ] **GET `/api/processing/lots/:id`:** Fetch lot details including all associated `StageLog` history.

### Step 3: Kanban Stage Tracking Endpoints
- [ ] **POST `/api/processing/lots/:id/stages`:** Log the completion of a stage. 
  - Validate that `inputWeight` equals the `outputWeight` + `wastageWeight` + `moistureLoss`.
  - Encrypt the `outputWeight` and `wastageWeight` using the Encrypt Engine.
  - Update the `ProcessingLot.currentStage` to the next stage.
- [ ] **GET `/api/processing/stages/active`:** Return an aggregated count of lots currently in each of the 12 stages (for the frontend Supervisor Kanban dashboard).

### Step 4: Quality & Grading Endpoints
- [ ] **POST `/api/quality/grades`:** Submit the final grading breakdown for a lot.
  - Close the lot (`status = COMPLETED`).
  - Add the graded outputs (W320, W240, etc.) to the `InventoryItem` table as finished goods.
- [ ] **POST `/api/quality/certificates`:** Upload QC document metadata (link to S3/Cloud storage or local disk).

### Step 5: Unit Testing & Validation
- [ ] Write integration test for full lot lifecycle: Create Lot -> Advance 3 stages -> Submit Grading.
- [ ] Verify that final grading accurately updates Finished Goods inventory and raw RCN inventory was deducted.
- [ ] Verify that yield calculations (outputWeight) are correctly encrypted and decrypted via the engine.

## ✅ Completion Criteria
- Processing pipeline is fully operational via API.
- Inventory automatically shifts from Raw -> Work in Progress -> Finished Goods.
- Yield data is securely encrypted at rest.
