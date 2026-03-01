# TB Softwash — Comprehensive Backup & Restore Runbook

## 1) Purpose (What this is)

This runbook documents the full, reproducible process for creating, verifying, storing, and restoring a **disaster-recovery-grade backup** of the live WordPress site for **tbsoftwash.com**.

It covers:
- What is being backed up
- Why each step exists
- Where files are stored (local + Google Drive)
- Who should run each step
- When to run backups
- How to validate backup integrity
- How to restore when needed
- Troubleshooting and known pitfalls

This is intended to be the primary operations document for this backup pipeline.

---

## 2) Scope (What is included)

A full backup in this pipeline includes:

1. **Files archive** (`*_files.tar.gz`)
   - Entire WordPress site directory from live host
   - Includes themes, plugins, media/uploads, and site files

2. **Database dump** (`*_db.sql`)
   - WordPress MySQL/MariaDB data exported from live
   - Includes posts, pages, users, options, plugin settings, etc.

3. **Checksums + manifest**
   - Hashes for integrity validation
   - Run metadata and artifact sizing

A backup is considered complete only when all three are present and validated.

---

## 3) Why this exists (Business/technical rationale)

WordPress recovery requires both **files + database**.

- Files-only backup is insufficient (content/settings may be missing)
- DB-only backup is insufficient (uploads/themes/plugins may be missing)

This process provides:
- Repeatable recovery path
- Off-host copy (Google Drive) in case hosting account fails
- Integrity verification before trust
- Standardized procedure anyone on ops can follow

---

## 4) Ownership (Who does what)

### Primary operator
- Site owner/operator (Brian)

### Secondary operator
- Any trusted technical assistant with:
  - WSL access to backup scripts
  - Bluehost SSH access
  - Google Drive access via `gog`

### Responsibility split
- **Bluehost credentials/SSH enablement**: account owner
- **Script execution**: operator
- **Verification and retention review**: operator
- **Restore drills**: operator + owner approval

---

## 5) System architecture (Where things live)

## Local (WSL)
- Ops root: `/home/kingb/sites/tbsoftwash-ops`
- Scripts: `/home/kingb/sites/tbsoftwash-ops/scripts`
- Docs: `/home/kingb/sites/tbsoftwash-ops/docs`
- Local backup staging: `/home/kingb/backups/tbsoftwash-live/<timestamp>/`

## Live host (Bluehost)
- SSH host: `50.87.170.84`
- SSH user: `tbsoftwa`
- Site path: `/home/tbsoftwa/public_html`
- Temporary remote backup artifacts are created under `/home/tbsoftwa/` then deleted after pull

## Google Drive
Folder hierarchy:
- `Backups/WordPress/tbsoftwash.com/`
  - `db/`
  - `files/`
  - `manifests/`
  - `logs/`

---

## 6) Script inventory (What each script does)

## `01_pull_live_backup.sh`
Purpose:
- SSH into live host
- Create file archive and DB export
- Download artifacts to local timestamped folder
- Remove temporary remote files

Key outputs:
- `tbsoftwash_live_<timestamp>_files.tar.gz`
- `tbsoftwash_live_<timestamp>_db.sql`
- `tbsoftwash_live_<timestamp>_sha256.txt`

## `02_verify_backup.sh`
Purpose:
- Validate latest local backup artifacts
- Check archive readability
- Check SQL structure/data presence
- Generate local hash file + manifest

Key outputs:
- `manifest.txt`
- `local_sha256.txt`

## `03_upload_to_drive.sh`
Purpose:
- Upload verified artifacts to Google Drive
- Log start/end timestamps and per-file durations

Key outputs:
- Drive-hosted copies of DB, files archive, manifest, checksums

## `04_restore_local.sh`
Purpose:
- Restore latest backup into local WordPress path
- Import DB and run URL replacement for local testing

Safety:
- Requires manual `YES` confirmation before destructive restore

---

## 7) Prerequisites (Before running)

1. WSL Ubuntu environment available
2. `wp` CLI installed locally
3. `gog` CLI authenticated (`gog status --json` should show account)
4. SSH key present at `~/.ssh/id_ed25519`
5. Bluehost shell access enabled
6. `env.sh` correctly configured

---

## 8) Configuration file (`env.sh`) — required values

Location:
- `/home/kingb/sites/tbsoftwash-ops/scripts/env.sh`

Critical values:
- `LIVE_SSH_HOST`
- `LIVE_SSH_USER`
- `LIVE_SITE_PATH`
- `LIVE_SSH_KEY` (use WSL path, e.g. `$HOME/.ssh/id_ed25519`)
- `LOCAL_BACKUP_ROOT`
- Google Drive folder IDs
- `LOCAL_RESTORE_PATH`
- `LOCAL_URL`

