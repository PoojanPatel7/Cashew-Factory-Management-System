# Phase 1 — Foundation, Auth & RBAC (Weeks 1-3)
## Version: `v0.1.0`

---

## 🎨 UI Reference (Search on Google/Dribbble)
- "Dark theme ERP login page glassmorphism 2025"
- "Flutter admin dashboard sidebar responsive"
- "Role based dashboard UI design dark mode"
- "Premium onboarding wizard steps UI dark"

---

## Week 1: Flutter Project & Design System

### Day 1-2: Project Setup & Responsive Shell
- [ ] Create Flutter project with Android/iOS/Web platforms
- [ ] Add all dependencies (Riverpod, GoRouter, Dio, Drift, fl_chart, google_fonts, etc.)
- [ ] **Responsive Layout System** — 3 breakpoints:
  - **Mobile (<600px):** Bottom navigation bar (5 core items: Dashboard, Processing, Inventory, Employees, More) + Drawer for remaining modules
  - **Tablet (600-1024px):** Collapsible NavigationRail with icons, expandable on tap
  - **Desktop (>1024px):** Persistent sidebar with full labels, icons, active indicator
- [ ] `LayoutBuilder` wrapper widget that auto-switches navigation based on screen width
- [ ] **Keyboard shortcuts** for desktop (Ctrl+1 = Dashboard, Ctrl+2 = Procurement, etc.)

