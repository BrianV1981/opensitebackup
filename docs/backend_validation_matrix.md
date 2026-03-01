# Backend Validation Matrix (Phase 3)

This document defines how to validate upload backend reliability for v1.

## Goal

Confirm the same verified backup can be uploaded across backend implementations without core flow changes.

## Command

```bash
bash scripts/backend_matrix_smoke.sh
```

## Backend pass criteria

- `local`: must pass
- `gog`: pass when tool + required env present
- `rclone`: pass when tool + `RCLONE_REMOTE` present

Backends missing tool/env are logged as `SKIP`, not hard failures.

## Output log

- `data/state/backend_matrix_smoke.log`

Expected line format:

```text
[ISO_TIMESTAMP] START backend=<name>
[ISO_TIMESTAMP] END backend=<name> status=success|failure
[ISO_TIMESTAMP] SKIP backend=<name> reason=...
```

## Reliability knobs

Cloud backend retries are governed by:

- `OSB_UPLOAD_RETRIES`
- `OSB_UPLOAD_RETRY_DELAY_SEC`

Upload step emits `UPLOAD_VERIFY_SUMMARY` markers after successful backend operations.

## Recommended cadence

- Run before any dev->main promotion
- Run after backend-related changes
- Include latest log snippet in PR evidence
