# OpenSiteBackup — Red Team Fix List (Immediate)

## Purpose
Critical hardening and multi-user normalization tasks required to make OpenSiteBackup safe, portable, and non-site-specific.

This list is intentionally strict. Priority order is by risk reduction.

---

## Severity Legend
- **P0** = must fix before broad public alpha
- **P1** = fix immediately after P0
- **P2** = important but can follow

---

## P0 — Must Fix Now

## P0.1 Remove all project-specific hardcoding from core runtime

### Risk
Hardcoded names/domains/paths create hidden coupling and make the tool fail for non-tbsoftwash users.

### Required changes
- Replace any hardcoded domain/site strings in adapters and wrappers.
- Replace hardcoded restore defaults with env-driven values.

### Acceptance criteria
- `grep -R "tbsoftwash\|localhost:8081\|ChangeThisNow_123" scripts adapters backends` returns no runtime hardcoding.
- Fresh user can configure and run without editing source code.

---

## P0.2 Staged/atomic restore flow (no destructive direct overwrite)

### Risk
Current restore can leave site in partial broken state if extraction/import fails mid-run.

### Required changes
- Restore into temp site path + temp DB.
- Validate (`wp core is-installed`, page count > 0, blogname/siteurl present).
- Swap active site pointer/path only if validation passes.
- Preserve previous working state as rollback target.

### Acceptance criteria
- Simulated import failure leaves active site unchanged.
- Successful run swaps atomically and preserves rollback snapshot.

---

## P0.3 Strict command-specific env validation

### Risk
Misconfigured envs currently fail late and sometimes after destructive steps.

### Required changes
- Add per-command required var matrix.
- Validate all required vars *before* any destructive operation.

### Acceptance criteria
- `restore` refuses to begin if DB vars or target vars missing.
- `upload` refuses to begin if backend-specific vars missing.
- clear error output: `MISSING ENV: <VAR>`.

---

## P0.4 Locking/concurrency protection

### Risk
Two backup/restore runs can collide and corrupt artifacts/state.

### Required changes
- Add lockfile + PID + timestamp for each run type.
- Add stale lock recovery with confirmation.

### Acceptance criteria
- second run exits with lock warning while first is active.
- stale lock can be cleared safely.

---

## P0.5 Retention & cleanup policy implementation

### Risk
Storage bloat, operational drift, and confusion from stale/failed artifacts.

### Required changes
- Add `scripts/cleanup_backups.sh` with policy vars.
- Purge empty failed run dirs and old artifacts by policy.

### Acceptance criteria
- policy-based dry run and apply mode.
- keeps N daily / N weekly / N monthly snapshots.

---

## P1 — Immediate Next

## P1.1 Backend neutrality by default (remove gog as implicit default)

### Risk
OSS adoption friction due to ecosystem-specific dependency.

### Required changes
- Default `OSB_BACKEND=local` or `rclone`.
- Keep gog optional.

### Acceptance criteria
- fresh install works without gog.
- cloud path works with rclone backend.

---

## P1.2 Post-upload verification hooks

### Risk
Upload success logs may not equal verified remote integrity.

### Required changes
- Add optional per-backend verify step (checksum/size check where possible).
- Report `UPLOAD_VERIFY_SUMMARY`.

### Acceptance criteria
- upload pipeline can fail on remote verification mismatch.

---

## P1.3 Structured logs + run IDs

### Risk
Troubleshooting and metrics aggregation become unreliable at scale.

### Required changes
- Add run UUID to each execution.
- Optional JSON log line mode (`OSB_LOG_JSON=1`).

### Acceptance criteria
- every stage log includes run id.
- machine-readable logs parse cleanly.

---

## P1.4 Restore safety gates in release checks

### Risk
Releases pass without testing actual restore path.

### Required changes
- Make restore drill required for release candidate gates.

### Acceptance criteria
- release gate fails if restore drill not executed for RC.

---

## P2 — Important Follow-ups

