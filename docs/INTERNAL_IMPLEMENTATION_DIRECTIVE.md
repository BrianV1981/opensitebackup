# OpenSiteBackup — Internal Implementation Directive

## Context
We have:
- a working OpenSiteBackup repo,
- proven backup + cloud upload + cloud-to-local restore,
- external feedback validating positioning and monetization direction.

**Do not update docs in this task block.**
This directive is implementation-only and execution-focused.

---

## Mission
Implement the top recommendations from external review by shipping technical assets that improve adoption and launch readiness:

1) repo structure refactor (adapters/backends),
2) comparison capability groundwork,
3) demo-ready restore workflow hardening,
4) launch execution artifacts (code/automation, not docs edits).

---

## Hard Constraints
- No destructive changes without explicit confirmation.
- Preserve existing working scripts as fallback.
- Keep backward compatibility for current operator flow.
- No doc edits in this pass (README/docs untouched).
- Commit in small, logical units with clear messages.

---

## Branching / Workflow
1. Create/use a GitHub dev branch (do not work on `main`).
2. Commit per milestone (below).
3. Push to the dev branch and open PR targeting `main` only when ready for review.
4. Include command output evidence in PR body (not docs files).

---

## Milestone 1 — Adapter/Backend Refactor (Priority: Highest)

### Goal
Move from flat scripts to architecture-aligned layout without breaking current flow.

### Required file structure
Create:

```text
adapters/wordpress/
  backup.sh
  verify.sh
  restore.sh

backends/
  local/upload.sh
  gog/upload.sh
  # scaffold rclone/upload.sh (can be no-op with TODO if not ready)
```

### Implementation requirements
- Extract logic from:
  - `scripts/01_pull_live_backup.sh` -> `adapters/wordpress/backup.sh`
  - `scripts/02_verify_backup.sh` -> `adapters/wordpress/verify.sh`
  - `scripts/04_restore_local.sh` + `scripts/05_restore_from_drive.sh` -> `adapters/wordpress/restore.sh`
  - `scripts/03_upload_to_drive.sh` -> `backends/gog/upload.sh`
- Keep existing scripts as wrappers so user commands still work.
- Wrappers should call new adapter/backend implementations.

### Acceptance criteria
- Existing commands still run:
  - `bash scripts/01_pull_live_backup.sh`
  - `bash scripts/02_verify_backup.sh`
  - `bash scripts/03_upload_to_drive.sh`
  - `bash scripts/04_restore_local.sh`
- No behavior regression in:
  - stage logging,
  - empty-folder cleanup on failed run,
  - checksum/manifest generation.

---

## Milestone 2 — Backend Selection Engine

### Goal
Enable upload backend switching via env var without script edits.

### Requirements
- Add backend selector in orchestration layer (or wrapper):
  - `OSB_BACKEND=local|gog|rclone`
- `scripts/03_upload_to_drive.sh` should become generic upload entrypoint (`run_upload` behavior).
- Route to backend implementation file by value.
- Keep gog path as current working default for existing env.

### Acceptance criteria
- `OSB_BACKEND=gog` works exactly as today.
- `OSB_BACKEND=local` writes artifacts to configured local target path.
- Unknown backend exits with clear error and non-zero code.

---

## Milestone 3 — Restore Drill Reliability Hardening

### Goal
Reduce restore ambiguity and make repeat runs predictable.

### Required changes
- Add pre-restore validations:
  - artifact existence check,
  - target path check,
  - wp-config presence after extract.
- Add post-restore validations:
  - `wp option get siteurl`,
  - `wp option get blogname`,
  - page count check (`wp post list --post_type=page --format=count`).
- Emit machine-parseable summary line at end:
  - `RESTORE_SUMMARY siteurl=... blogname=... pages=...`

### Acceptance criteria
- Failed restore exits non-zero with reason.
- Successful restore emits summary line.
- Current local restore use case still passes.

---

## Milestone 4 — Comparison Data Capture (Code-only groundwork)

### Goal
Prepare objective benchmark inputs for future comparison table (without doc editing).

### Required changes
Create script:
- `scripts/collect_restore_metrics.sh`

Output file:
- `data/state/restore_metrics.jsonl` (gitignored)

Capture:
- timestamp
- backup source type (`live_pull` / `drive_restore`)
- files archive size
- db size
- backup duration (if available)
- restore duration
- page count after restore
- theme slug after restore
- success/fail + error reason

### Acceptance criteria
- Script runs post-restore and appends one JSONL row.
- No secrets stored in metrics file.
- File is ignored by git.

---

## Milestone 5 — Demo-Run Automation Support

### Goal
Make “record demo” run easy and repeatable.

### Required changes
Create:
- `scripts/demo_restore_run.sh`

Behavior:
1) run preflight
2) run restore from Drive
3) run post-restore checks
4) print concise “demo success block” with URLs/metrics

Optional:
- start local server on configurable port if not running.

### Acceptance criteria
- Single command produces demo-ready terminal output.
- Non-zero exit if any critical step fails.

---

## Milestone 6 — Pricing/Launch Recommendations as Issues (No doc changes)

### Goal
Translate strategic suggestions into executable backlog.

### Required actions
Create GitHub issues (implementation tasks, not docs content):
1. Add comparison table generation data source
2. Add demo video script + capture checklist automation
3. Implement rclone backend
4. Add agency pricing configuration model (future SaaS)
5. Add release checklist script gate (`pre-release` command)

Use labels:
- `enhancement`
- `launch`
- `backend`
- `roadmap`

---

## Test Matrix (must run before PR)
Run and capture output for each:

1. `bash scripts/preflight.sh --strict`
2. Live pull path:
   - `bash scripts/01_pull_live_backup.sh`
   - `bash scripts/02_verify_backup.sh`
3. Upload path:
   - `OSB_BACKEND=gog bash scripts/03_upload_to_drive.sh`
4. Restore path:
   - `bash scripts/05_restore_from_drive.sh`
5. Post-check:
   - `wp option get blogname`
   - `wp option get template`
   - `wp post list --post_type=page --format=count`

---

## Commit Plan (suggested)
1. `refactor: introduce wordpress adapter and backend directories`
2. `feat: add backend selector for upload pipeline`
3. `feat: harden restore with pre/post validation and summary output`
4. `feat: add restore metrics collector`
5. `feat: add demo restore run command`
6. `chore: add launch backlog issues and labels`

---

## Definition of Done
- Refactor complete, backward-compatible wrappers preserved
- Backend selection functional
- Restore drill hardened with deterministic output
- Metrics capture implemented
- Demo-run script implemented
- PR opened with test evidence and clean CI
