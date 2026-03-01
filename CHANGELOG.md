# Changelog

## [Unreleased]
### Added
- Adapter/backend structure:
  - `adapters/wordpress/{backup,verify,restore}.sh`
  - `backends/{gog,local,rclone}/upload.sh`
- Upload backend selector via `OSB_BACKEND` in `scripts/03_upload_to_drive.sh`.
- Restore post-check summary output line:
  - `RESTORE_SUMMARY siteurl=... blogname=... pages=...`
- `rclone` backend implementation with upload logging and `RCLONE_REMOTE` validation.

### Security/Hardening
- Removed hardcoded local DB credentials from restore flow.
- Drive-restore wp-config rewrite now uses env-provided DB values (`LOCAL_DB_*`).
- Tightened backend launcher validation to require existing + executable backend scripts.

### Cleanup
- Removed temporary internal implementation directive after integrating execution items.

### Added
- `scripts/collect_restore_metrics.sh` to append restore outcomes to `data/state/restore_metrics.jsonl`.
- `scripts/demo_restore_run.sh` for a repeatable demo flow (preflight -> drive restore -> checks -> metrics).
- Roadmap strategy doc alignment to current wrapper entrypoints (`scripts/01..05`) and backend-routed upload flow.
- Strict preflight checks for backend-specific requirements and env dependencies.

### Reliability
- Demo restore flow now records structured failure metrics on non-success exits.
- Metrics collector now tolerates missing/non-numeric values safely.
- Restore/demo/metrics WP-CLI calls now use `--skip-plugins --skip-themes` to reduce warning noise during restore drills.

### Docs
- Synced root + `docs/` handoff/runbook/contributing docs with current architecture and execution flow.
- Removed stale `rclone` scaffold wording and aligned operational checklists with backend/env requirements.

### Added
- `scripts/pre_release_check.sh` as a release gate (syntax + strict preflight + verify + local upload smoke, optional destructive restore drill).

### Changed
- `scripts/run_all.sh` now includes strict preflight and explicit stage logging (`pull -> verify -> upload`).

### Changed
- `scripts/01..05` are now backward-compatible wrappers that call adapter/backend implementations.
- Architecture and quickstart docs updated to reflect wrapper + backend-routing model.

## [0.1.0-alpha] - 2026-02-28
### Added
- Initial OpenSiteBackup repo scaffolding
- WordPress backup/verify/upload/restore scripts
- Architecture, roadmap, GTM, and handoff docs
- Self-contained mode docs and config template

### Changed
- `scripts/01_pull_live_backup.sh` now auto-removes an empty timestamp run directory if a run fails early (prevents buildup of empty backup folders).

### Added
- `scripts/05_restore_from_drive.sh` for direct Google Drive file-ID restore drills.
- Recovery checkpoint document after validated cloud->local restore (`docs/recovery_checkpoint.md`).
