# CashewPro ERP — Comprehensive Database Schema

This document outlines the complete relational database design for the CashewPro ERP backend using **Prisma ORM**. It details all 15+ tables, their columns, and the foreign key relationships connecting them.

> **🔒 SECURITY NOTE:** Any field prefixed with `encrypted` (e.g., `encryptedPhone`, `encryptedAmount`) means the data is passed through the `E:\encrypt engine` before being saved to PostgreSQL. The raw value never touches the database.

---

## Complete Prisma Schema (`schema.prisma`)

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// -----------------------------------------------------------------------------
// 1. AUTHENTICATION & USERS
// -----------------------------------------------------------------------------

model User {
  id             String     @id @default(uuid())
  email          String     @unique
  passwordHash   String
  role           UserRole   @default(WORKER)
  encryptedName  String     // Passed through Encrypt Engine
  createdAt      DateTime   @default(now())
  updatedAt      DateTime   @updatedAt
  
  // Relations
  auditLogs      AuditLog[]
}

enum UserRole {
  OWNER
  MANAGER
  SUPERVISOR
  ACCOUNTANT
  OPERATOR
  WORKER
}

model AuditLog {
  id        String   @id @default(uuid())
  userId    String?
  action    String
  details   String
  ipAddress String?
  createdAt DateTime @default(now())

  // Relations
  user      User?    @relation(fields: [userId], references: [id], onDelete: SetNull)
}

// -----------------------------------------------------------------------------
// 2. PROCUREMENT & INVENTORY
// -----------------------------------------------------------------------------

model Supplier {
  id                   String          @id @default(uuid())
  encryptedName        String
  encryptedPhone       String
  encryptedBankDetails String
  gstin                String?
  status               String          @default("ACTIVE")
  createdAt            DateTime        @default(now())
  updatedAt            DateTime        @updatedAt

  // Relations
  purchaseOrders       PurchaseOrder[]
}

model PurchaseOrder {
  id              String         @id @default(uuid())
  supplierId      String
  date            DateTime       @default(now())
  itemType        String         // e.g., "RCN", "Packaging"
  quantity        Float          // In Kg or Units
  encryptedPrice  String         // Price per unit
  status          PoStatus       @default(PENDING)
  createdAt       DateTime       @default(now())
  updatedAt       DateTime       @updatedAt

  // Relations
  supplier        Supplier       @relation(fields: [supplierId], references: [id], onDelete: Restrict)
  goodsReceipts   GoodsReceipt[]
}

enum PoStatus {
  PENDING
  PARTIAL
  RECEIVED
  CANCELLED
}

model GoodsReceipt {
  id              String        @id @default(uuid())
  purchaseOrderId String
  receiveDate     DateTime      @default(now())
  receivedQty     Float
  notes           String?

  // Relations
  purchaseOrder   PurchaseOrder @relation(fields: [purchaseOrderId], references: [id], onDelete: Restrict)
}

model InventoryItem {
  id            String   @id @default(uuid())
  category      String   // "RCN", "WIP", "Finished Goods", "Spares", "Packaging"
  itemName      String
  currentStock  Float    @default(0)
  unit          String   // "kg", "pcs", "tins"
  minThreshold  Float    @default(0)
  updatedAt     DateTime @updatedAt

  // Relations
  stockLogs     StockLog[]
}

model StockLog {
  id              String        @id @default(uuid())
  inventoryItemId String
  changeAmount    Float         // Positive for inward, negative for outward
  reason          String        // e.g., "PO_RECEIPT", "LOT_ALLOCATION", "DISPATCH"
  date            DateTime      @default(now())

  // Relations
  inventoryItem   InventoryItem @relation(fields: [inventoryItemId], references: [id], onDelete: Cascade)
}

// -----------------------------------------------------------------------------
// 3. LIVE PROCESSING & QUALITY
// -----------------------------------------------------------------------------

model ProcessingLot {
  id            String      @id @default(uuid())
  lotNumber     String      @unique
  startDate     DateTime    @default(now())
  initialWeight Float       // In Kg
  currentStage  StageEnum   @default(CLEANING)
  status        LotStatus   @default(IN_PROGRESS)
  
  // Relations
  stageLogs     StageLog[]
  gradingRecord GradingRecord?
}

enum LotStatus {
  IN_PROGRESS
  COMPLETED
  CANCELLED
}

enum StageEnum {
  CLEANING
  ROASTING_STEAMING
  SHELLING
  SEPARATION
  DRYING_BORMA
  PEELING
  GRADING
  COLOR_SORTING
  PACKING
}

model StageLog {
  id              String        @id @default(uuid())
  lotId           String
  stageName       StageEnum
  startTime       DateTime
  endTime         DateTime?
  inputWeight     Float
  encryptedOutput String        // Encrypted yield
  encryptedWastage String       // Encrypted waste/loss
  workerId        String?       // Reference to Employee

  // Relations
  lot             ProcessingLot @relation(fields: [lotId], references: [id], onDelete: Cascade)
  worker          Employee?     @relation(fields: [workerId], references: [id], onDelete: SetNull)
}

model GradingRecord {
  id               String        @id @default(uuid())
  lotId            String        @unique
  encryptedW320    String
  encryptedW240    String
  encryptedSplits  String
  qcNotes          String?
  certificateUrl   String?
  date             DateTime      @default(now())

  // Relations
  lot              ProcessingLot @relation(fields: [lotId], references: [id], onDelete: Cascade)
}

