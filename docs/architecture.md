# OpenSiteBackup — Architecture (v1)

## 1) Objective

Define a clear technical architecture for OpenSiteBackup v1 so a new engineering team can implement, maintain, and extend the system with minimal ambiguity.

v1 focus:
- WordPress source adapter
- Full backup (files + DB)
- Verification + manifesting
- Provider-flexible upload backend
- Restore drill workflow

---

## 2) High-level system model

```text
[Source Host (WordPress)]
   |  (SSH)
   v
[Backup Runner (WSL/Linux)]
   |- backup stage   -> files.tar.gz + db.sql + remote sha
   |- verify stage   -> local sha + tar test + sql sanity + manifest
   |- upload stage   -> backend adapter (local/rclone/gog)
   '- restore stage  -> local extraction + db import + URL rewrite

Outputs:
- Backup artifacts
- Verification artifacts
- Logs
- Restore evidence
- Restore metrics (`data/state/restore_metrics.jsonl`)
```

---

## 3) Core architectural principles

1. **Restore-first design**
   - Backup is not "done" unless verify + restore path are available.

2. **Adapter isolation**
   - Source logic (WordPress) is isolated from storage backend logic.

3. **Deterministic artifacts**
   - Always produce manifest/checksums in consistent format.

4. **Observable execution**
   - Every phase emits explicit stage markers and timestamps.

5. **Fail loud, fail typed**
   - Distinct failure modes and non-zero exits.

---

## 4) Component breakdown

## 4.1 Orchestrator scripts

Current canonical operator entrypoints are wrapper scripts:
- `scripts/01_pull_live_backup.sh`
- `scripts/02_verify_backup.sh`
- `scripts/03_upload_to_drive.sh`
- `scripts/04_restore_local.sh`
- `scripts/05_restore_from_drive.sh`

Responsibilities:
- Load env/config
- Validate preflight conditions
- Call adapter/backend functions
- Emit stage logs
- Return stable exit code semantics

Upload routing:
- `scripts/03_upload_to_drive.sh` selects backend from `OSB_BACKEND`
- Supported values: `gog`, `local`, `rclone`

## 4.2 Source adapter: WordPress

Location:
- `adapters/wordpress/`

Functions:
- `backup.sh`
  - remote file archive via SSH/tar
  - DB dump via `wp db export` (or fallback strategy)
- `verify.sh`
  - tar readability
  - SQL structural checks
  - checksum generation
  - manifest generation
- `restore.sh`
  - extract archive
  - import DB
  - search-replace URLs
  - run post-restore checks

## 4.3 Storage backends

Location:
- `backends/<backend>/upload.sh`

v1 backends:
- `local` (required)
- `rclone` (recommended cloud default)
- `gog` (optional compatibility backend)

Contract:
- input: artifact paths + metadata + destination config
- output: upload IDs/links + duration + exit status

## 4.4 Configuration

- Single env file per deployment context
- Example templates in `examples/`
- Mandatory values validated before run

---

## 5) Runtime sequence (backup to upload)

## Step A — Preflight
- Validate tools present (`ssh`, `scp`, `tar`, `wp`, backend tool)
- Validate config values and backend selection (`OSB_BACKEND`)
- Validate backend-specific env requirements (`DRIVE_*` or `RCLONE_REMOTE`)
- Validate SSH key path and permissions
- Validate source host reachability and WP path

## Step B — Backup (source adapter)
- SSH to source
- Archive site files
- Export DB
- Generate source checksums
- Pull artifacts local
- Delete remote temp artifacts

## Step C — Verify
- `tar -tzf` archive test
- SQL sanity checks (`CREATE TABLE`, `INSERT INTO`)
- Compute local checksums
- Generate `manifest.txt`

## Step D — Upload
- Select backend
- Upload files + DB + manifest + checksums
- Apply bounded retry policy for transient backend failures (`OSB_UPLOAD_RETRIES`, `OSB_UPLOAD_RETRY_DELAY_SEC`)
- Emit IDs/links and duration

## Step E — Optional restore drill
- Stage extract/import into temporary site path
- Create DB rollback snapshot before import
- Validate staged restore (`wp core is-installed`, siteurl/blogname/pages)
- Atomic filesystem swap into active path on success
- URL search-replace
- post-restore checks

---

## 6) Data model (artifacts)

Naming convention:
- `<site-slug>_live_<timestamp>_files.tar.gz`
- `<site-slug>_live_<timestamp>_db.sql`
- `<site-slug>_live_<timestamp>_sha256.txt`
- `manifest.txt`
- `local_sha256.txt`

Local folder structure:
```text
<LOCAL_BACKUP_ROOT>/<timestamp>/
  *_files.tar.gz
  *_db.sql
  *_sha256.txt
  manifest.txt
  local_sha256.txt
```

---

## 7) Logging and observability

Required log conventions:
- ISO timestamps for stage markers
- `[x/y]` stage numbering
- explicit START/DONE markers for uploads
- duration seconds for long operations

Example:
- `[2026-02-28T18:35:20-05:00] START upload: files-archive ...`
- `[2026-02-28T18:36:29-05:00] DONE  upload: files-archive | duration=69s`

---

## 8) Error model and exit codes (proposal)

- `10` config error
- `20` preflight dependency error
- `30` SSH/auth error
- `40` source backup error
- `50` verification error
- `60` upload backend error
- `70` restore error

If not yet implemented, standardize in first engineering sprint.

---

## 9) Security model

- SSH key auth preferred over password auth
- WSL-native key files with strict permissions
- No secrets committed to repository
- SQL dumps/backups excluded from git
- Cloud credentials managed by backend-native secure methods

---

## 10) Extensibility plan

## New source adapter (e.g., Ghost/static)
Must implement:
- `backup`
- `verify` (or verify hooks)
- `restore` (where applicable)

## New backend adapter (e.g., S3)
Must implement:
- `upload` contract with consistent output and exit semantics

This enables horizontal extension without refactoring core flow.

---

## 11) Test strategy

## Unit-level
- shell lint (`shellcheck`)
- config parser checks
- path and variable validation tests

## Integration-level
- backup from staging WP host
- verify artifacts
- upload via at least 2 backends
- full local restore drill

## Acceptance-level
- New engineer executes docs-only path successfully
- One external user run succeeds and reports restore success

---

## 12) Operational SLO targets (v1)

- Backup success rate: > 95%
- Verify success rate: > 99% for completed backups
- Restore drill success rate: > 90%
- Mean time to usable restore: tracked and reduced each release

---

## 13) Open questions (for team kickoff)

1. Primary backend default: `local` vs `rclone` for first-run UX?
2. Minimum supported WP host matrix?
3. Standardized JSON log output needed in v1?
4. Encrypt artifacts before cloud upload in v1 or v1.1?
5. Should restore be mandatory in CI test gates for release tags?

---

## 14) Decision record links

- Product plan: `strategy/90_day_execution_plan.md`
- Monetization: `strategy/12_month_monetization_roadmap.md`
- Positioning: `docs/positioning_and_gtm.md`
