# Contributing

Thanks for contributing to OpenSiteBackup.

## Development flow
1. Fork and create a branch: `feat/<name>` or `fix/<name>`
2. Make small, focused commits
3. Run checks locally:
   - `bash scripts/preflight.sh --help`
   - `bash scripts/lint.sh`
4. Update docs for behavior changes (hard rule)
5. Open PR with:
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
