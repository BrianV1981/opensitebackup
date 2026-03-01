# OpenSiteBackup — 90-Day Execution Plan (Handoff-Ready)

## Document intent

This document is written for a separate engineering team to execute OpenSiteBackup with minimal ambiguity.
It defines:
- Scope
- Architecture direction
- Milestones
- Deliverables
- Acceptance criteria
- Ownership model
- Risks and dependencies

---

## 1) Product definition (v1)

## Problem
Website owners and agencies often believe they are "backed up" but cannot reliably restore. Existing plugin-based approaches can fail silently due to host limits, missing files, partial DB exports, or non-tested restore paths.

## v1 objective
Deliver an open-source, provider-flexible backup pipeline that proves restore viability through deterministic verification and restore drills.

## v1 non-goals
- Full enterprise SaaS in 90 days
- Broad CMS coverage at launch
- Perfect GUI UX at launch

## v1 launch scope
- WordPress adapter first
- Backup: live files + DB
- Verify: archive readability + SQL checks + checksums + manifest
- Upload: pluggable backends (minimum: local + one cloud backend)
- Restore: local drill path with URL rewriting
- Docs: production-grade runbook + handoff docs

---

## 2) Architecture direction

## Core design principle
Keep backup engine provider-agnostic and adapter-driven.

## Components
1. **Core runner**
   - Orchestrates backup -> verify -> upload -> restore
   - Uniform logging and exit codes

2. **Source adapters**
   - `wordpress` (v1)
   - Future: static, Ghost, custom app

3. **Storage adapters**
   - `local` (v1)
   - `rclone` (v1 recommended)
   - `gdrive-gog` (optional)
   - Future: S3 native, B2 native

4. **Verification module**
   - sha256 checksums
   - tar test (`tar -tzf`)
   - SQL sanity (`CREATE TABLE`, `INSERT INTO`)
   - manifest generation

5. **Restore module**
   - Extract + DB import + search-replace + post-checks

## Suggested repo structure

```text
opensitebackup/
  adapters/
    wordpress/
      backup.sh
      restore.sh
      verify.sh
  backends/
    local/
      upload.sh
    rclone/
      upload.sh
    gog/
      upload.sh
  scripts/
    bootstrap.sh
    run_backup.sh
    run_verify.sh
    run_upload.sh
    run_restore.sh
  docs/
    architecture.md
    runbook.md
    troubleshooting.md
  examples/
    env.wordpress.example
  strategy/
    90_day_execution_plan.md
  tests/
  LICENSE
  README.md
```

---

## 3) Delivery model (90 days)

## Phase 0 — Alignment & setup (Week 1)

### Deliverables
- Confirm product name: OpenSiteBackup
- Confirm license (MIT or Apache-2.0)
- Repo initialized with base structure
- CODEOWNERS + branch strategy + issue labels

### Acceptance criteria
- Team can clone repo and run bootstrap shell checks
- CI runs lint for shell/docs

---

## Phase 1 — Stable WordPress backup core (Weeks 2-4)

### Work items
- Normalize env/config format
- Harden WordPress backup adapter
  - Handle SSH key auth edge cases
  - Handle unreadable/transient files with safe excludes
  - Use absolute remote paths
- Deterministic stage logs (`[1/5]`, etc.)
- Exit codes for each failure class

### Deliverables
- `adapters/wordpress/backup.sh`
- `scripts/run_backup.sh`
- Integration test script for dry-run and live-run checks

### Acceptance criteria
- Successful full backup from at least 2 real WP hosts
- Backups include media + DB
- No silent failure paths

---

## Phase 2 — Verification and restore drill (Weeks 5-6)

### Work items
- Implement verify module
  - checksum generation
  - tar integrity test
  - SQL sanity checks
  - manifest output
- Implement restore module
  - clean target path
  - DB import
  - URL rewrite
  - post-restore health checks

### Deliverables
- `adapters/wordpress/verify.sh`
- `adapters/wordpress/restore.sh`
- `scripts/run_verify.sh`
- `scripts/run_restore.sh`

### Acceptance criteria
- Restore drill passes on local WSL target
- Post-restore checks confirm WP usability
- Manifest and checksum output reproducible

---

## Phase 3 — Provider-flexible upload (Weeks 7-8)