// -----------------------------------------------------------------------------
// 4. HR, PAYROLL & ACCOUNTING
// -----------------------------------------------------------------------------

model Employee {
  id                   String        @id @default(uuid())
  encryptedName        String
  encryptedPhone       String
  encryptedAadhar      String
  encryptedBankDetails String
  role                 String        // "Sheller", "Peeler", "Driver"
  department           String
  encryptedDailyWage   String        // Or Piece-rate base
  status               String        @default("ACTIVE")

  // Relations
  attendances          Attendance[]
  pieceWorks           PieceWork[]
  payrolls             Payroll[]
  stageLogs            StageLog[]    // Jobs they worked on
}

model Attendance {
  id         String   @id @default(uuid())
  employeeId String
  date       DateTime
  checkIn    DateTime?
  checkOut   DateTime?
  status     String   // "PRESENT", "ABSENT", "HALF_DAY"

  // Relations
  employee   Employee @relation(fields: [employeeId], references: [id], onDelete: Cascade)
}

model PieceWork {
  id              String   @id @default(uuid())
  employeeId      String
  date            DateTime
  stageName       String   // "Shelling", "Peeling"
  kgProcessed     Float
  encryptedEarned String   // Earnings for this specific work

  // Relations
  employee        Employee @relation(fields: [employeeId], references: [id], onDelete: Cascade)
}

model Payroll {
  id               String   @id @default(uuid())
  employeeId       String
  month            Int
  year             Int
  encryptedTotal   String
  encryptedAdvance String
  encryptedNetPay  String
  status           String   // "PENDING", "PAID"

  // Relations
  employee         Employee @relation(fields: [employeeId], references: [id], onDelete: Restrict)
}

// --- ACCOUNTING (Double-Entry Ledger) ---

model LedgerAccount {
  id               String   @id @default(uuid())
  accountName      String
  type             AccType  // ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE
  encryptedBalance String

  // Relations
  debitTransactions  Transaction[] @relation("DebitAccount")
  creditTransactions Transaction[] @relation("CreditAccount")
}

enum AccType {
  ASSET
  LIABILITY
  EQUITY
  REVENUE
  EXPENSE
}

model Transaction {
  id              String        @id @default(uuid())
  date            DateTime      @default(now())
  description     String
  debitAccountId  String
  creditAccountId String
  encryptedAmount String
  referenceId     String?       // Links to PO id, Sales Order id, or Payroll id

  // Relations
  debitAccount    LedgerAccount @relation("DebitAccount", fields: [debitAccountId], references: [id], onDelete: Restrict)
  creditAccount   LedgerAccount @relation("CreditAccount", fields: [creditAccountId], references: [id], onDelete: Restrict)
}

// -----------------------------------------------------------------------------
// 5. SALES & MACHINERY
// -----------------------------------------------------------------------------

model Customer {
  id             String       @id @default(uuid())
  encryptedName  String
  encryptedPhone String
  encryptedAddress String
  gstin          String?

  // Relations
  salesOrders    SalesOrder[]
}

model SalesOrder {
  id             String        @id @default(uuid())
  customerId     String
  orderDate      DateTime      @default(now())
  status         String        // PENDING, DISPATCHED, DELIVERED
  encryptedTotal String

  // Relations
  customer       Customer      @relation(fields: [customerId], references: [id], onDelete: Restrict)
  dispatchLogs   DispatchLog[]
}

model DispatchLog {
  id             String      @id @default(uuid())
  salesOrderId   String
  dispatchDate   DateTime    @default(now())
  vehicleNumber  String
  driverName     String?

  // Relations
  salesOrder     SalesOrder  @relation(fields: [salesOrderId], references: [id], onDelete: Restrict)
}

// --- MACHINERY ---

model Machine {
  id             String              @id @default(uuid())
  name           String
  modelNumber    String
  status         String              // RUNNING, IDLE, MAINTENANCE
  
  // Relations
  telemetry      MachineTelemetry[]
  maintenanceLogs MaintenanceLog[]
}

model MachineTelemetry {
  id          String   @id @default(uuid())
  machineId   String
  timestamp   DateTime @default(now())
  temperature Float?
  pressure    Float?
  powerKw     Float?

  // Relations
  machine     Machine  @relation(fields: [machineId], references: [id], onDelete: Cascade)
}

model MaintenanceLog {
  id          String   @id @default(uuid())
  machineId   String
  date        DateTime @default(now())
  description String
  cost        Float?
  technician  String?

  // Relations
  machine     Machine  @relation(fields: [machineId], references: [id], onDelete: Cascade)
}
```

## Key Architectural Relationships

1. **Double-Entry Accounting Enforcement:** The `Transaction` table explicitly demands a `debitAccountId` and a `creditAccountId`. This means you cannot insert a financial record without balancing the books. The `encryptedAmount` ensures that the transaction value is hidden from database admins.
2. **Proprietary Yield Protection:** In the `StageLog` and `GradingRecord`, outputs are stored as `encryptedOutput` and `encryptedW320` etc. This protects your specific factory efficiency and yield metrics from being stolen.
3. **Inventory Traceability:** Everything that affects inventory (PO receipts, lot allocation, stage completions, sales dispatch) MUST insert a row into the `StockLog` table, pointing to `InventoryItem`. This creates an unbreakable audit trail for every single kilogram of cashew in the factory.
4. **Offline Sync Support:** Every table has an `id` generated securely as a `UUID`. This prevents primary key collisions when a mobile device creates records offline and syncs them to the server later.
