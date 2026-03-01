# Changelog

## [Unreleased]
### Added
- Adapter/backend structure:
  - `adapters/wordpress/{backup,verify,restore}.sh`
  - `backends/{gog,local,rclone}/upload.sh`
- Upload backend selector via `OSB_BACKEND` in `scripts/03_upload_to_drive.sh`.
- Restore post-check summary output line:
  - `RESTORE_SUMMARY siteurl=... blogname=... pages=...`

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
