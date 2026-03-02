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
- Performed coherence sweep across root/docs to align naming, quality gates, and release checklist with red-team + TUI implementation.
- Added stale-lock recovery controls (`OSB_LOCK_TIMEOUT_SEC`, `OSB_LOCK_CLEAR_STALE`) to lock wrapper.
- Added RC-mode restore enforcement (`OSB_RC_MODE`) in pre-release checks.
- Added `UPLOAD_VERIFY_SUMMARY` markers for cloud backends (`gog`, `rclone`).
- Added run-id logging helper (`scripts/log.sh`) and optional JSON logging mode support in core entrypoints.
- Added onboarding scripts `scripts/session_prep.sh`, `scripts/quick_run.sh`, and Drive bootstrap script `scripts/init_drive_structure.sh`.
- Added `scripts/use_site_profile.sh` and profile save/switch flow (`config/sites/<slug>.env`) for multi-site operations.
- Added `scripts/ssh_troubleshoot.sh` for guided SSH diagnostics and fix hints.
- Session prep now supports non-interactive environments via `OSB_SESSION_PREP_SKIP_SSH_TEST=1` fallback path.
- Archived red-team directive to `docs/archive/RED_TEAM_FIX_LIST.closed.md` and added `docs/DOCS_INDEX.md` canonical map.
- Clarified docs and runbook language that `gog` is optional support, not a prerequisite backend.
- Added CI env-validation matrix script (`scripts/validate_env_matrix_ci.sh`) and workflow gate.
- Added profile-aware onboarding fast paths (`scripts/session_prep.sh --profile`, `scripts/quick_run.sh --profile`).
- Added `docs/FINAL_EVIDENCE_SUMMARY.md` to consolidate red-team closure + gate evidence for reviewer handoff.
- Deep docs coherence sweep: aligned README/runtime list with actual scripts, clarified legacy reference-doc role, and synced runbook/quickstart operator checks.
- Added `scripts/doctor.sh` non-destructive diagnostics bundle and linked it in runbook/release checklist.
- Backend matrix now hard-fails only on required `local` backend; optional cloud backend failures are surfaced as warnings.
- Added `OSB_MATRIX_INCLUDE_OPTIONAL_BACKENDS` control (default `0` in env example) so doctor/matrix can avoid cloud uploads unless explicitly enabled.
- Improved Drive init output contract to emit canonical `export DRIVE_*` lines; setup wizard now appends these directly.
- Added `scripts/prepare_pr_evidence.sh` to generate reviewer-ready evidence bundle from release artifacts.
- Added professional Node.js marketing site under `site/` with zero-dependency static server and polished landing page content.
- Added basic SEO assets for marketing site (`robots.txt`, `sitemap.xml`, OpenGraph/canonical metadata).
- Verify flow now handles empty/missing backup state gracefully with clear first-run guidance (instead of raw `ls` failure).
- Setup wizard now prompts for `DRIVE_ACCOUNT` when `gog` backend is selected and can auto-wire Drive init IDs.
- Quick run now emits a clear stage-specific SSH guidance hint when backup auth fails.
- Added `scripts/status_snapshot.sh` for fast operator visibility into branch/backend/latest backup/evidence status.

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
