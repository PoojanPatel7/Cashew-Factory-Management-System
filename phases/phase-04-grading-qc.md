# Phase 4 — Grading & Quality Control (Week 9)
## Version: `v0.4.0`

---

## 🎨 UI Reference
- "Quality control checklist UI dark theme"
- "Product grading dashboard pie chart design"
- "Certificate PDF generator modern design"

## 🔑 Role Access

| Feature | Owner | Manager | Supervisor | Accountant | Operator | Worker |
|---|---|---|---|---|---|---|
| Grade lots | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| QC checklists | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| View grade stock | ✅ | ✅ | ✅ | ✅ (read) | ❌ | ❌ |
| Update grade prices | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Generate certificates | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |

---

### Day 1-2: Grading Pages
- [ ] **Grade Dashboard Page:** Cards per grade (W180-W450, SW, S, B, P) showing current stock kg, current price, % of total. Pie chart: grade distribution
- [ ] **Grading Entry Page:** Select lot → enter weight per grade → auto-calculate percentages. Pie chart preview updates live. **Confirmation popup** with grade breakdown table
- [ ] **Grade Price Master Page:** Editable list with current market rate per grade. Price history sparkline. **Confirmation popup** on price change

### Day 3-4: QC Pages
- [ ] **QC Checklist Page:** Digital form: Moisture % (slider), Color (picker), Broken ratio, Foreign material (toggle), Aflatoxin (pass/fail), Metal detection (pass/fail). Auto-calculate overall status. Photo capture. **Confirmation popup** with all parameters
- [ ] **Quality Certificate PDF Page:** Preview and generate PDF: Factory header, lot details, grade breakdown, QC results, inspector signature, date. Share/download

### Day 5: Testing
- [ ] Grade lot → verify finished goods inventory created per grade. Confirmation popups on all actions. Responsive on all screen sizes. Role checks working

## Git Commit
```bash
git add .
git commit -m "v0.4.0: Grading & QC - Grade classification (W180-W450), QC checklists, quality certificates, grade price master, confirmation popups"
git tag v0.4.0
git push origin main --tags
```
