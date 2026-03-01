# OpenSiteBackup — Operator Runbook

This runbook is the canonical day-to-day operations guide for OpenSiteBackup.

## 1) Preconditions

- `config/env.sh` exists and is populated
- Required tools installed (`ssh`, `scp`, `tar`, `wp`, plus backend tool)
- Selected backend env is configured:
  - `OSB_BACKEND=gog` -> `DRIVE_ACCOUNT`, `DRIVE_*_FOLDER_ID`
  - `OSB_BACKEND=rclone` -> `RCLONE_REMOTE`
  - `OSB_BACKEND=local` -> no extra dependency
- Optional retry tuning for cloud backends (`gog`, `rclone`):
  - `OSB_UPLOAD_RETRIES`
  - `OSB_UPLOAD_RETRY_DELAY_SEC`

## 2) Preflight

```bash
bash scripts/preflight.sh --strict
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

## 8) Artifacts to retain per successful run

- `*_files.tar.gz`
- `*_db.sql`
- `manifest.txt`
- `local_sha256.txt`
- relevant logs and restore summary lines
