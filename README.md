# Cashew Factory Management System 🏭

A comprehensive management system built to streamline the operations of a cashew processing factory. This application tracks raw cashew stock from processing through multiple stages up to final packaging and manages overall factory efficiency, data syncing, and user role-based access control.

## 🚀 Key Features

* **Multi-Factory Support**: Create and manage multiple factories under a single owner account. Switch between factories and have isolated data for each.
* **Full Process Lifecycle Tracking**: Track cashew processing through each stage:
  - 🧼 Cleaning
  - ♨️ Boiling
  - ❄️ Cooling
  - 🔨 Shelling
  - ☀️ Drying
  - 🔪 Peeling
  - 📏 Grading
  - 📦 Packing
* **Detailed Lot Management**: Process batches (lots) of raw materials and track wastage/weight loss at each stage. Includes the ability to *undo* to a previous stage.
* **Role-Based Authentication**: 
  - **Owner**: Full access, creation of factories, viewing aggregate stats.
  - **Manager**: Factory-level control and lot management.
* **Real-time Synchronization**: Frontend is connected to a Node.js API with a PostgreSQL database, ensuring all connected devices are up-to-date.
* **Interactive Dashboard**: Get a clear overview of raw stock, processed stock, and ongoing lots across the factory with a live activity log.

## 🛠 Technology Stack

### Frontend (Mobile & Web App)
* **Framework**: Flutter (Dart)
* **State Management**: Riverpod (`flutter_riverpod`)
* **Routing**: `go_router` for seamless navigation
* **Network & API**: `dio` for network requests
* **Authentication**: Firebase Authentication (Google Sign-In)
* **Design**: Premium glassmorphism UI, gradient headers, Lottie animations, and micro-interactions.

### Backend (REST API)
* **Runtime**: Node.js
* **Framework**: Express.js
* **Database**: PostgreSQL (Neon Database)
* **ORM**: Prisma
* **Authentication**: JWT & Firebase Admin integration

## 💼 Business Value

1. **Reduced Wastage & Shrinkage**: By meticulously tracking input and output weight at every processing stage, the factory can identify which step causes the most material loss.
2. **Real-time Inventory Control**: Eliminate manual logbooks. The owner always knows exactly how much raw material is available, how much is in-process, and how much finished product is packed.
3. **Traceability**: If a finished batch has quality issues, it can be traced back to the exact lot of raw cashews it originated from.
4. **Multi-location Scaling**: The system allows the owner to effortlessly manage multiple physical factory locations from a single dashboard.

## 📱 Releases

The Android APK is available in the **Releases** section of this repository. You can download the latest version (`v1`) and install it directly on your Android device to test the application.
