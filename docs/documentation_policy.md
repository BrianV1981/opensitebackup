# Documentation Policy (Hard Rule)

OpenSiteBackup requires docs to be updated whenever behavior changes.

## Rule
Any change to scripts, config shape, or runtime flow MUST include doc updates in the same PR/commit.

## Minimum docs to review on each change
- `README.md`
- `docs/architecture.md`
- `docs/runbook.md`
- `docs/troubleshooting.md`
- `docs/self_contained_mode.md`
- `docs/handoff_checklist.md` (if process changed)
- `docs/release_checklist.md` (if release/promotion process changed)
- `docs/TUI_SETUP_FLOW.md` and `docs/archive/RED_TEAM_FIX_LIST.closed.md` (when onboarding/safety model changes)
- `docs/DOCS_INDEX.md` (when canonical/archived doc map changes)

## Periodic review cadence
- Weekly: quick doc drift scan
- Monthly: full runbook review
- Before each release: complete docs audit

## Evidence in PR
Each PR must include:
- changed docs list
- statement: "Docs reviewed and updated"