### Day 3-4: Theme System (Multi-Theme Support)
- [ ] **Theme Provider** (Riverpod) — stores selected theme, persists in SharedPreferences
- [ ] **5 Built-in Themes:**
  - `Cashew Dark` — Deep navy (#0D0D0D, #1A1A2E) + amber/gold (#D4A017, #FFB300)
  - `Cashew Light` — Cream (#FFF8E1) + warm brown (#5D4037) + gold
  - `Midnight` — True dark (#121212) + cyan (#18FFFF) + teal (#009688)
  - `Forest` — Dark green (#1B2A1B) + lime (#76FF03) + emerald
  - `Custom` — Owner picks primary + accent via color picker
- [ ] **Theme Switcher Widget** in Settings — preview cards with theme colors
- [ ] All widgets use `Theme.of(context)` — no hardcoded colors
- [ ] Smooth animated transition between themes

### Day 5: Shared Components Library
- [ ] `GlassCard` — Frosted glass container with blur, border, shadow
- [ ] `StatCard` — Icon, value, label, trend indicator, color
- [ ] `StatusBadge` — Pill with dot: Running/Idle/Pending/Error
- [ ] `ConfirmationDialog` — **Reusable popup for ALL data pushes:**
  ```dart
  ConfirmationDialog.show(
    context,
    title: 'Confirm Purchase',
    icon: Icons.shopping_cart,
    fields: [
      {'label': 'Supplier', 'value': 'Rajan Farm'},
      {'label': 'Quantity', 'value': '5,000 kg'},
      {'label': 'Rate', 'value': '₹120/kg'},
      {'label': 'Total', 'value': '₹6,00,000'},
    ],
    warnings: ['This will deduct ₹50,000 advance'],
    onConfirm: () => api.createPurchase(data),
  );
  ```
- [ ] `AppSearchBar` — Animated search with filters
- [ ] `EmptyState` — Illustration + message + action button
- [ ] `ErrorState` — Retry button, error details expandable
- [ ] `LoadingShimmer` — Skeleton loading for lists and cards
- [ ] `AppSnackbar` — Success (green), Error (red), Info (blue), Warning (orange)
- [ ] `DataTable` — Responsive: full table on desktop, card list on mobile
- [ ] `FormSection` — Grouped form fields with header and divider

---

## Week 2: Authentication & 6-Role RBAC

### Day 1-2: Backend Auth System
- [ ] **Backend folder structure** (`server/src/`)
- [ ] Prisma schema with ALL tables + `users`, `roles`, `permissions`, `role_permissions`
- [ ] **6 User Roles** with granular permissions:
  ```
  OWNER:
    - ALL modules: full CRUD
    - User management, settings, security, audit logs
    - Financial data: full access
    
  MANAGER:
    - All modules: full CRUD (except settings/security)
    - Can approve: purchases, payroll, dispatch, maintenance
    - Financial data: read-only
    
  SUPERVISOR:
    - Processing: full CRUD
    - Inventory: read + update stock
    - Grading/QC: full CRUD
    - Employees (own team): read attendance, assign work
    - Machinery (assigned): full access
    
  ACCOUNTANT:
    - Accounting: full CRUD
    - Sales: full CRUD (orders, invoices)
    - Procurement: read-only
    - Reports: financial reports only
    - Employees: read names only (no PII)
    
  OPERATOR:
    - Machinery (assigned machines): view + log work + report breakdown
    - Processing (assigned stage): update stage logs
    - Own attendance: view
    
  WORKER:
    - Own profile: view (masked PII)
    - Own attendance: view + self check-in
    - Own piece-work: view earnings
    - Own payslip: view + download
  ```
- [ ] `POST /api/auth/register` — Owner registration (first user = Owner role)
- [ ] `POST /api/auth/login` — Returns JWT with `{userId, role, permissions[], factoryId}`
- [ ] `POST /api/auth/refresh` — Refresh token
- [ ] Auth middleware: verify JWT → attach user
- [ ] RBAC middleware: `requirePermission('procurement.create')` → check user permissions
- [ ] Encrypt Engine integration for credentials

### Day 3-4: Flutter Auth Screens (Per-Role UI)
- [ ] **Splash Screen** — Animated CashewPro logo (Lottie animation), check JWT
- [ ] **Login Screen:**
  - Dark glassmorphism card, gold accent button
  - Email + password fields with validation
  - "Remember me" checkbox, "Forgot Password" link
  - Loading animation on submit
  - Error shake animation on invalid credentials
  - Smooth page transition to dashboard on success
- [ ] **Setup Wizard (First-Time):**
  - Step 1: Connect to Server (URL input + connection test button)
  - Step 2: Owner Details (name, email, phone, password)
  - Step 3: Factory Details (name, address, GSTIN, FSSAI, logo upload)
  - Step indicator with animated progress
  - Each step validates before next
- [ ] **Auth Provider (Riverpod):**
  - Login/logout state
  - Current user with role & permissions
  - Auto-redirect: no token → login, has token → dashboard
  - Token refresh on 401

### Day 5: Role-Based Navigation
- [ ] **Sidebar/Navigation adapts per role:**
  - Owner: sees ALL 13 nav items
  - Manager: sees all EXCEPT "Settings" and "Security"
  - Supervisor: sees Dashboard, Processing, Inventory, Grading, Employees, Machinery
  - Accountant: sees Dashboard, Accounting, Sales, Procurement (read badge), Reports
  - Operator: sees Dashboard (mini), Machinery (assigned), Processing (assigned)
  - Worker: sees "My Dashboard" with attendance, earnings, payslip only
- [ ] **Permission-guarded widgets:** `PermissionGate(permission: 'accounting.view', child: ...)`
- [ ] Navigation items hidden (not disabled) if no permission
- [ ] Unauthorized route access → redirect to dashboard with snackbar

---

## Week 3: Settings, User Management & Integration

### Day 1-2: Settings Module (Owner-Only Pages)
**Separate pages for each setting (not just a list):**
- [ ] **Factory Profile Page:**
  - Edit name, address, GSTIN, FSSAI, phone, email
  - Logo upload with crop tool
  - Preview of how it appears on invoices
  - Confirmation popup before saving changes
- [ ] **User Management Page:**
  - User list with role badges, status (Active/Inactive)
  - Search + filter by role
  - "Add User" form: name, email, phone, role dropdown, initial password
  - Edit user: change role, reset password, deactivate
  - Confirmation popup: "Create user Ramesh as Supervisor?"
  - Desktop: master-detail split view
  - Mobile: list → detail push navigation
- [ ] **Role & Permissions Page:**
  - Matrix grid: Roles × Permissions with checkboxes
  - Owner can create custom roles
  - Visual permission groups (Procurement, Inventory, Processing, etc.)
- [ ] **Theme Settings Page:**
  - Theme preview cards (tap to switch)
  - Custom theme: color pickers for primary & accent
  - Font size slider (Small/Medium/Large)
  - Live preview of changes

### Day 3-4: Grade Master & Stage Config Pages
- [ ] **Grade Master Page:**
  - List of all cashew grades (W180, W210, W240, W320, W450, SW, S, B, P)
  - Tap to edit: name, count range, current market price
  - Add custom grade
  - Confirmation popup on price update
- [ ] **Processing Stages Page:**
  - Drag-to-reorder stages list
  - Enable/disable stages
  - Add custom stage (name, expected duration, expected wastage %)
  - Confirmation popup on reorder
- [ ] **Tax Configuration Page:**
  - GST rate (default 5%), HSN codes
  - State-wise CGST/SGST or IGST toggle
  - Invoice prefix/numbering config
- [ ] **Server Connection Page:**
  - Current API URL, Encrypt Engine URL
  - Connection status indicators (green/red)
  - Test connection button
  - Change server URL with confirmation

### Day 5: Testing & Git Commit
**Testing Checklist:**
- [ ] App renders correctly on mobile (360px), tablet (768px), desktop (1440px)
- [ ] Sidebar → NavigationRail → Bottom nav transitions smoothly
- [ ] All 5 themes switch with smooth animation
- [ ] Login → JWT stored → protected routes work → logout clears token
- [ ] 6 roles see correct navigation items (test each role)
- [ ] Owner can create user with role → user can login with role-restricted view
- [ ] Confirmation popup appears on: create user, update grade price, change factory info
- [ ] Settings pages all have dedicated screens with proper forms
- [ ] Backend APIs respond correctly for auth and RBAC
- [ ] Encrypt Engine encrypts user credentials in database

## Git Commit
```bash
git add .
git commit -m "v0.1.0: Foundation - Responsive Flutter app (mobile/tablet/desktop), 5-theme system, 6-role RBAC auth, settings pages, confirmation popups, Encrypt Engine integration"
git tag v0.1.0
git push -u origin main --tags
```
