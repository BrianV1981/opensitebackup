# OpenSiteBackup — TUI Setup Flow Spec

## Purpose
Define a guided, beginner-friendly TUI onboarding flow that reduces setup failures (especially SSH) and enforces all critical hardening requirements from `docs/archive/RED_TEAM_FIX_LIST.closed.md`.

This spec is implementation-facing and should be treated as a required build checklist.

---

## Scope and non-goals

## In scope
- First-run setup wizard for `config/env.sh`
- Inline help for each required field
- SSH key creation/validation path
- Backend-specific validation and preflight
- Safe dry-run/connection checks

## Out of scope
- Full GUI dashboard
- Multi-tenant web admin
- Non-terminal UX

---

## Must-align with Red Team Fix List

The wizard implementation must directly support and enforce these red-team requirements:

### P0 items to enforce in TUI
1. **No hardcoded project/site values** in runtime scripts or generated config.
2. **Strict command-specific env validation** before destructive operations.
3. **Concurrency lock awareness** (warn if another run lock exists).
4. **Retention policy setup** fields during onboarding.
5. **Staged/atomic restore prerequisites** captured in config.

### P1 items to support in TUI
1. Backend neutrality default (`local` or `rclone`), gog optional.
2. Post-upload verification toggles and backend verify capability hints.
3. Structured logging toggles (run ID + JSON mode optional).
4. Restore safety gate options for release checks.

### P2 items this wizard contributes to
1. Multi-site readiness (profile-based config path scaffold).
2. Security posture prompts (artifact encryption future flag placeholder).

---

## UX design principles

1. Every prompt includes:
   - **What this field is**
   - **Where to find it**
   - **Example value**
   - **How to verify it**
2. Show plain-language failures + exact fix command.
3. Default to safe options.
4. Never run destructive steps during setup.
5. Offer `guided` mode and `advanced` mode.

---

## Wizard flow (step-by-step)

## Step 0 — Welcome and mode selection

Prompt:
- `Select mode: [1] Guided (recommended) [2] Advanced`

Explain:
- Guided asks for required values with checks.
- Advanced allows direct value entry with minimal prompts.

---

## Step 1 — Project root and self-contained paths

Collect/confirm:
- `OSB_HOME`
- `OSB_BACKUPS`
- `OSB_LOGS`
- `OSB_TMP`
- `OSB_STATE`

Default behavior:
- all under `$OSB_HOME/data/...`

Validation:
- ensure writable paths
- warn if paths point outside project root (allow override)

Red-team linkage:
- supports no-sprawl and no hardcoded assumptions.

---

## Step 2 — Source profile basics

Collect:
- `SOURCE_KIND` (default `wordpress`)
- `SITE_PROFILE_NAME` (e.g., `primary-site`)
- `SOURCE_SITE_SLUG` (e.g., `my-site`)

Validation:
- slug format: lowercase + hyphen/underscore only

Red-team linkage:
- removes site-specific hardcoding and enables future multi-site profiles.

---

## Step 3 — SSH onboarding (critical)

## 3.1 Host details
Collect:
- `LIVE_SSH_HOST`
- `LIVE_SSH_USER`
- `LIVE_SSH_PORT` (default 22)
- `LIVE_SITE_PATH`

Inline guidance for each field (required):
- what it is
- where to find it in hosting panel
- example values

## 3.2 Key setup branch
Prompt:
- `Do you already have an SSH key in WSL/Linux? [yes/no]`

If no:
- guide key generation (`ssh-keygen -t ed25519 -C "<email>"`)
- show public key (`cat ~/.ssh/id_ed25519.pub`)
- explain adding/authorizing in host panel

If yes:
- collect key path (default `~/.ssh/id_ed25519`)

## 3.3 Permission checks
Validate key file exists and permissions are safe.

If unsafe, show fix commands:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

WSL guidance:
- if key is in `/mnt/c/...`, suggest copying to `~/.ssh`.

## 3.4 Connection test
Run key-only test:
```bash
ssh -o IdentitiesOnly=yes -o PreferredAuthentications=publickey -p <port> -i <key> <user>@<host> "echo OSB_SSH_OK"
```

Error branching required:
- `Permission denied (publickey...)`
- `UNPROTECTED PRIVATE KEY FILE`
- timeout/refused
- unknown host key prompt

Red-team linkage:
- solves major setup failure source and enforces strict validation before run.

---

## Step 4 — Restore target and local DB settings

Collect:
- `LOCAL_RESTORE_PATH`
- `LOCAL_URL`
- `LOCAL_DB_NAME`
- `LOCAL_DB_USER`
- `LOCAL_DB_PASSWORD`
- `LOCAL_DB_HOST`
- `LOCAL_DB_PORT`

Validation:
- URL format
- path writable
- DB vars non-empty

Explain clearly:
- these are local target settings for restore drills.

Red-team linkage:
- eliminates hardcoded restore credentials.

---

## Step 5 — Domain rewrite mappings (dynamic)

