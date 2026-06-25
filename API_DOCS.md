# REST API Documentation (v1.0.0)

Base URL: `https://api.cashewpro.app/v1`

## Authentication
All endpoints (except `/auth/login`) require a JWT Bearer token.
`Authorization: Bearer <token>`

---

## 1. Auth & Users
*   **POST** `/auth/login`
    *   Body: `{ "email": "...", "password": "..." }`
    *   Returns: `{ "token": "...", "role": "..." }`
*   **POST** `/auth/logout`
*   **GET** `/users/me`

## 2. Procurement
*   **GET** `/suppliers` — List all suppliers
*   **POST** `/suppliers` — Add new supplier
*   **GET** `/procurement/purchase-orders` — List POs
*   **POST** `/procurement/purchase-orders` — Create a PO

## 3. Inventory
*   **GET** `/inventory/stock` — Get current stock levels
*   **POST** `/inventory/adjust` — Submit stock adjustment

## 4. Processing
*   **GET** `/processing/lots` — List active processing lots
*   **POST** `/processing/lots` — Create new lot
*   **PUT** `/processing/lots/:id/stage` — Update lot stage

## 5. Quality
*   **POST** `/quality/grades` — Enter grading output
*   **GET** `/quality/certificates` — List QC certificates

## 6. HR & Payroll
*   **GET** `/employees` — List employees
*   **POST** `/hr/attendance/check-in` — Worker check-in
*   **POST** `/hr/piece-work` — Log piece-rate work (e.g. kg shelled)

## 7. Accounting
*   **GET** `/accounting/ledger` — View general ledger
*   **POST** `/accounting/expenses` — Log new expense

## 8. Sales & Dispatch
*   **GET** `/sales/orders` — List sales orders
*   **POST** `/sales/dispatch` — Log container dispatch

## 9. Machinery & IoT
*   **GET** `/machinery/status` — Live status of all machines
*   **POST** `/machinery/maintenance` — Log maintenance event

## 10. Reports & Analytics
*   **GET** `/reports/production?start=X&end=Y`
*   **GET** `/reports/financial/pnl`
