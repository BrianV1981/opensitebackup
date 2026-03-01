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
- Added first-class `docs/runbook.md` and `docs/troubleshooting.md` and linked them in README + handoff docs.
- Added `docs/release_checklist.md` to standardize dev->main promotion and tagging gates.
- Expanded documentation policy minimum review set to include runbook/troubleshooting/release docs.

### Changed
- `scripts/lint.sh` now runs shellcheck across `scripts/`, `adapters/`, and `backends/` for parity with CI.

### Added
- `scripts/pre_release_check.sh` as a release gate (syntax + strict preflight + verify + local upload smoke, optional destructive restore drill).

### Changed
- `scripts/run_all.sh` now includes strict preflight and explicit stage logging (`pull -> verify -> upload`).
- CI now lint-checks shell scripts across `scripts/`, `adapters/`, and `backends/` and runs `bash -n` syntax checks.
- PR template now requires merge-readiness evidence snippets for strict preflight and pre-release gate runs.
- `gog` and `rclone` upload backends now support bounded retry behavior for transient failures (`OSB_UPLOAD_RETRIES`, `OSB_UPLOAD_RETRY_DELAY_SEC`).

### Added
- `scripts/backend_matrix_smoke.sh` for Phase 3 backend validation (local/gog/rclone upload smoke with skip-aware logging).
- `docs/backend_validation_matrix.md` to standardize backend reliability checks and evidence capture.
- `docs/architecture_decisions.md` to capture core v1 technical decisions.
- `docs/troubleshooting_matrix.md` for fast stage->symptom->action operations support.

### Phase status
- Phase 4 (docs/handoff quality) closed with runbook + troubleshooting + architecture decisions + troubleshooting matrix + release checklist coverage.
- Phase 5 launch-readiness execution started with release evidence automation and launch-tracking docs.

### Added
- `scripts/release_prepare.sh` to generate `data/state/release_readiness_report.md` with validation evidence.
- `scripts/generate_launch_packet.sh` to generate `data/state/launch_go_no_go_packet.md` for final release decisions.
- `docs/launch_readiness.md` for Phase 5 gating and external validation tracking.
- `docs/go_no_go.md` for formal release decision workflow.
- `docs/release_notes_template.md` for structured release communication.
- `scripts/validate_env.sh` for strict command-context env validation.
- `scripts/setup_wizard.sh` guided TUI-style config bootstrap.
- `scripts/cleanup_backups.sh` for retention policy cleanup (dry-run/apply).
- `scripts/with_lock.sh` for run-type lock protection.

### Changed
- Runtime scripts now reject missing required env vars before action (`MISSING ENV: <VAR>`).
- Upload default backend switched to `local` for backend-neutral fresh installs.
- Runtime hardcoded site/domain tokens removed in scripts/adapters/backends.
- CI now fails on banned hardcoded runtime tokens in `scripts/`, `adapters/`, and `backends/`.

### Fixed
- Corrected markdown code-fence emission in `scripts/generate_launch_packet.sh` to avoid shell backtick command-substitution errors.
- Restore workflow is now staged+atomic with validation gate and DB rollback snapshot before swap.
- Added command-context env validator (`scripts/validate_env.sh`) enforcement across runtime entrypoints.
- Added lock-based concurrency protection (`scripts/with_lock.sh`) for backup/upload/restore flows.
- Added retention cleanup script (`scripts/cleanup_backups.sh`) with dry-run/apply modes.

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
