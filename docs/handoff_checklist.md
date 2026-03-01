# OpenSiteBackup — Engineering Handoff Checklist

Use this checklist when transferring execution to another engineering team.

---

## A) Repo & governance handoff

- [ ] Repository URL shared
- [ ] Default branch policy documented
- [ ] Protected branch rules configured
- [ ] CODEOWNERS configured
- [ ] Issue templates enabled (bug/feature/task)
- [ ] Project board/tickets created for 90-day milestones

---

## B) Product/context handoff

- [ ] Product name confirmed: **OpenSiteBackup**
- [ ] Problem statement shared (restore-first backup)
- [ ] v1 scope agreed (WordPress-first)
- [ ] Non-goals agreed (no full SaaS in first 90 days)
- [ ] Success metrics reviewed (backup/verify/restore rates)

---

## C) Documentation handoff package

- [ ] `README.md` reviewed
- [ ] `strategy/90_day_execution_plan.md` reviewed
- [ ] `strategy/12_month_monetization_roadmap.md` reviewed
- [ ] `docs/architecture.md` reviewed
- [ ] `docs/positioning_and_gtm.md` reviewed
- [ ] Runbook(s) linked and accessible

---

## D) Environment and access handoff

- [ ] Source host access model documented (SSH)
- [ ] Required credentials inventory documented (without exposing secrets)
- [ ] Cloud provider/backend access documented
- [ ] WSL/Linux assumptions documented
- [ ] Tool prerequisites listed (`ssh`, `wp`, `tar`, backend tools)

---

## E) Config handoff

- [ ] `env` template provided with comments
- [ ] Required variables marked mandatory
- [ ] Example values included (safe placeholders)
- [ ] Secret handling policy documented
- [ ] `.gitignore` excludes secrets/backups/dumps

---

## F) Pipeline functionality handoff

### Backup
- [ ] Source adapter can produce full files archive
- [ ] Source adapter can export DB dump
- [ ] Remote temp files cleanup behavior documented

### Verify
- [ ] Tar integrity test implemented
- [ ] SQL sanity checks implemented
- [ ] Checksums generated
- [ ] Manifest generated

### Upload
- [ ] Backend abstraction implemented
- [ ] At least one cloud backend working
- [ ] Upload logs include timestamps and durations
- [ ] Backend selection validated via `OSB_BACKEND` (`gog|local|rclone`)

### Restore
- [ ] Local restore script implemented
- [ ] URL rewrite step documented
- [ ] Post-restore health checks documented
- [ ] Drive restore env requirements documented (`LOCAL_DB_NAME`, `LOCAL_DB_USER`, `LOCAL_DB_PASSWORD`, optional `LOCAL_DB_HOST`)

---

## G) Test evidence handoff

- [ ] One successful real backup log attached
- [ ] One successful verify log attached
- [ ] One successful upload log attached
- [ ] One successful restore drill log attached
- [ ] Artifact sample set available (or secure references)
- [ ] One restore metrics sample row attached (`data/state/restore_metrics.jsonl`)

---

## H) Risk/troubleshooting handoff

- [ ] Known SSH auth pitfalls documented (PowerShell vs WSL)
- [ ] Known permission pitfalls documented
- [ ] Known host file-read pitfalls documented
- [ ] Retry/recovery steps documented for failed stage
- [ ] Escalation owner for each failure type assigned

---

## I) Delivery plan handoff (execution readiness)

- [ ] Milestones imported into ticket tracker
- [ ] Owners assigned per phase
- [ ] Weekly review cadence set
- [ ] Demo checkpoints scheduled (backup, verify, restore)
- [ ] Release criteria for `v0.1.0` agreed

---

## J) Definition of handoff complete

Handoff is complete only when all are true:

- [ ] Receiving team can run backup from docs-only instructions
- [ ] Receiving team can run restore drill from docs-only instructions
- [ ] Receiving team can explain architecture and extension model
- [ ] 90-day plan has owners and target dates

---

## Appendix — Minimum artifacts expected in first transfer

- Architecture doc
- Execution plan
- Runbook
- Environment template
- Successful run logs
- Known-issues list
- Next 2-week sprint board