## P2.1 Guided setup wizard (TUI)
- `scripts/setup_wizard.sh` to generate `config/env.sh` with field guidance.

## P2.2 Multi-site config model
- site profiles (`config/sites/<slug>.env`) + profile selector.

## P2.3 Integration test harness
- fixture-based tests for backup/verify/restore command flows.

## P2.4 Security hardening extras
- optional artifact encryption before upload
- secrets lint in CI

---

# Immediate Implementation: Dynamic Variables Standardization

## Goal
Make all user-specific/site-specific behavior configurable via env vars (no source edits per user).

## Canonical variable groups

## A) Global runtime
- `OSB_HOME`
- `OSB_CONFIG`
- `OSB_BACKUPS`
- `OSB_LOGS`
- `OSB_TMP`
- `OSB_STATE`

## B) Source host connection
- `SOURCE_KIND` (initially `wordpress`)
- `LIVE_SSH_HOST`
- `LIVE_SSH_USER`
- `LIVE_SITE_PATH`
- `LIVE_SSH_KEY`
- `LIVE_SSH_PORT` (default 22)

## C) Restore target
- `LOCAL_RESTORE_PATH`
- `LOCAL_URL`
- `LOCAL_DB_NAME`
- `LOCAL_DB_USER`
- `LOCAL_DB_PASSWORD`
- `LOCAL_DB_HOST`
- `LOCAL_DB_PORT`

## D) Domain rewrite mapping
- `OSB_REWRITE_FROM_1`
- `OSB_REWRITE_TO_1`
- `OSB_REWRITE_FROM_2`
- `OSB_REWRITE_TO_2`
(Allow multiple pairs; loop dynamically)

## E) Backend selection + backend config
- `OSB_BACKEND` (`local|rclone|gog`)

### local backend
- `LOCAL_UPLOAD_ROOT`

### rclone backend
- `RCLONE_REMOTE`
- `RCLONE_FLAGS`

### gog backend (optional)
- `DRIVE_ACCOUNT`
- `DRIVE_DB_FOLDER_ID`
- `DRIVE_FILES_FOLDER_ID`
- `DRIVE_MANIFESTS_FOLDER_ID`
- `DRIVE_DB_FILE_ID` (for direct restore)
- `DRIVE_FILES_FILE_ID` (for direct restore)

## F) Reliability controls
- `OSB_UPLOAD_RETRIES`
- `OSB_UPLOAD_RETRY_DELAY_SEC`
- `OSB_LOCK_TIMEOUT_SEC`
- `OSB_RESTORE_CONFIRM_REQUIRED` (`1|0`)

## G) Retention policy
- `OSB_RETENTION_DAILY`
- `OSB_RETENTION_WEEKLY`
- `OSB_RETENTION_MONTHLY`
- `OSB_RETENTION_PRUNE_EMPTY` (`1|0`)

---

## Implementation steps (immediate)

1. Add all variables to `config/env.example` with comments and safe defaults.
2. Add `scripts/validate_env.sh`:
   - accepts command context (`backup|verify|upload|restore|demo|release`).
   - validates required variable matrix per context.
3. Update all entry scripts to call `validate_env.sh` before action.
4. Replace remaining literals in adapter/backend scripts with env variables.
5. Add CI check to fail if banned hardcoded tokens appear in runtime paths.

---

## Banned hardcoded tokens check (add to CI)

Fail build if these appear in runtime scripts:
- `tbsoftwash`
- `localhost:8081`
- project-specific DB passwords

Command example:
```bash
grep -RInE 'tbsoftwash|localhost:8081|ChangeThisNow_123' scripts adapters backends && exit 1 || true
```

---

## Definition of completion for this directive

- [ ] No site/user-specific literals in runtime scripts.
- [ ] All dynamic behavior configured via env vars.
- [ ] `validate_env.sh` enforced by all entrypoints.
- [ ] Restore is staged+atomic with rollback path.
- [ ] Retention cleanup script implemented and tested.
- [ ] Pre-release gate includes restore requirement for RC builds.
