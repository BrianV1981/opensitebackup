# Contributing

Thanks for contributing to OpenSiteBackup.

## Development flow
1. Fork and create a branch: `feat/<name>` or `fix/<name>`
2. Make small, focused commits
3. Run checks locally:
   - `bash scripts/preflight.sh --strict`
   - `bash scripts/lint.sh`
   - `bash scripts/validate_env.sh backup`
   - `bash scripts/validate_env.sh upload`
4. If restore/upload paths changed, run targeted smoke checks:
   - `OSB_BACKEND=local bash scripts/03_upload_to_drive.sh`
   - `bash scripts/05_restore_from_drive.sh` (destructive local drill; optional by scope)
5. For release-impacting changes, run:
   - `bash scripts/pre_release_check.sh`
   - `bash scripts/backend_matrix_smoke.sh`
6. Update docs for behavior changes (hard rule)
7. Open PR with:
   - problem statement
   - change summary
   - test evidence

## Hard rules
- Do not commit secrets (`config/env.sh`, keys, tokens)
- Do not commit runtime data (`data/backups`, `data/sites`, logs)
- Docs must be updated whenever scripts/behavior changes

## Commit style (recommended)
- `feat: ...`
- `fix: ...`
- `docs: ...`
- `chore: ...`
