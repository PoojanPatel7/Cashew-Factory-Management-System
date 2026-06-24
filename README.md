# 🏭 CashewPro ERP — Cashew Factory Management System

> **Complete, self-hosted ERP platform for cashew processing factories**
> Built with Flutter (Android/iOS/Web) + Node.js Backend + Encrypt Engine Security

---

## 🌟 Features

### 📊 15 Modules
| Module | Description |
|---|---|
| **Dashboard** | Real-time factory KPIs, alerts, processing pipeline overview |
| **Procurement** | Supplier management, purchase orders, goods receipt, payments |
| **Inventory** | Multi-warehouse stock tracking, QR/barcode, stock audits |
| **Live Processing** | 12-stage cashew processing pipeline with Kanban board |
| **Grading & QC** | W180-W450 grade classification, quality checklists, certificates |
| **Employee & Payroll** | HR, GPS attendance, piece-rate tracking, payslip generation |
| **Accounting** | Double-entry ledger, expenses, GST compliance, P&L reports |
| **Sales & Dispatch** | Orders, GST invoicing, dispatch tracking, export documentation |
| **Byproducts** | Shell, CNSL, Testa tracking with revenue from byproduct sales |
| **Compliance** | License management (FSSAI, GST, IEC) with expiry alerts |
| **Machinery Portal** | IoT machine monitoring, maintenance scheduling, operator portal |
| **Reports** | 30+ reports with PDF/Excel export |
| **Settings** | Factory profile, user management, theme, language |
| **Security** | AES-256-GCM encryption via Encrypt Engine, audit logs |
| **Mobile App** | Full offline support with sync engine |

### 🔐 6-Role RBAC System
- **Owner** — Full access to everything
- **Manager** — All modules except settings/security
- **Supervisor** — Processing floor, inventory, team management
- **Accountant** — Finance, sales, GST, payroll
- **Operator** — Assigned machines & processing stage
- **Worker** — Own attendance, earnings, payslips only

### 📱 Responsive Design (3 Breakpoints)
- **Mobile** (<600px) — Bottom navigation + drawer
- **Tablet** (600-1024px) — Collapsible NavigationRail
- **Desktop** (>1024px) — Persistent sidebar with keyboard shortcuts

### 🎨 5 Built-in Themes
- Cashew Dark (default) — Navy + Amber/Gold
- Cashew Light — Cream + Warm Brown
- Midnight — Pure Dark + Cyan/Teal
- Forest — Dark Green + Lime
- Custom — Owner-defined colors

### ✅ Confirmation Popups
Every data push (create/update/delete) shows a preview dialog before committing.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.44 (Android, iOS, Web) |
| State Management | Riverpod |
| Routing | GoRouter |
| Backend | Node.js + Express + TypeScript |
| Database | PostgreSQL / MySQL (self-hosted) |
| ORM | Prisma |
| Security | Custom Encrypt Engine (AES-256-GCM) |
| IoT | MQTT (Mosquitto) for machine sensors |
| Deployment | Docker Compose on private server |

---

## 📦 Version History

| Version | Phase | Description |
|---|---|---|
| `v0.1.0` | Foundation | Flutter setup, 5 themes, 6-role RBAC, auth, settings pages |
| `v0.2.0` | Procurement & Inventory | Suppliers, POs, stock tracking, QR |
| `v0.3.0` | Live Processing | 12-stage pipeline, Kanban, yield |
| `v0.4.0` | Grading & QC | Grade classification, certificates |
| `v0.5.0` | Employee & Payroll | HR, attendance, piece-rate, payslips |
| `v0.6.0` | Accounting | Ledger, expenses, GST, P&L |
| `v0.7.0` | Sales & Dispatch | Orders, invoicing, dispatch, exports |
| `v0.8.0` | Byproduct & Compliance | Waste tracking, license alerts |
| `v0.9.0` | Machinery Portal | IoT dashboard, maintenance, QR |
| `v0.10.0` | Reports & Dashboard | 6 dashboards, 30+ reports |
| `v0.11.0` | UI/UX Polish | Animations, onboarding, notifications |
| `v0.12.0` | Multi-Language & Offline | EN/HI/GU, sync engine, backup |
| `v1.0.0` | Production Release | Security audit, docs, final build |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.44+
- Node.js 18+
- Docker & Docker Compose
- Git

### Run Locally (Development)
```bash
# Clone
git clone https://github.com/PoojanPatel7/Cashew-Factory-Management-System.git
cd Cashew-Factory-Management-System

# Install Flutter dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Android
flutter run
```

### Deploy to Server (Production)
```bash
# Coming in v1.0.0 — Full Docker Compose deployment guide
docker-compose up -d
```

---

## 📂 Project Structure

```
lib/
├── main.dart                       # Entry point
├── app.dart                        # Root widget with multi-theme
├── config/                         # Routes, themes, constants, API config
├── core/auth/                      # RBAC roles & permissions
├── features/
│   ├── auth/                       # Login, setup wizard
│   ├── dashboard/                  # Command center dashboard
│   ├── settings/                   # Theme, users, grades
│   └── ... (15 modules)
└── shared/widgets/                 # Reusable: scaffold, cards, dialogs
```

---

## 📄 License

Proprietary — All rights reserved.  
Built by [PoojanPatel7](https://github.com/PoojanPatel7)

---

## 🏗️ Current Status: **Phase 1 Complete** (`v0.1.0`)
