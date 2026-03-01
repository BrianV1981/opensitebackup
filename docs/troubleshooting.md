# OpenSiteBackup — Troubleshooting

## Preflight failures

### `MISSING: <binary>`
Install the missing dependency and rerun:

```bash
bash scripts/preflight.sh --strict
```

### `MISSING ENV: ...`
Populate required variables in `config/env.sh` for the selected backend.

## Upload failures

Cloud backends (`gog`, `rclone`) support bounded retries via:
- `OSB_UPLOAD_RETRIES`
- `OSB_UPLOAD_RETRY_DELAY_SEC`

### Unknown backend
Ensure `OSB_BACKEND` is one of:

- `local`
- `gog`
- `rclone`

### Backend script not executable
Fix script permissions:

```bash
chmod +x backends/*/upload.sh
```

### rclone backend errors
Verify:

- `rclone` is installed
- `RCLONE_REMOTE` is set correctly
- remote path exists and credentials are valid

## Restore failures

### Missing artifacts
Run verify first and ensure latest backup folder has required files:

- `*_files.tar.gz`
- `*_db.sql`

### Drive restore env missing
For `scripts/05_restore_from_drive.sh`, ensure:

- `DRIVE_ACCOUNT`
- `DRIVE_DB_FILE_ID`
- `DRIVE_FILES_FILE_ID`
- `LOCAL_DB_NAME`
- `LOCAL_DB_USER`
- `LOCAL_DB_PASSWORD`
- optional `LOCAL_DB_HOST`

### `wp-config.php missing after extract`
Archive extraction failed or archive is incomplete/corrupted. Re-download/rebuild backup and rerun verify.

## WP-CLI warning noise during restore
Some plugin/theme/site config combinations may emit non-fatal warnings during restore/search-replace operations.

Current mitigations:

- core restore checks still enforce exit on hard failures
- many calls use safe WP mode (`--skip-plugins --skip-themes`)

If warnings become blockers, inspect `wp-config.php` constant definitions and plugin bootstrap behavior.

## Verify stage failures

### Tar integrity check fails
Archive may be incomplete/corrupted. Re-run backup pull and verify.

### SQL sanity check fails (`CREATE TABLE` / `INSERT INTO`)
DB export likely failed/partial. Re-run backup stage and inspect DB dump size/content.

## Lock/concurrency errors

### `LOCKED: <name> (another run is active)`
A prior run is still executing for the same run type.

Actions:
- wait for the active run to finish, or
- inspect lock metadata in `data/state/locks/*.meta`.

## Final confidence checks

Before merge/release, run:

```bash
bash scripts/pre_release_check.sh
RUN_RESTORE_DRILL=1 bash scripts/pre_release_check.sh
```
