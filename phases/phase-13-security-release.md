# Phase 13 — Security Audit & Production Release (Week 24)
## Version: `v1.0.0` 🎉

---

## 🎨 UI Reference
- "Security dashboard monitoring dark UI"
- "App store screenshots professional design"
- "Production deployment checklist design"

---

### Day 1: Security Hardening
- [ ] **API Security:**
  - Rate limiting per user/IP (100 req/min)
  - Input sanitization on ALL endpoints (Zod validation)
  - SQL injection prevention (Prisma parameterized queries)
  - XSS prevention (sanitize all user inputs before rendering)
  - CSRF protection for state-changing endpoints
  - CORS configured for allowed origins only
  - HTTPS enforcement via Nginx (TLS 1.3)
- [ ] **Authentication Security:**
  - JWT rotation: access token 1hr, refresh token 7d
  - Token revocation on logout (blacklist in Redis)
  - Auto-logout on inactivity (configurable: 15/30/60 min)
  - Brute force protection: lock account after 5 failed attempts (30 min cooldown)
  - Password policy: min 8 chars, uppercase, number, special char
- [ ] **Encrypt Engine Verification:**
  - All PII encrypted in database (spot check: employees, suppliers, customers)
  - HMAC hashes working for searchable fields
  - Audit log of every encrypt/decrypt operation
  - Key rotation procedure documented
- [ ] **Data Protection:**
  - Automated daily backups with 30-day retention
  - Backup encryption using Encrypt Engine
  - Data encryption at rest (database level)
  - Sensitive fields NEVER appear in logs
- [ ] **Security Dashboard Page (Owner Only):**
  - Encrypt Engine health status
  - Last backup time
  - Failed login attempts list
  - Active sessions list (force-logout option)
  - Audit log viewer (who accessed what, when)

### Day 2: Performance Optimization
- [ ] **API Performance:**
  - Database query optimization (analyze slow queries)
  - Add indexes on: date, status, foreign keys, lookup hashes
  - Redis caching for dashboard endpoints (30s TTL)
  - Pagination on ALL list endpoints (default 20 per page)
  - Gzip compression on API responses
- [ ] **Flutter Performance:**
  - `const` widgets everywhere possible
  - Lazy loading for long lists (ListView.builder)
  - Image compression before upload (max 1MB)
  - Chart data caching (don't re-fetch on tab switch)
  - Route-based code splitting (deferred imports)
  - Profiling: 60fps target on mid-range Android device
- [ ] **Database Performance:**
  - Connection pooling configured
  - Query result caching for reports
  - Archive old data (> 2 years) to separate table

### Day 3: End-to-End Testing
- [ ] **Full Business Flow Test:**
  1. Owner registers → sets up factory
  2. Creates users: Manager, Supervisor, Accountant, Operator, Worker
  3. Adds suppliers → Creates purchase orders → Receives goods
  4. Starts processing lots → 12 stages → Grades output
  5. Creates sales orders → Generates invoices → Dispatches
  6. Records expenses → Generates payroll → Views P&L
  7. Registers machines → Logs work → Schedules maintenance
  8. Uploads compliance docs → Receives expiry alerts
  9. Views reports → Exports to Excel/PDF
- [ ] **Role Testing (Each Role Separately):**
  - Login as each role → verify correct dashboard shows
  - Verify hidden nav items for restricted modules
  - Verify API returns 403 for unauthorized actions
  - Worker can ONLY see own data
  - Operator sees ONLY assigned machines
- [ ] **Confirmation Popup Audit:**
  - Every create action has confirmation popup ✅
  - Every update action has confirmation popup showing changes ✅
  - Every delete action has "Are you sure?" confirmation ✅
  - Popup shows accurate data preview ✅
- [ ] **Responsive Test:**
  - Every page tested on: 360px (phone), 768px (tablet), 1440px (desktop)
  - Navigation: bottom nav / rail / sidebar transitions correctly
  - Tables switch to card lists on mobile
  - Forms stack vertically on mobile, horizontal on desktop
- [ ] **Theme Test:** Switch between all 5 themes on every key page
- [ ] **Language Test:** Switch EN/HI/GU, verify all labels translate
- [ ] **Offline Test:** Go offline → perform actions → reconnect → verify sync

### Day 4: Production Build & Documentation
- [ ] **Android APK:** `flutter build apk --release` (signed with keystore)
- [ ] **Flutter Web:** `flutter build web` (for Machinery Portal)
- [ ] **Docker Images:** Tag all services as `v1.0.0`
- [ ] **Docker Compose Production Config:**
  - Environment variables documented
  - SSL certificate setup guide
  - Encrypt Engine master key generation guide
  - Database backup cron job setup
- [ ] **Documentation Files:**
  - `README.md` — Project overview, features, screenshots, architecture diagram
  - `SETUP.md` — Step-by-step server setup guide:
    1. Server requirements (2GB RAM, 20GB disk, Ubuntu/CentOS)
    2. Install Docker & Docker Compose
    3. Clone repo, configure .env
    4. Generate Encrypt Engine master key
    5. Run docker-compose up
    6. Access admin panel, create first user
  - `USER_GUIDE.md` — End-user manual with screenshots for each module
  - `API_DOCS.md` — Full REST API documentation (endpoints, request/response)
  - `CHANGELOG.md` — All versions v0.1.0 through v1.0.0

### Day 5: Final Release
- [ ] **Version bump:** `pubspec.yaml` → `version: 1.0.0+1`
- [ ] **App icon:** CashewPro branded icon (cashew nut silhouette + gold gradient)
- [ ] **Splash screen:** Animated CashewPro logo (3 seconds)
- [ ] **Final smoke test** on real Android device
- [ ] **Screenshot capture** for documentation (all key screens)

## Git Commit
```bash
git add .
git commit -m "v1.0.0: Production Release - Security hardened, performance optimized, fully tested, documented, production Docker images"
git tag v1.0.0
git push origin main --tags
```

---

# 🎉 v1.0.0 Release Checklist

## Functionality
- [ ] All 15 modules working end-to-end
- [ ] 6 user roles with correct access control
- [ ] Confirmation popups on every data push action
- [ ] 30+ reports generating accurately
- [ ] PDF/Excel export working

## Design
- [ ] 5 themes available and switching correctly
- [ ] Responsive on mobile/tablet/desktop
- [ ] Micro-animations and transitions polished
- [ ] Empty states, error states, loading states complete
- [ ] Onboarding tours for each role

## Technical
- [ ] Encrypt Engine encrypting all PII in database
- [ ] Offline sync working with conflict resolution
- [ ] Multi-language (EN/HI/GU) complete
- [ ] WebSocket real-time updates on dashboards
- [ ] Push notifications delivering
- [ ] IoT MQTT integration for machinery

## Deployment
- [ ] Docker Compose deploys all services
- [ ] SSL/HTTPS configured
- [ ] Database backup automation set up
- [ ] Signed Android APK ready
- [ ] Flutter Web build for Machinery Portal ready

## Documentation
- [ ] README, SETUP, USER_GUIDE, API_DOCS, CHANGELOG complete
- [ ] GitHub repository tagged v1.0.0
- [ ] Screenshots captured for all key screens
