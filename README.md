# Cashew Factory Management System (CashewPro ERP) 🌰

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.27-blue?logo=flutter)

A comprehensive, end-to-end Enterprise Resource Planning (ERP) application built specifically for Cashew Processing Factories. It covers the complete lifecycle of a cashew factory: from raw cashew nut (RCN) procurement, 12-stage live processing, employee payroll, accounting, sales dispatch, up to advanced analytics and offline data sync.

## 🚀 Key Features

*   **Procurement & Inventory:** Manage suppliers, generate Purchase Orders (POs), process Goods Receipts, and monitor stock with dynamic aging.
*   **Live 12-Stage Processing:** Real-time tracking of grading, peeling, drying, and packing with lot traceability.
*   **Quality Control (QC):** Digital grading entries and QC certificates.
*   **HR & Payroll:** Biometric/self-check-in attendance, piece-rate calculation, payroll generation, and advance tracking.
*   **Accounting & Financials:** General ledger, automated expense logging, CA-ready P&L statements, and GST integrations.
*   **Sales & Dispatch:** Sales order generation, delivery challans, and container tracking.
*   **IoT Machinery Portal:** Live sensor dashboard, maintenance scheduler, and operator workflow portal.
*   **Role-Based Access Control:** 6 distinct roles (Owner, Manager, Supervisor, Accountant, Operator, Worker) with dedicated, tailored dashboards.
*   **Offline First & Multi-Language:** Seamless offline mode with queue syncing and multi-language support (English, Hindi, Gujarati).
*   **Security:** State-of-the-art Encrypt Engine to secure PII data, audit logging, and automated backups.

## 📦 Modules

1. **Procurement:** `lib/features/procurement/`
2. **Inventory:** `lib/features/inventory/`
3. **Live Processing:** `lib/features/processing/`
4. **Grading & QC:** `lib/features/quality/`
5. **HR & Payroll:** `lib/features/hr/`
6. **Accounting:** `lib/features/accounting/`
7. **Sales & Dispatch:** `lib/features/sales/`
8. **Byproducts & Compliance:** `lib/features/byproducts/` and `lib/features/compliance/`
9. **Machinery Portal:** `lib/features/machinery/`
10. **Reports & Analytics:** `lib/features/reports/` and `lib/features/dashboard/`

## 🛠 Tech Stack

*   **Framework:** Flutter (Dart)
*   **Routing:** GoRouter
*   **State Management/Architecture:** Domain-Driven Design (DDD) principles with generic Flutter capabilities
*   **Database:** SQLite (Drift) for local offline sync, scalable cloud-ready.

## 📖 Documentation

*   [SETUP.md](SETUP.md): Infrastructure and Docker deployment guide.
*   [USER_GUIDE.md](USER_GUIDE.md): End-user operations manual.
*   [API_DOCS.md](API_DOCS.md): API Endpoint specifications.
*   [CHANGELOG.md](CHANGELOG.md): Version history and updates.

## 🔒 Security

Built with an integrated **Encrypt Engine** utilizing AES-256 GCM encryption. All sensitive user and employee data (PII), payroll details, and proprietary manufacturing yields are encrypted at rest.

---
© 2026 Poojan Patel. All Rights Reserved.
