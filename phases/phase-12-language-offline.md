# Phase 12 — Multi-Language & Offline Sync (Week 23)
## Version: `v0.12.0`

---

## 🎨 UI Reference
- "Multi language selector Flutter app design"
- "Offline sync indicator mobile app UI"
- "Data export settings page design dark"

---

### Day 1-2: Multi-Language Support (EN / HI / GU)
- [ ] **Flutter `intl` package** with ARB files:
  - `app_en.arb` — English (all 500+ strings)
  - `app_hi.arb` — Hindi (हिंदी) translation
  - `app_gu.arb` — Gujarati (ગુજરાતી) translation
- [ ] **Language Switcher Page** (in Settings):
  - 3 language cards: English, हिंदी, ગુજરાતી
  - Tap → instant language change (no restart needed)
  - **Confirmation popup:** "Change language to हिंदी?"
  - Persisted in SharedPreferences
- [ ] **What's translated:**
  - All UI labels, button text, menu items
  - Form field labels and hints
  - Error messages and validation messages
  - Empty state messages
  - Notification text
  - Report headers (data stays in original language)
- [ ] **Indian number format:** 1,00,000 (Lakh system) for Hindi/Gujarati, 100,000 for English
- [ ] **Date format:** DD/MM/YYYY for Indian locales
- [ ] **Keyboard support:** Hindi/Gujarati input for text fields (notes, descriptions)

### Day 3-4: Offline Mode & Data Sync
- [ ] **Local SQLite database (Drift)** — mirrors critical server tables:
  - employees (basic info only, not PII)
  - inventory_items (current stock)
  - processing_lots & stage_logs
  - attendance
  - piece_work
  - machines (status, basic info)
- [ ] **Offline Capabilities:**
  - View cached: inventory, lots, employees, machines
  - Create offline: attendance entries, piece-work logs, stage completions, machine work logs
  - All offline writes → stored in `sync_queue` table with timestamp
- [ ] **Sync Engine:**
  - On connectivity restore → push queued items in order
  - Pull server updates → merge with local
  - Conflict resolution: server-wins + user notified
  - Progress indicator: "Syncing 5/12 items..."
- [ ] **Sync Status Indicator** (always visible in app bar):
  - ✅ Green dot = fully synced
  - ⏳ Yellow dot = X items pending sync
  - ❌ Red dot = offline (with "Working Offline" banner)
  - Tap → shows sync details: last sync time, pending items, retry option
- [ ] **Offline Confirmation Popup:**
  ```
  ⚠️ You are offline
  This action will be saved locally and synced when connected.
  Pending sync items: 3
  [Cancel]  [Save Offline ✓]
  ```

### Day 5: Data Export & Testing
- [ ] **Data Export Page** (in Settings):
  - Export options: All Data | Module-specific
  - Formats: Excel (.xlsx) | CSV | PDF
  - Date range filter
  - **Confirmation popup:** "Export all inventory data as Excel?"
  - Download or share exported file
- [ ] **Database Backup Page:**
  - Manual backup button → creates backup file
  - Backup history list
  - Restore from backup option (Owner only)
  - **Confirmation popup:** "Create full database backup? This may take a few minutes."
- [ ] **Testing:**
  - Switch language EN → HI → GU → verify all UI labels change
  - Indian number formatting correct
  - Go offline → create records → come online → verify sync
  - Sync conflict scenario test
  - Data export generates valid Excel/CSV
  - Backup/restore cycle test
  - All confirmation popups work in all 3 languages

## Git Commit
```bash
git add .
git commit -m "v0.12.0: Multi-Language (EN/HI/GU), offline sync engine, data export (Excel/CSV/PDF), database backup/restore, sync status indicator"
git tag v0.12.0
git push origin main --tags
```
