# 🥜 HMNuts — Cashew Factory Management System

<p align="center">
  <img src="logo.png" alt="HMNuts Logo" width="150" />
</p>

<p align="center">
  <b>A complete end-to-end cashew processing management system built for real factory operations.</b>
</p>

<p align="center">
  <a href="https://hm-nuts.web.app">🌐 Live Web App</a> •
  <a href="#-download">📥 Download APK</a> •
  <a href="#-features">✨ Features</a> •
  <a href="#-tech-stack">🛠 Tech Stack</a>
</p>

---

## 📖 About

**HMNuts** is a production-ready, multi-factory cashew processing management system. It digitizes the entire lifecycle of raw cashew — from procurement of raw stock, through sorting, 8-stage processing, finishing, and dispatch — all in real-time with live data updates.

Designed for **factory owners** and **managers** who need complete visibility and control over their cashew processing operations across one or more factories.

---

## 📥 Download

| Platform | Link |
|----------|------|
| 🌐 Web App | [hm-nuts.web.app](https://hm-nuts.web.app) |
| 🤖 Android APK | [Download v1.0 APK](./releases/HMNuts-v1.0-release.apk) |

---

## ✨ Features

### 🔐 Authentication & Roles
- **Google Sign-In** — One-tap authentication via Google
- **Email/Password Login** — Traditional manual login option
- **Owner PIN System** — Secure owner role assignment via secret PIN (avoids unauthorized admin access)
- **Role-Based Access** — Owner role with full management capabilities

### 🏭 Multi-Factory Management
- **Create & Manage Factories** — Set up multiple factory units under one account
- **Factory Switching** — Seamlessly switch between factories with a dropdown selector
- **Global Dashboard** — Bird's-eye view across all factories showing combined stats
- **Per-Factory Dashboard** — Detailed stats scoped to the active factory
- **Factory Transfer** — Transfer raw stock, lots, and finished stock between factories

### 📦 Raw Stock Management
- **Add Raw Stock Batches** — Record incoming raw cashew (weight, supplier, date, price)
- **Track Available vs Used** — Automatic calculation of remaining available raw stock
- **Stock Detail View** — See which lots were created from each raw stock entry
- **Edit & Delete** — Full CRUD operations on raw stock records

### ✂️ Sorting (Raw → Lots)
- **Sort Raw Stock into Lots** — Split raw cashew batches into processing lots
- **Custom Lot Naming** — Assign meaningful names to each lot
- **Weight Distribution** — Specify weight for each lot being created
- **Automatic Raw Stock Deduction** — Consumed weight is auto-deducted from the source

### ⚙️ 8-Stage Processing Pipeline
Each lot goes through **8 sequential processing stages**:

| # | Stage | Description |
|---|-------|-------------|
| 1 | 🧹 Cleaning | Remove debris, stones, and impurities |
| 2 | 🫕 Boiling | Steam/boil cashew shells |
| 3 | ❄️ Cooling | Cool down after boiling |
| 4 | 🔨 Shelling | Crack and remove outer shell |
| 5 | ☀️ Drying | Reduce moisture content |
| 6 | 🫧 Peeling | Remove inner skin (testa) |
| 7 | 📊 Grading | Grade kernels by size (W180, W210, W240, etc.) |
| 8 | 📦 Packing | Final packaging for dispatch |

For each stage:
- **Record Input/Output Weight** — Track weight before and after processing
- **Auto Wastage Calculation** — Wastage = Input − Output
- **Notes & Sorting Method** — Add notes and sorting method (for grading)
- **Stage Revert** — Undo a stage and re-process if needed

### 📊 Lot Detail Page
- **Full Stage Timeline** — Visual timeline showing each stage's progress
- **Weight Flow Tracking** — See how weight changes through each stage
- **Wastage per Stage** — Breakdown of loss at every processing step
- **Lot Status** — PENDING → PROCESSING → COMPLETED

### ✅ Finished Stock
- **Auto-Created on Completion** — When packing is done, finished stock record is created
- **Track Packed Weight** — Total packed weight from final stage
- **Dispatch Management** — Record dispatches against finished stock
- **Available Weight** — Real-time available = packed − dispatched

### 📈 Dashboard & Analytics
- **Total Raw Stock** — Total received and available weight
- **Processing Stats** — Number of active lots and their combined weight
- **Finished Stock Stats** — Available finished stock and total dispatched
- **Multi-Factory Overview** — Global dashboard aggregating all factory data
- **Per-Factory Cards** — Individual metrics for each factory including yield percentage

### 📉 Wastage Tracking
- **Dedicated Wastage Screen** — View all wastage across lots and stages
- **Wastage by Stage** — Identify which stages have the highest loss
- **Process Optimization** — Data-driven decisions to reduce waste

### ⚙️ Settings & Administration
- **Theme Toggle** — Switch between light and dark modes
- **Reset All Data** — Danger zone: wipe all factory data while keeping user accounts
- **How-to-Use Guides** — Every page includes an interactive guide explaining the workflow

### 📱 Real-Time Live Updates
- **Firestore Stream Listeners** — All data sections auto-refresh when data changes
- **Multi-Device Sync** — Changes made on one device instantly appear on all others
- **No Manual Refresh** — Dashboard, stock lists, processing — everything updates live

---

## 🛠 Tech Stack

### Frontend (Mobile + Web)
| Technology | Purpose |
|-----------|---------|
| **Flutter 3.12+** | Cross-platform UI framework (Android, iOS, Web) |
| **Dart** | Programming language |
| **Riverpod** | State management with reactive providers |
| **GoRouter** | Declarative routing and deep-linking |
| **RxDart** | Reactive stream transformations for live data |
| **Google Fonts** | Typography (Inter, Roboto) |
| **FL Chart** | Data visualization and charts |
| **Shimmer** | Loading skeleton animations |
| **Flutter Animate** | Micro-animations and transitions |
| **Lottie** | Premium animated illustrations |

### Backend & Database
| Technology | Purpose |
|-----------|---------|
| **Firebase Auth** | Google Sign-In and Email/Password authentication |
| **Cloud Firestore** | NoSQL real-time database |
| **Firebase Hosting** | Web app deployment at [hm-nuts.web.app](https://hm-nuts.web.app) |

### Dev Tools
| Technology | Purpose |
|-----------|---------|
| **Git / GitHub** | Version control |
| **Firebase CLI** | Deployment automation |
| **Flutter DevTools** | Performance profiling |

---

## 📁 Project Structure

```
cashew-factory-management-system/
├── lib/
│   ├── main.dart                          # App entry, routing, theme setup
│   ├── firebase_options.dart              # Firebase configuration
│   ├── config/
│   │   ├── constants.dart                 # App-wide constants
│   │   └── themes.dart                    # Light & dark theme definitions
│   ├── core/
│   │   ├── network/
│   │   │   └── api_client.dart            # HTTP client & factory ID management
│   │   └── utils/
│   │       └── date_parser.dart           # Date parsing utilities
│   ├── providers/
│   │   ├── stock_providers.dart           # All data providers (live streams)
│   │   └── theme_provider.dart            # Theme state management
│   ├── features/
│   │   ├── auth/
│   │   │   ├── providers/auth_provider.dart
│   │   │   └── screens/
│   │   │       ├── login_screen.dart          # Google + Email login
│   │   │       ├── forgot_password_screen.dart
│   │   │       └── setup_wizard_screen.dart   # Owner PIN setup
│   │   ├── splash/
│   │   │   └── splash_screen.dart         # Animated splash screen
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart      # Main dashboard with stats
│   │   │   └── widgets/
│   │   │       └── factory_selector.dart  # Factory dropdown
│   │   ├── factory/
│   │   │   ├── factory_setup_screen.dart      # First-time factory creation
│   │   │   ├── factory_management_screen.dart # Multi-factory management
│   │   │   └── factory_selector_widget.dart   # Reusable factory picker
│   │   ├── raw_stock/
│   │   │   ├── raw_stock_screen.dart          # Raw stock list + CRUD
│   │   │   └── raw_stock_detail_page.dart     # Raw stock detail view
│   │   ├── sorting/
│   │   │   ├── sorting_screen.dart            # Sorting history list
│   │   │   └── create_sorting_page.dart       # Create new sorting
│   │   ├── processing/
│   │   │   ├── processing_screen.dart         # Lot list (processing/completed)
│   │   │   └── lot_detail_page.dart           # 8-stage processing timeline
│   │   ├── finished/
│   │   │   └── finished_stock_screen.dart     # Finished stock + dispatch
│   │   ├── wastage/
│   │   │   └── wastage_screen.dart            # Wastage analytics
│   │   └── settings/
│   │       ├── settings_screen.dart           # App settings + danger zone
│   │       └── guide_screen.dart              # Help & how-to guides
│   └── shared/
│       └── widgets/
│           ├── common_widgets.dart            # Reusable UI components
│           ├── confirmation_dialog.dart       # Delete/action confirmation
│           ├── empty_state_widget.dart        # Empty state with guide
│           ├── logout_action.dart             # Logout button
│           ├── responsive_grid_row.dart       # Responsive grid layout
│           └── shimmer_loading.dart           # Loading skeletons
├── assets/
│   ├── images/
│   │   ├── logo.png                       # App logo
│   │   └── google_logo.png               # Google sign-in logo
│   └── icons/
├── android/                               # Android native code
├── ios/                                   # iOS native code
├── web/                                   # Web-specific assets
├── releases/
│   └── HMNuts-v1.0-release.apk          # Android APK for testing
├── pubspec.yaml                           # Flutter dependencies
├── firebase.json                          # Firebase hosting config
└── README.md                              # This file
```

---

## 🔄 How the Cashew Processing Flow Works

```
┌─────────────┐
│  Raw Cashew  │  ← Receive from supplier (weight, price, date)
│  Stock Entry │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Sorting    │  ← Split raw stock into processing lots
│  (Raw → Lots)│     Deducts from raw stock automatically
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────┐
│              8-Stage Processing                  │
│                                                  │
│  Cleaning → Boiling → Cooling → Shelling →      │
│  Drying → Peeling → Grading → Packing           │
│                                                  │
│  Each stage records input/output weight          │
│  Wastage = input − output (auto-calculated)      │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
              ┌─────────────┐
              │  Finished    │  ← Auto-created when packing completes
              │  Stock       │     Track packed weight & dispatches
              └──────┬──────┘
                     │
                     ▼
              ┌─────────────┐
              │  Dispatch    │  ← Record outgoing dispatches
              │              │     Available = packed − dispatched
              └─────────────┘
```

---

## 💼 How This Helps Cashew Businesses

| Problem | Solution |
|---------|----------|
| Manual paper records get lost | All data stored in cloud, accessible anywhere |
| No visibility across stages | Real-time stage-by-stage weight tracking |
| Can't track wastage | Automatic wastage calculation at every stage |
| Multiple factories hard to manage | Multi-factory support with global dashboard |
| Delays in knowing stock availability | Live-updating dashboards and stock counters |
| No dispatch tracking | Record every dispatch against finished stock |
| Workers can't access data | Web app works on any device with a browser |
| Manual yield calculations | Auto-calculated yield % (finished ÷ initial weight) |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.12+
- Dart SDK 3.0+
- Firebase project with Firestore and Auth enabled
- Node.js 18+ (for backend, if used)

### Installation

```bash
# Clone the repository
git clone https://github.com/PoojanPatel7/Cashew-Factory-Management-System.git
cd Cashew-Factory-Management-System

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome    # For web
flutter run               # For connected device
```

### Build

```bash
# Build Web
flutter build web --release

# Build Android APK
flutter build apk --release

# Deploy to Firebase
firebase deploy --only hosting
```

---

## 📱 Screenshots

| Dashboard | Raw Stock | Processing |
|-----------|-----------|------------|
| Multi-factory overview with live stats | Add, edit, track raw cashew inventory | 8-stage processing with weight tracking |

| Sorting | Finished Stock | Settings |
|---------|---------------|----------|
| Split raw stock into processing lots | Track packed weight and dispatches | Theme toggle, guides, data reset |

---

## 🔐 Security

- **Firebase Auth** — Secure authentication via Google or email/password
- **Owner PIN** — Secret 4-digit PIN to assign owner role (prevents unauthorized admin access)
- **Firestore Rules** — Data access scoped to authenticated users
- **Factory-Level Isolation** — Each factory's data is isolated by `factoryId`

---

## 📋 Version History

| Version | Date | Changes |
|---------|------|---------|
| **v1.0** | June 2026 | Initial release — Full cashew processing pipeline, multi-factory support, real-time live updates, Google Sign-In, owner PIN system, 8-stage processing, wastage tracking, dispatch management, comprehensive guides |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is proprietary software owned by HMNuts.

---

## 👨‍💻 Author

**Poojan Patel**
- GitHub: [@PoojanPatel7](https://github.com/PoojanPatel7)

---

<p align="center">
  Made with ❤️ for the Cashew Industry
</p>