Note:
- Do **not** use Windows key path (`/mnt/c/...`) for SSH private key in WSL unless permissions are hardened properly.

---

## 9) Standard operating procedure (When and how to run)

## Recommended cadence
- **Before any major update/change** (mandatory)
- **Weekly full backup** (recommended)
- **Monthly restore drill** (strongly recommended)

## Procedure

1) Pull live backup
```bash
cd /home/kingb/sites/tbsoftwash-ops/scripts
bash 01_pull_live_backup.sh
```

2) Verify integrity
```bash
bash 02_verify_backup.sh
```

3) Upload to Drive
```bash
bash 03_upload_to_drive.sh
```

4) (Optional) Restore drill
```bash
bash 04_restore_local.sh
```

Success criteria:
- No script errors
- Manifest + checksum files present
- Drive files uploaded with links/IDs returned

---

## 10) Validation checklist (How to know backup is trustworthy)

A valid backup must satisfy all:

- [ ] Files archive exists and has non-trivial size
- [ ] DB dump exists and has non-trivial size
- [ ] `tar -tzf` test passes
- [ ] SQL contains `CREATE TABLE`
- [ ] SQL contains `INSERT INTO`
- [ ] Local checksum file created
- [ ] Artifacts uploaded to Drive
- [ ] Manifest uploaded to Drive

---

## 11) Restore procedure (Disaster recovery)

## Local restore target
- Default: `/home/kingb/sites/tbsoftwash.com`

## Restore steps

1. Ensure latest verified backup exists locally.
2. Run restore script:
```bash
cd /home/kingb/sites/tbsoftwash-ops/scripts
bash 04_restore_local.sh
```
3. Type `YES` when prompted.
4. Verify local site health:
```bash
cd /home/kingb/sites/tbsoftwash.com
wp core is-installed
wp option get siteurl
wp plugin list
```

## Post-restore checks
- Admin login works
- Media renders
- Key pages load
- Permalinks behave as expected

---

## 12) Security and credential guidance

- Keep SSH private key in WSL home with `chmod 600`
- Do not commit secrets or SQL dumps to GitHub
- Use key-based SSH, avoid password fallback where possible
- Use unique passphrases/passwords (avoid reuse)
- Keep Drive access controlled to trusted users only

---

## 13) Retention policy

Recommended:
- Daily backups: keep 7
- Weekly backups: keep 8
- Monthly backups: keep 12

Purge policy:
- Remove oldest backups after confirming newer backups are verified
- Never delete last known-good backup until a newer one is validated

---

## 14) Known issues encountered and resolutions

1. **SSH key permissions too open (0777) on `/mnt/c/...`**
   - Fix: use WSL-native key path `~/.ssh/id_ed25519` with strict perms

2. **Remote `~/` path expansion bug in script**
   - Fix: use absolute remote paths `/home/<user>/...`

3. **Tar permission denied on transient file (`wpforms` temp .htaccess*)**
   - Fix: `tar --ignore-failed-read` and exclude problematic pattern

4. **Silent long-running behavior during remote archive**
   - Fix: progress markers `[1/5]...[5/5]` added to script

5. **Repeated keyring prompts for `gog`**
   - Expected behavior depending on keyring lock policy

---

## 15) Operational run examples

Example successful artifact sizes observed:
- DB dump: ~22M
- Files archive: ~1.8G

This confirms full live-content capture (uploads/media + DB), not just core WordPress files.

---

## 16) GitHub policy (important)

Store in GitHub:
- Scripts
- Documentation
- Theme/plugin custom code

Do NOT store in GitHub:
- Full site tar backups
- SQL dumps
- `wp-config.php` with credentials
- Any secrets or keys

Use Google Drive / object storage for backup artifacts.

---

## 17) Future enhancements

Potential improvements:
- Add cron scheduling for automated backups
- Add upload retries and resumable transfer strategy
- Add email/Discord notification on success/failure
- Add encrypted backup-at-rest option before cloud upload
- Add restore verification automation (smoke-test script)

---

## 18) Quick command reference

Run backup:
```bash
cd /home/kingb/sites/tbsoftwash-ops/scripts
bash 01_pull_live_backup.sh
bash 02_verify_backup.sh
bash 03_upload_to_drive.sh
```

Run restore drill:
```bash
bash 04_restore_local.sh
```

SSH key test:
```bash
ssh -o IdentitiesOnly=yes -o PreferredAuthentications=publickey tbsoftwa@50.87.170.84 'echo OK'
```

---

## 19) Document control

Document: `COMPREHENSIVE_BACKUP_RUNBOOK.md`
Location: `/home/kingb/sites/tbsoftwash-ops/docs/`
Status: Active
Owner: Site operator
Last updated: 2026-02-28

If the pipeline changes, update this file in the same session before closing work.
