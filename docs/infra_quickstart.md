# Infrastructure Quickstart

## 1) Initialize local config
```bash
# option A: guided wizard
bash scripts/setup_wizard.sh

# option B: manual
cp config/env.example config/env.sh
# edit config/env.sh with your values
```

For Google Drive backend, optional structure bootstrap:
```bash
bash scripts/init_drive_structure.sh
```

Note: when using `gog`, set `DRIVE_ACCOUNT` first (wizard now prompts for it).

Optional docs check:
```bash
bash scripts/check_docs_links.sh
```

Multi-site profile switching:
```bash
bash scripts/use_site_profile.sh <site-slug>
# or run profile-aware fast path directly
bash scripts/quick_run.sh --profile <site-slug>
```

## 2) Preflight
```bash
bash scripts/preflight.sh --strict
```

Strict preflight validates:
- required binaries (`ssh`, `scp`, `tar`, `wp` + backend tool)
- selected backend requirements (`OSB_BACKEND`)
- key env dependencies (e.g., `RCLONE_REMOTE`, Drive folder IDs, optional drive-restore env set)
- command-context env requirements (via `scripts/validate_env.sh`)

## 3) Run pipeline
```bash
bash scripts/01_pull_live_backup.sh
bash scripts/02_verify_backup.sh
# default upload backend is gog
bash scripts/03_upload_to_drive.sh
```

One-command variant:
```bash
bash scripts/run_all.sh
```

Optional backend override:
```bash
OSB_BACKEND=local bash scripts/03_upload_to_drive.sh
OSB_BACKEND=rclone bash scripts/03_upload_to_drive.sh
```

If using `rclone`, set `RCLONE_REMOTE` in `config/env.sh` first.

Optional upload retry knobs (gog/rclone):
- `OSB_UPLOAD_RETRIES`
- `OSB_UPLOAD_RETRY_DELAY_SEC`

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

## 6) Pre-release gate (recommended)
```bash
bash scripts/pre_release_check.sh
bash scripts/backend_matrix_smoke.sh
bash scripts/release_prepare.sh
# include destructive restore drill only when explicitly intended:
RUN_RESTORE_DRILL=1 bash scripts/pre_release_check.sh
```
