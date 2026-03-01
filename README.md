# OpenSiteBackup (working name)

Open-source, end-to-end website backup and disaster recovery pipeline.

## Vision
A trustworthy backup engine (OSS) + optional hosted control plane (SaaS) for agencies, operators, and site owners.

## Pillars
- **Backup you can restore** (not just export)
- **Provider-flexible** storage (local, Drive, S3, etc.)
- **Operator-first** UX (clear logs, checksums, drills)
- **Open core trust** + managed convenience

## Initial Scope
- WordPress adapter first
- Local + cloud backup targets
- Verify + manifest + checksum workflow
- Restore drills

See:
- `strategy/12_month_monetization_roadmap.md`
- `brand/project_naming_shortlist.md`
- `docs/positioning_and_gtm.md`


## Self-contained mode
OpenSiteBackup can run in a single-root layout using `OSB_HOME`.
See:
- `docs/self_contained_mode.md`
- `config/env.example`
- `docs/glossary.md`

## Imported reference docs
Legacy ops docs were copied from `tbsoftwash-ops` to:
- `docs/reference/tbsoftwash-ops/`


## Runtime scripts (canonical)
Use scripts in this repository:
- `scripts/01_pull_live_backup.sh`
- `scripts/02_verify_backup.sh`
- `scripts/03_upload_to_drive.sh`
- `scripts/04_restore_local.sh`

Config file:
- `config/env.sh`

Legacy/site-specific scripts were moved to:
- `legacy/tbsoftwash-ops/`


## Quick start
```bash
cp config/env.example config/env.sh
bash scripts/preflight.sh --strict
bash scripts/01_pull_live_backup.sh
bash scripts/02_verify_backup.sh
bash scripts/03_upload_to_drive.sh
```

## Documentation hard rule
Documentation must be updated whenever behavior/scripts change.
See `docs/documentation_policy.md`.