### Work items
- Abstract upload backend interface
- Implement `local` backend
- Implement `rclone` backend (recommended default cloud path)
- Keep `gog` backend optional and isolated
- Add progress logging and duration metrics

### Deliverables
- `backends/local/upload.sh`
- `backends/rclone/upload.sh`
- `backends/gog/upload.sh` (optional)
- `scripts/run_upload.sh`

### Acceptance criteria
- Same backup can upload with backend switch only (no core changes)
- Upload logs include timestamps, file sizes, duration
- Failure retries documented (and partially automated)

---

## Phase 4 — Documentation and handoff quality (Weeks 9-10)

### Work items
- Rewrite docs for external team onboarding
- Add architecture decisions and troubleshooting matrix
- Add operator runbook and DR drill checklist
- Add contribution and release process docs

### Deliverables
- `README.md` (public-facing)
- `docs/architecture.md`
- `docs/runbook.md`
- `docs/troubleshooting.md`
- `CONTRIBUTING.md`

### Acceptance criteria
- New engineer can run first backup from docs only
- New operator can run restore drill from docs only
- All scripts have usage blocks and examples

---

## Phase 5 — Launch readiness (Weeks 11-12)

### Work items
- Public repo hardening
- CI checks for shell/docs examples
- Release tag `v0.1.0`
- Launch materials (demo video + comparison table)

### Deliverables
- First OSS release
- Changelog + roadmap
- Issue templates for bugs/features

### Acceptance criteria
- 3 external users can complete backup/verify/upload flow
- At least 1 external successful restore report

---

## 4) Roles & responsibilities (suggested)

- **Tech lead**: architecture decisions, standards, release gating
- **Platform engineer**: backup/restore scripts + adapters
- **Infra engineer**: backend upload adapters and reliability
- **DX/documentation lead**: docs, examples, onboarding
- **QA engineer**: restore drill test matrix and regression checks

---

## 5) Handoff package requirements

Before handing to another code team, include:

1. Current repository snapshot and branch naming conventions
2. `.env` template(s) with variable explanations
3. End-to-end sequence diagram (backup -> verify -> upload -> restore)
4. Known host/provider quirks and workarounds
5. Example logs of a successful full run
6. Restore drill evidence with timestamps
7. Open issues list with severity and ownership

---

## 6) Risk register and mitigations

## Risk A: Host-specific permission failures during archive
- Mitigation: `--ignore-failed-read` + explicit excludes + warning logs

## Risk B: SSH auth instability across environments (PowerShell vs WSL)
- Mitigation: WSL-native key path, key permission checks, preflight test command

## Risk C: Cloud upload lock-in
- Mitigation: adapter interface + default to rclone backend

## Risk D: False confidence from backup-only runs
- Mitigation: mandatory restore drill policy for release criteria

## Risk E: Scope creep (multi-CMS too early)
- Mitigation: lock v1 to WordPress, define v2 adapter expansion

---

## 7) Operational metrics (must track)

- Backup success rate
- Verify success rate
- Restore drill success rate
- Mean backup duration
- Mean restore duration
- Time-to-recovery (TTR)
- Upload failure/retry counts by backend

---

## 8) Definition of done (v1)

OpenSiteBackup v1 is done when all are true:

- [ ] WordPress full backup works on multiple hosts
- [ ] Verify artifacts are deterministic and documented
- [ ] Upload backend can be switched without core code changes
- [ ] Restore drill succeeds from docs-only execution
- [ ] Public docs are sufficient for third-party engineering handoff
- [ ] First tagged OSS release is published

---

## 9) Next-step backlog (post-v1)

- Incremental backups
- Built-in scheduler
- Notifications (Discord/Slack/email)
- Team/RBAC + audit log (hosted control plane)
- Additional source adapters (Ghost/static/custom)
- Encryption at rest and key management policy

---

## 10) Immediate action checklist (next 7 days)

- [ ] Initialize repo standards (license, CI, contribution docs)
- [ ] Refactor current scripts into adapter/backend structure
- [ ] Add preflight command: SSH + path + WP-CLI checks
- [ ] Capture one complete successful run log set
- [ ] Record one successful restore drill log set
- [ ] Publish `v0.1.0-alpha` internal tag
