# OpenSiteBackup

**Open-source website backup and restore pipeline that actually proves recovery.**

Most tools stop at “backup complete.”
OpenSiteBackup is built for the moment that matters: **restore day**.

---

## Why OpenSiteBackup

If your host disappears, your plugin breaks, or an update wrecks production, you don’t need another ZIP file.
You need a **working site** back online.

OpenSiteBackup is designed around that reality:

- ✅ Full-site backup (files + database)
- ✅ Integrity checks (checksums + SQL sanity + archive test)
- ✅ Cloud copy support (provider-flexible)
- ✅ Real restore drills (local test environment)
- ✅ Operator-friendly logs and deterministic run outputs

---

## Proven in real use

OpenSiteBackup has already restored a real WordPress production snapshot locally including:

- Elementor-built pages/layouts
- Blog content and posts
- Theme configuration
- Full plugin ecosystem and settings
- Media/assets

In short: **not just files, full behavior parity from backup snapshot.**

---

## Core Features

## 1) Backup that includes everything needed for recovery
- WordPress files archive (`*_files.tar.gz`)
- Database dump (`*_db.sql`)
- Optional cloud upload targets

## 2) Verification by default
- `tar -tzf` archive integrity test
- SQL sanity checks (`CREATE TABLE`, `INSERT INTO`)
- SHA256 checksums
- Manifest generation

## 3) Cloud and local workflows
- Local artifact storage
- Cloud storage adapters (current workflow includes Google Drive via CLI backend)
- Designed for adapter expansion (`rclone`, S3-compatible, etc.)

## 4) Restore drill workflow
- Restore from latest backup artifacts
- URL rewrite for local environment
- Cache flush + quick validation checks

## 5) Self-contained project mode
- Keep runtime data under one project root with `OSB_HOME`
- Avoid filesystem sprawl
- Portable and easier to reason about

---

## Project Pillars

- **Backup you can restore** (not just export)
- **Provider flexibility** (avoid lock-in)
- **Operator-first UX** (clear logs, predictable outputs)
- **Open core trust** (inspectable, auditable workflow)

---

## Quick Start

```bash
cp config/env.example config/env.sh
bash scripts/preflight.sh --strict
bash scripts/01_pull_live_backup.sh
bash scripts/02_verify_backup.sh
bash scripts/03_upload_to_drive.sh
```

Optional restore drill:

```bash
bash scripts/04_restore_local.sh
```

Cloud-to-local restore test (directly from Google Drive file IDs):

```bash
bash scripts/05_restore_from_drive.sh
```

---

## Runtime scripts (canonical wrappers)

- `scripts/01_pull_live_backup.sh` (wrapper -> `adapters/wordpress/backup.sh`)
- `scripts/02_verify_backup.sh` (wrapper -> `adapters/wordpress/verify.sh`)
- `scripts/03_upload_to_drive.sh` (generic upload entrypoint; routes by `OSB_BACKEND`)
- `scripts/04_restore_local.sh` (wrapper -> `adapters/wordpress/restore.sh local`)
- `scripts/05_restore_from_drive.sh` (wrapper -> `adapters/wordpress/restore.sh drive`)
- `scripts/preflight.sh`
- `scripts/lint.sh`
- `scripts/run_all.sh`
- `scripts/collect_restore_metrics.sh`
- `scripts/demo_restore_run.sh`

Core implementation paths:
- `adapters/wordpress/`
- `backends/local/upload.sh`
- `backends/gog/upload.sh`
- `backends/rclone/upload.sh` (scaffold)

Config file:
- `config/env.sh`

Backend selection:
- `OSB_BACKEND=gog|local|rclone` (default: `gog`)
- `rclone` backend requires `RCLONE_REMOTE` in env (example in `config/env.example`)
- Drive-restore wp-config rewrite uses env vars (`LOCAL_DB_NAME`, `LOCAL_DB_USER`, `LOCAL_DB_PASSWORD`, `LOCAL_DB_HOST`)
- `scripts/preflight.sh --strict` now validates backend-specific requirements and key env dependencies before run

---

## Documentation

- Architecture: `docs/architecture.md`
- Self-contained mode: `docs/self_contained_mode.md`
- Infra quickstart: `docs/infra_quickstart.md`
- Handoff pack: `docs/HANDOFF_PACK.md`
- Handoff checklist: `docs/handoff_checklist.md`
- Execution plan (90 days): `strategy/90_day_execution_plan.md`
- Monetization roadmap: `strategy/12_month_monetization_roadmap.md`

---

## Documentation Policy (Hard Rule)

When scripts/behavior change, docs must be updated in the same change.

See:
- `docs/documentation_policy.md`

---

## Who this is for

- Agencies managing multiple WordPress sites
- Freelancers who want reliable disaster recovery
- Technical owners who want host-independent recovery confidence
- Teams that prefer open-source tooling with auditable behavior

---

## Open Source + Future Direction

OpenSiteBackup is open-source first.
The long-term model can support optional managed control-plane features, but the core recovery engine remains transparent and portable.

---

## License

MIT — see `LICENSE`.
