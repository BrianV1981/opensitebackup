# Storage Migration Plan (Canonical Cloud Path)

## Purpose
Define one canonical cloud destination structure and document the completed cutover from legacy Drive paths.

---

## Canonical target
All OpenSiteBackup cloud artifacts should land under:

`opensitebackup/wordpress/<site-slug>/`

For current site:

`opensitebackup/wordpress/tbsoftwash.com/`
- `db/`
- `files/`
- `manifests/`
- `logs/`

---

## Legacy vs canonical (Google Drive)

## Legacy path (deprecated)
`Backups/WordPress/tbsoftwash.com/`

## Canonical path (active)
`opensitebackup/wordpress/tbsoftwash.com/`

Cutover status: **completed** (2026-03-13)

---

## Active folder IDs (Google Drive)
These IDs should be considered source-of-truth for current runtime config.

- `DRIVE_SITE_FOLDER_ID=1DfiZcqJLQwe9qvQc-d04jvH8pE3sMIfi`
- `DRIVE_DB_FOLDER_ID=1-aGrHKvB8f28BVmvVwy529PMuUq40XXS`
- `DRIVE_FILES_FOLDER_ID=1bgA7rTtuxa6JecAgouKxliISTzPg8Rry`
- `DRIVE_MANIFESTS_FOLDER_ID=1K1TFWRPUZmOg_mm71EEoESFZieLwU87v`

Runtime config location:
- `config/env.sh`

---

## Retention policy (current)
To reduce confusion and storage growth during stabilization:

- Keep exactly one canonical backup set in cloud (latest verified)
- Keep exactly one canonical backup set locally
- Remove temp and duplicate artifacts after verification

Note: Increase retention depth after scheduler/policy automation is implemented.

---

## Rollback plan
If canonical path is unavailable or corrupted:

1. Restore previous folder IDs in `config/env.sh`
2. Re-run upload validation
3. Re-run restore-from-drive drill
4. Document incident and cause in `docs/recovery_checkpoint.md`

---

## Verification checklist
- [x] `scripts/03_upload_to_drive.sh` succeeds with `OSB_BACKEND=gog`
- [x] Uploaded DB/file artifacts are visible in canonical path
- [x] Manifest/checksum files are visible in canonical path
- [x] Legacy duplicate cloud artifacts cleaned
- [x] Local duplicate backup/temp artifacts cleaned

---

## Notes for future adapters
This namespace convention should be preserved for non-WordPress adapters:

- `opensitebackup/ghost/<site-slug>/...`
- `opensitebackup/static/<site-slug>/...`
- `opensitebackup/custom/<site-slug>/...`

This keeps provider storage organized and avoids cross-adapter collisions.
