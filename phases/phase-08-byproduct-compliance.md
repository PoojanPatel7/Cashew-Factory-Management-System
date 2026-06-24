# Phase 8 — Byproduct & Compliance (Week 16)
## Version: `v0.8.0`

---

## 🎨 UI Reference
- "Waste management dashboard green dark UI"
- "Document expiry calendar alert design"
- "Compliance tracker dashboard modern"

## 🔑 Role Access: Owner + Manager (full), Supervisor (byproducts read), Accountant (compliance read)

---

### Day 1-2: Byproduct Pages
- [ ] **Byproduct Dashboard Page:** Cards: Shells (kg), CNSL (litres), Testa (kg), Rejects (kg) with stock + revenue. Revenue trend chart
- [ ] **Byproduct Sale Page:** Select type, buyer, quantity, rate. **Confirmation popup** with sale details + auto-ledger entry
- [ ] **CNSL Extraction Log Page:** Date, method, yield %, litres. Confirmation popup
- [ ] **Waste Disposal Log Page:** Type, quantity, method, date. Photo upload for proof

### Day 3-4: Compliance Pages
- [ ] **Compliance Dashboard Page:** Health score gauge (% of valid docs). Upcoming expirations list (color-coded). Calendar view with expiry dots
- [ ] **Document List Page:** Grouped by type, status badges (Active/Expiring/Expired). Upload + view PDF
- [ ] **Add Document Page:** Name, type dropdown, issue date, expiry date, file upload. Alert preferences: 30/15/7 day reminders. **Confirmation popup**
- [ ] **Document Detail Page:** Preview PDF, renewal reminder settings, history of uploads

### Day 5: Testing
- [ ] Processing stage → auto-creates byproduct entries
- [ ] Byproduct sale → confirmation → ledger entry
- [ ] Document upload → expiry alerts at 30/15/7 days
- [ ] Push notification for compliance alerts
- [ ] All confirmation popups, responsive layouts, role access

## Git Commit
```bash
git add .
git commit -m "v0.8.0: Byproduct management + Compliance tracking with expiry alerts, confirmation popups"
git tag v0.8.0
git push origin main --tags
```
