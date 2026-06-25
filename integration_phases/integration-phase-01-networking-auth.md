# Integration Phase 1 — Networking Foundation & Authentication
## Version: `i1.0.0`

---

## 🎯 Objective
Establish the core HTTP networking layer in Flutter using `dio`, replace the mock Authentication system with real Node.js API calls, and enforce Role-Based Access Control (RBAC) so that factory workers see different screens than the Owner.

## 📝 Step-by-Step Implementation

### Step 1: Dio Client Setup (`lib/core/network/api_client.dart`)
- [ ] Create a singleton `ApiClient` class utilizing `dio`.
- [ ] Configure `BaseOptions` with `baseUrl: apiConfig.apiBaseUrl`.
- [ ] Add an Interceptor to automatically attach the `Bearer Token` to every outgoing request.
- [ ] Add error handling to catch `401 Unauthorized` responses and redirect the user back to the Login Screen.

### Step 2: Auth Provider & Service (`lib/features/auth/`)
- [ ] Create `AuthRepository` that points to `/api/auth/login`.
- [ ] Update the Flutter `LoginScreen`. When the user clicks login:
  - Call the API.
  - Wait for the JSON response containing the `token` and `user.role`.
  - Save the `token` locally using `flutter_secure_storage` or `shared_preferences`.
- [ ] Create an `AuthProvider` (using Riverpod or Provider) to hold the current user's state globally.

### Step 3: Role-Based Routing (`lib/config/routes.dart`)
- [ ] Update the router so that the initial route checks if a token exists. If yes -> `AppScaffold`, if no -> `LoginScreen`.
- [ ] Within `AppScaffold`, dynamically hide/show sidebar navigation items based on the user's role (e.g., Worker cannot see Accounting).

## ✅ Completion Criteria
- User can successfully log in using an email/password stored in the PostgreSQL database.
- The JWT token is successfully stored on the device.
- The UI properly hides administrative tabs from low-level operators.
