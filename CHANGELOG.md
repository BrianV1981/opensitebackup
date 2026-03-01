# Changelog

## [0.1.0-alpha] - 2026-02-28
### Added
- Initial OpenSiteBackup repo scaffolding
- WordPress backup/verify/upload/restore scripts
- Architecture, roadmap, GTM, and handoff docs
- Self-contained mode docs and config template

### Changed
- `scripts/01_pull_live_backup.sh` now auto-removes an empty timestamp run directory if a run fails early (prevents buildup of empty backup folders).
