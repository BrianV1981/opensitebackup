# Operations Runbook: Full Backup & Restore (Bluehost -> WSL -> Google Drive)

## Purpose
Create full, restorable backups of the live WordPress site:
- Files archive (`*_files.tar.gz`)
- Database SQL dump (`*_db.sql`)
- Manifest/checksums

## Preconditions
- SSH access to Bluehost host
- WP-CLI available on live host (or adapt to mysqldump)
- `gog` authenticated locally

## Procedure
1. Configure `scripts/env.sh`
2. `bash scripts/01_pull_live_backup.sh`
3. `bash scripts/02_verify_backup.sh`
4. `bash scripts/03_upload_to_drive.sh`
5. Optional DR test: `bash scripts/04_restore_local.sh`

## Retention Policy (recommended)
- Keep daily backups: 7 days
- Keep weekly backups: 8 weeks
- Keep monthly backups: 12 months

## What NOT to store in GitHub
- SQL dumps
- Full uploads/media archives
- `wp-config.php` with secrets

Use GitHub for code only:
- themes
- plugins
- mu-plugins
- deployment scripts/runbooks
