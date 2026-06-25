# Backend Phase 1 — Foundation & Encrypt Engine Integration
## Version: `b0.1.0`

---

## 🎯 Objective
Set up the core Node.js (TypeScript) backend server, configure the PostgreSQL database using Prisma ORM, and critically, establish the bridge to the **Encrypt Engine** located at `E:\encrypt engine`. All sensitive data (PII, financials) must be routed through the Encrypt Engine before being saved to the database.

## 🏗 Architecture
- **Framework:** Node.js + Express + TypeScript
- **Database:** PostgreSQL
- **ORM:** Prisma
- **Encryption Bridge:** child_process / HTTP bridge to `E:\encrypt engine`
- **Auth:** JWT (JSON Web Tokens)

---

## 📝 Step-by-Step Implementation

### Step 1: Project Initialization
- [ ] Create `cashew-backend` folder.
- [ ] Initialize `npm init -y` and install dependencies (`express`, `typescript`, `prisma`, `cors`, `helmet`, `jsonwebtoken`, `zod`).
- [ ] Set up `tsconfig.json` and basic Express server in `src/server.ts`.
- [ ] Configure `.env` for Database URL and JWT Secret.

### Step 2: Encrypt Engine Bridge (`src/services/encryptService.ts`)
- [ ] Build a service that communicates with your Encrypt Engine.
- [ ] **Implementation approach:** Since the engine is at `E:\encrypt engine`, the backend will spawn a child process OR make local HTTP calls to the engine to encrypt/decrypt strings.
- [ ] Create `encrypt(text: string): Promise<string>` function.
- [ ] Create `decrypt(cipher: string): Promise<string>` function.
- [ ] Add caching (Redis or in-memory) for frequently decrypted non-sensitive config keys, but NEVER cache PII.

### Step 3: Database Schema Setup (Prisma)
- [ ] Define the `User` model in `schema.prisma` (id, email, passwordHash, role, encryptedName).
- [ ] Define `AuditLog` model to track security events.
- [ ] Run `npx prisma migrate dev` to create the PostgreSQL tables.

### Step 4: Authentication & Security Middleware
- [ ] Implement user registration endpoint `/api/auth/register` (passwords hashed via bcrypt, names encrypted via Encrypt Engine).
- [ ] Implement login endpoint `/api/auth/login` returning JWT.
- [ ] Create `authMiddleware.ts` to verify JWT and attach user role to the request.
- [ ] Create `roleMiddleware.ts` to restrict endpoints (e.g., `requireRole(['OWNER', 'MANAGER'])`).

### Step 5: Unit Testing & Validation
- [ ] Set up `Jest` and `Supertest`.
- [ ] Write tests for the Encrypt Engine Bridge (mocking the engine response).
- [ ] Write integration tests for `/auth/login` and `/auth/register`.

## ✅ Completion Criteria
- Express server boots successfully.
- Calling the `encryptService` successfully interfaces with `E:\encrypt engine` and returns cipher text.
- Database contains registered users with their names stored exclusively as cipher text.
- JWT authentication protects dummy routes.
