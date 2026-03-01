# Infrastructure Quickstart

## 1) Initialize local config
```bash
cp config/env.example config/env.sh
# edit config/env.sh with your values
```

## 2) Preflight
```bash
bash scripts/preflight.sh --strict
```

## 3) Run pipeline
```bash
bash scripts/01_pull_live_backup.sh
bash scripts/02_verify_backup.sh
# default upload backend is gog
bash scripts/03_upload_to_drive.sh
```

Optional backend override:
```bash
OSB_BACKEND=local bash scripts/03_upload_to_drive.sh
OSB_BACKEND=rclone bash scripts/03_upload_to_drive.sh
```

If using `rclone`, set `RCLONE_REMOTE` in `config/env.sh` first.

If using `scripts/05_restore_from_drive.sh`, set local DB rewrite vars in env:
- `LOCAL_DB_NAME`
- `LOCAL_DB_USER`
- `LOCAL_DB_PASSWORD`
- `LOCAL_DB_HOST` (optional, defaults to `localhost`)

## 4) Restore drill (optional)
```bash
bash scripts/04_restore_local.sh
```

## 5) Demo one-command restore run (optional)
```bash
bash scripts/demo_restore_run.sh
```

This executes preflight -> Drive restore -> post-checks -> metrics append.