Collect N rewrite pairs (1..N):
- `OSB_REWRITE_FROM_1`, `OSB_REWRITE_TO_1`
- `OSB_REWRITE_FROM_2`, `OSB_REWRITE_TO_2`
- etc.

Default first pair suggestion:
- from live domain
- to local URL

Validation:
- avoid empty `from` or `to`
- detect duplicate from-values

Red-team linkage:
- removes simplistic hardcoded URL rewrite behavior.

---

## Step 6 — Backend selection and backend-specific prompts

Prompt:
- `Select upload backend: [local] [rclone] [gog(optional)]`

Default:
- `local` (or `rclone` if configured)

### If local
Collect:
- `LOCAL_UPLOAD_ROOT`

### If rclone
Collect:
- `RCLONE_REMOTE`
- `RCLONE_FLAGS` (optional)

Run test:
- `rclone lsd <remote>` or equivalent non-destructive probe

### If gog
Collect:
- `DRIVE_ACCOUNT`
- `DRIVE_DB_FOLDER_ID`
- `DRIVE_FILES_FOLDER_ID`
- `DRIVE_MANIFESTS_FOLDER_ID`

Run test:
- lightweight gog auth/status check

Red-team linkage:
- backend neutrality; gog remains optional.

---

## Step 7 — Reliability and safety controls

Collect:
- `OSB_UPLOAD_RETRIES`
- `OSB_UPLOAD_RETRY_DELAY_SEC`
- `OSB_LOCK_TIMEOUT_SEC`
- `OSB_RESTORE_CONFIRM_REQUIRED` (default 1)
- `OSB_LOG_JSON` (default 0)

Explain:
- retries help transient cloud failures
- lock timeout helps avoid run collisions
- confirm-required prevents accidental destructive restore

Red-team linkage:
- concurrency and reliability controls.

---

## Step 8 — Retention policy setup

Collect:
- `OSB_RETENTION_DAILY`
- `OSB_RETENTION_WEEKLY`
- `OSB_RETENTION_MONTHLY`
- `OSB_RETENTION_PRUNE_EMPTY`

Explain:
- this controls storage growth and cleanup behavior.

Red-team linkage:
- addresses missing retention policy implementation.

---

## Step 9 — Save config and profile

Write:
- `config/env.sh`
- profile file `config/sites/<site-slug>.env`

Profile switching command:
- `bash scripts/use_site_profile.sh <site-slug>`

Safety:
- create timestamped backup if env file exists
- file perms `600`

Show:
- path summary of saved files

---

## Step 10 — Post-setup validation (non-destructive)

Run:
1. `scripts/validate_env.sh backup`
2. `scripts/validate_env.sh upload`
3. `scripts/preflight.sh --strict`
4. SSH connection-only test

Optional prompt:
- `Run first backup now? [yes/no]`

If yes:
- run backup + verify only (no restore)

---

## Required implementation files

- `scripts/setup_wizard.sh`
- `scripts/validate_env.sh`
- `scripts/ssh_troubleshoot.sh` (helper optional)

Update runtime scripts to call `validate_env.sh` by command context:
- backup
- verify
- upload
- restore
- demo
- release

---

## Validation matrix for `validate_env.sh`

## backup
Required:
- `LIVE_SSH_HOST`, `LIVE_SSH_USER`, `LIVE_SITE_PATH`, `LIVE_SSH_KEY`

## verify
Required:
- `OSB_BACKUPS` or `LOCAL_BACKUP_ROOT`

## upload/local
Required:
- `LOCAL_UPLOAD_ROOT`

## upload/rclone
Required:
- `RCLONE_REMOTE`

## upload/gog
Required:
- `DRIVE_ACCOUNT`, `DRIVE_DB_FOLDER_ID`, `DRIVE_FILES_FOLDER_ID`, `DRIVE_MANIFESTS_FOLDER_ID`

## restore/local
Required:
- `LOCAL_RESTORE_PATH`, `LOCAL_URL`, local DB vars

## restore/drive
Required:
- all restore/local vars + `DRIVE_ACCOUNT`, `DRIVE_DB_FILE_ID`, `DRIVE_FILES_FILE_ID`

---

## CI enforcement additions (required)

1. Fail build if banned hardcoded tokens are present in runtime scripts:
```bash
grep -RInE 'tbsoftwash|localhost:8081|ChangeThisNow_123' scripts adapters backends && exit 1 || true
```

2. Add dry-run env validation job for each command context.

---

## Definition of done

- Wizard generates valid `config/env.sh` from prompts only.
- New user can complete SSH setup with guided flow and pass connection test.
- Runtime scripts no longer require source edits for per-user/per-site values.
- `validate_env.sh` blocks destructive operations when required vars are missing.
- Retention settings captured and consumed by cleanup flow.
- CI enforces anti-hardcoding checks.

---

## Handoff note for implementer

Treat this file and `docs/archive/RED_TEAM_FIX_LIST.closed.md` as paired requirements.
If conflicts appear, Red Team list priority wins for safety-critical behavior.
