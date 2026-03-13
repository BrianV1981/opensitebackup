# OpenSiteBackup — Operator Runbook

This runbook is the canonical day-to-day operations guide for OpenSiteBackup.

## 1) Preconditions

- `config/env.sh` exists and is populated
- For multi-site mode, profiles can be stored in `config/sites/<slug>.env` and activated via `scripts/use_site_profile.sh <slug>`
- Required tools installed (`ssh`, `scp`, `tar`, `wp`, plus backend tool)
- Selected backend env is configured:
  - `OSB_BACKEND=local` -> no extra dependency (recommended first-run)
  - `OSB_BACKEND=rclone` -> `RCLONE_REMOTE`
  - `OSB_BACKEND=gog` -> `DRIVE_ACCOUNT`, `DRIVE_*_FOLDER_ID` (optional support only)
- Optional retry tuning for cloud backends (`gog`, `rclone`):
  - `OSB_UPLOAD_RETRIES`
  - `OSB_UPLOAD_RETRY_DELAY_SEC`

## 2) Session prep + preflight

```bash
bash scripts/session_prep.sh
bash scripts/preflight.sh --strict
bash scripts/validate_env.sh backup
bash scripts/validate_env.sh upload
```

Fast operator path:

```bash
bash scripts/quick_run.sh
# profile-aware variant
bash scripts/quick_run.sh --profile <site-slug>
```

Adoption-first one-click style wrappers:

```bash
bash scripts/first_run.sh
bash scripts/backup_now.sh
bash scripts/test_restore_local.sh
bash scripts/recovery_status.sh
```

If quick run fails at backup stage, it now prints a direct SSH-prep hint.

If your SSH key is passphrase-protected and session prep runs in non-interactive mode, set:

```bash
OSB_SESSION_PREP_SKIP_SSH_TEST=1 bash scripts/session_prep.sh
```

## 3) Standard backup pipeline

```bash
bash scripts/01_pull_live_backup.sh
bash scripts/02_verify_backup.sh
bash scripts/03_upload_to_drive.sh
```

Or one-command equivalent:

```bash
bash scripts/run_all.sh
```

## 4) Restore drills

Local restore from latest local artifacts:

```bash
bash scripts/04_restore_local.sh
```

Direct cloud-to-local restore (Drive file IDs):

- uses staged/atomic restore flow and rollback snapshot handling

```bash
bash scripts/05_restore_from_drive.sh
```

Expected success marker:

```text
RESTORE_SUMMARY siteurl=... blogname=... pages=...
```

## 5) Demo run and metrics

Demo flow:

```bash
bash scripts/demo_restore_run.sh
```

Metrics collector output file:

- `data/state/restore_metrics.jsonl`

## 6) Status snapshot

Quick status output:

```bash
bash scripts/status_snapshot.sh
```

Optional docs integrity check:

```bash
bash scripts/check_docs_links.sh
```

Non-destructive diagnostics pack:

```bash
bash scripts/doctor.sh
```

By default, doctor skips optional cloud backend matrix uploads.
To include optional backends:

```bash
OSB_MATRIX_INCLUDE_OPTIONAL_BACKENDS=1 bash scripts/doctor.sh
```

## 7) Pre-release validation gate

Non-destructive by default:

```bash
bash scripts/pre_release_check.sh
bash scripts/release_prepare.sh
bash scripts/generate_launch_packet.sh
bash scripts/prepare_pr_evidence.sh
```

Include destructive local restore drill when intended:

```bash
RUN_RESTORE_DRILL=1 bash scripts/pre_release_check.sh
```

## 8) Safety rules

- Never run destructive restore against live production paths
- Never commit secrets or runtime artifacts
- Keep `main` stable; perform active integration on dev branch
- Locking is enforced for backup/upload/restore; stale lock handling uses `OSB_LOCK_TIMEOUT_SEC` + `OSB_LOCK_CLEAR_STALE`
- Backup adapter includes best-effort remote temp cleanup on failures to reduce orphaned sensitive artifacts on live host
- Logging includes a run identifier (`OSB_RUN_ID`) and supports JSON mode (`OSB_LOG_JSON=1`) for machine parsing

## 9) Retention and cleanup

Review retention settings in `config/env.sh`:
- `OSB_RETENTION_DAILY`
- `OSB_RETENTION_WEEKLY`
- `OSB_RETENTION_MONTHLY`
- `OSB_RETENTION_PRUNE_EMPTY`

Dry-run cleanup:

```bash
bash scripts/cleanup_backups.sh
```

Apply cleanup:

```bash
bash scripts/cleanup_backups.sh --apply
```

## 10) Artifacts to retain per successful run

- `*_files.tar.gz`
- `*_db.sql`
- `manifest.txt`
- `local_sha256.txt`
- relevant logs and restore summary lines
