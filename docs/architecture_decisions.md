# OpenSiteBackup — Architecture Decisions (v1)

This document captures explicit technical decisions to reduce ambiguity during handoff.

## AD-001 — Adapter/backend split

- **Decision:** Separate source adapters (`adapters/`) from storage backends (`backends/`).
- **Why:** Keeps source-capture logic independent from upload provider logic.
- **Impact:** New source/backends can be added without rewriting core flow.

## AD-002 — Preserve wrapper entrypoints

- **Decision:** Keep `scripts/01..05` as canonical wrappers even after refactor.
- **Why:** Backward compatibility for operators and existing docs/automation.
- **Impact:** Internal structure can evolve with stable user-facing commands.

## AD-003 — Restore-first verification contract

- **Decision:** A backup is not trusted without verify + restore path readiness.
- **Why:** Backup artifacts alone do not guarantee recovery success.
- **Impact:** Verify outputs (`manifest`, checksums) and restore drills are required evidence.

## AD-004 — Backend routing via env (`OSB_BACKEND`)

- **Decision:** Upload backend selected by environment variable, not script edits.
- **Why:** Safer operational switching across local/cloud backends.
- **Impact:** `scripts/03_upload_to_drive.sh` routes to backend implementations.

## AD-005 — Bounded retry policy for cloud uploads

- **Decision:** Add bounded retries for `gog` and `rclone` upload operations.
- **Why:** Handle transient network/provider failures without infinite loops.
- **Impact:** Controlled resilience using `OSB_UPLOAD_RETRIES` and `OSB_UPLOAD_RETRY_DELAY_SEC`.

## AD-006 — Env-driven restore credential rewrite

- **Decision:** Remove hardcoded DB creds from restore flow; use `LOCAL_DB_*` env vars.
- **Why:** Security and environment portability.
- **Impact:** Drive-restore path requires explicit local DB config in env.

## AD-007 — Release gate before promotion

- **Decision:** Require pre-release checks before dev->main promotion.
- **Why:** Reduce regression risk and improve reviewer confidence.
- **Impact:** `scripts/pre_release_check.sh` + `scripts/backend_matrix_smoke.sh` are standard gates.
