# 🏭 CashewPro ERP — Development Phases Overview (v2 — Pro Level)

> Each phase ends with **Testing → Git Commit → Version Tag → Push to GitHub**

---

## 🔑 User Roles & Access Rules

| Role | Sees | Can Do | Cannot Do |
|---|---|---|---|
| **Owner** | Everything — all modules, all data | Full CRUD, user management, settings, financials, export | Nothing restricted |
| **Manager** | All modules except settings/security | Approve purchases, payroll, dispatch; manage employees | Cannot manage users, change server config, view audit logs |
| **Supervisor** | Processing, Inventory, Grading, Employees (own team), Machinery | Create/edit processing stages, approve QC, assign workers | Cannot see financials, P&L, salary details of others |
| **Accountant** | Accounting, Sales, Procurement (read), Reports (financial) | Create invoices, record payments, manage expenses, GST | Cannot access processing floor, employee PII, machinery |
| **Machine Operator** | Machinery (assigned machines only), Processing (own stage) | Log machine work, report breakdowns, update stage output | Cannot see other modules, financials, employee data |
| **Worker (Sheller/Peeler)** | Own attendance, own piece-work, own payslip | Mark self-attendance, view own earnings | Cannot see anything else |

---

## 📱 Responsive Breakpoints

| Screen | Width | Navigation | Layout |
|---|---|---|---|
| **Mobile** | < 600px | Bottom nav (5 items) + Drawer for rest | Single column, stacked cards |
| **Tablet** | 600-1024px | Collapsible NavigationRail (icons) | 2-column grid, master-detail |
| **Desktop** | > 1024px | Persistent sidebar (full labels) | 3-4 column grid, split panels |

---

## 🎨 Theme System

| Theme | Style |
|---|---|
| **Cashew Dark** (default) | Deep navy + amber/gold accents |
| **Cashew Light** | Cream/beige + brown accents |
| **Midnight** | Pure dark + cyan/teal accents |
| **Forest** | Dark green + lime accents |
| **Custom** | Owner can set primary/accent colors |

---

## ✅ Confirmation Popup System (Every Data Push)

Every create/update/delete action shows a confirmation dialog:
```
┌─────────────────────────────────┐
│  ✏️ Confirm Changes             │
│─────────────────────────────────│
│  Action: Create New Purchase    │
│                                 │
│  Supplier: Rajan Cashew Farm    │
│  Quantity: 5,000 kg             │
│  Rate: ₹120/kg                 │
│  Total: ₹6,00,000              │
│  Moisture: 8.5%                 │
│  Transport: ₹12,000            │
│                                 │
│  ⚠️ This will deduct ₹50,000   │
│  advance from supplier balance  │
│                                 │
│  [Cancel]         [Confirm ✓]   │
└─────────────────────────────────┘
```

---

## 📦 Phase Table (13 Phases)

| Phase | Name | Weeks | Version | Key Deliverables |
|---|---|---|---|---|
| 1 | Foundation, Auth & RBAC | 1-3 | `v0.1.0` | Flutter setup, Backend, Auth, 6 roles, responsive shell, theme system |
| 2 | Procurement & Inventory | 4-6 | `v0.2.0` | Suppliers, POs, receipts, stock tracking, QR, confirmation popups |
| 3 | Live Processing | 7-8 | `v0.3.0` | 12-stage pipeline, Kanban, yield, supervisor approval |
| 4 | Grading & QC | 9 | `v0.4.0` | W180-W450 grades, QC checklists, certificates |
| 5 | Employee & Payroll | 10-11 | `v0.5.0` | HR, attendance, piece-rate, salary, worker self-service portal |
| 6 | Accounting & Finance | 12-13 | `v0.6.0` | Ledgers, expenses, GST, P&L, accountant-specific views |
| 7 | Sales & Dispatch | 14-15 | `v0.7.0` | Orders, invoicing, dispatch, export docs |
| 8 | Byproduct & Compliance | 16 | `v0.8.0` | Waste tracking, license management, alerts |
| 9 | Machinery Portal | 17-18 | `v0.9.0` | Machine registry, IoT, live dashboard, operator portal |
| 10 | Reports & Dashboard | 19-20 | `v0.10.0` | Role-based dashboards, 30+ reports, analytics |
| 11 | UI/UX Premium Polish | 21-22 | `v0.11.0` | Animations, micro-interactions, empty states, onboarding |
| 12 | Multi-Language & Offline | 23 | `v0.12.0` | EN/HI/GU, offline sync, data export |
| 13 | Security Audit & Release | 24 | `v1.0.0` | Penetration testing, performance, docs, production build |

> **Detailed plans for each phase → See `phases/` folder**
