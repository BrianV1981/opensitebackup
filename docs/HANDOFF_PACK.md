# OpenSiteBackup — Handoff Pack

## Purpose

This index is the single entry point for transferring OpenSiteBackup to another engineering team.
It defines what to read, what artifacts must be present, and how to sign off that handoff is complete.

---

## 1) Required reading order

1. `README.md`
2. `docs/architecture.md`
3. `docs/architecture_decisions.md`
4. `docs/runbook.md`
5. `docs/troubleshooting.md`
6. `docs/troubleshooting_matrix.md`
7. `strategy/90_day_execution_plan.md`
8. `strategy/12_month_monetization_roadmap.md`
9. `docs/positioning_and_gtm.md`
10. `docs/handoff_checklist.md`

---

## 2) Required artifacts (must exist before handoff)

## Documentation
- [ ] Project overview (`README.md`)
- [ ] Architecture (`docs/architecture.md`)
- [ ] 90-day plan (`strategy/90_day_execution_plan.md`)
- [ ] Monetization roadmap (`strategy/12_month_monetization_roadmap.md`)
- [ ] Positioning/Go-to-market (`docs/positioning_and_gtm.md`)
- [ ] Handoff checklist (`docs/handoff_checklist.md`)

## Operational evidence (from real runs)
- [ ] Successful backup log
- [ ] Successful verify log
- [ ] Successful upload log
- [ ] Successful restore drill log
- [ ] Manifest sample (`manifest.txt`)
- [ ] Checksum sample (`local_sha256.txt`)
- [ ] Restore metrics sample (`data/state/restore_metrics.jsonl`)

## Configuration package
- [ ] Environment template (no secrets)
- [ ] Tool prerequisite list
- [ ] Backend setup instructions
- [ ] Secret handling policy

---

## 3) Handoff acceptance criteria

Handoff is accepted only when receiving team can:

1. Explain architecture and adapter/backend model
2. Run backup from docs-only instructions
3. Run verify and interpret outputs
4. Run upload with selected backend
5. Execute a restore drill and validate result
6. Continue roadmap work with assigned milestones

---

## 4) Suggested handoff meeting agenda (60 minutes)

1. Product context + differentiation (10 min)
2. Architecture walkthrough (15 min)
3. Live demo: backup -> verify -> upload -> restore (20 min)
4. Risks and known issues (10 min)
5. Ownership and next sprint assignment (5 min)

---

## 5) Ownership signoff

## Transfer metadata
- Project: OpenSiteBackup
- Date:
- Outgoing lead:
- Receiving lead:

## Signoff checklist
- [ ] All required docs delivered
- [ ] All required artifacts delivered
- [ ] Access and environments confirmed
- [ ] Initial sprint tasks assigned
- [ ] Risk register reviewed

Outgoing lead signature: ______________________

Receiving lead signature: _____________________

---

## 6) Quick links

- Root README: `../README.md`
- Architecture: `./architecture.md`
- Architecture decisions: `./architecture_decisions.md`
- Runbook: `./runbook.md`
- Troubleshooting: `./troubleshooting.md`
- Troubleshooting matrix: `./troubleshooting_matrix.md`
- Handoff checklist: `./handoff_checklist.md`
- Release checklist: `./release_checklist.md`
- Launch readiness tracker: `./launch_readiness.md`
- Go/No-Go decision guide: `./go_no_go.md`
- Release notes template: `./release_notes_template.md`
- 90-day plan: `../strategy/90_day_execution_plan.md`
- Monetization roadmap: `../strategy/12_month_monetization_roadmap.md`
- Positioning/GTM: `./positioning_and_gtm.md`
