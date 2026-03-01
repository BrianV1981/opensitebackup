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
```

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

## 6) Pre-release validation gate

Non-destructive by default:

```bash
bash scripts/pre_release_check.sh
```

Include destructive local restore drill when intended:

```bash
RUN_RESTORE_DRILL=1 bash scripts/pre_release_check.sh
```

## 7) Safety rules

- Never run destructive restore against live production paths
- Never commit secrets or runtime artifacts
- Keep `main` stable; perform active integration on dev branch
- Locking is enforced for backup/upload/restore; stale lock handling uses `OSB_LOCK_TIMEOUT_SEC` + `OSB_LOCK_CLEAR_STALE`
- Logging includes a run identifier (`OSB_RUN_ID`) and supports JSON mode (`OSB_LOG_JSON=1`) for machine parsing

## 8) Retention and cleanup

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

## 9) Artifacts to retain per successful run

- `*_files.tar.gz`
- `*_db.sql`
- `manifest.txt`
- `local_sha256.txt`
- relevant logs and restore summary lines
