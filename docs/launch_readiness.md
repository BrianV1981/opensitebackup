# OpenSiteBackup — Phase 5 Launch Readiness

This document tracks launch-readiness completion criteria for v0.1.x releases.

## Scope

Phase 5 covers operational release confidence, packaging, and communication readiness.

## Required gates

- [ ] `bash scripts/release_prepare.sh` passes
- [ ] CI green on dev branch
- [ ] release evidence report generated (`data/state/release_readiness_report.md`)
- [ ] release checklist completed (`docs/release_checklist.md`)

## External validation loop

- [ ] at least 3 independent operator runs of backup->verify->upload
- [ ] at least 1 successful restore drill report from non-primary operator
- [ ] capture key blockers and mitigations in issue tracker

## Release packaging

- [ ] PR prepared (`dev -> main`) with evidence snippets
- [ ] tag plan confirmed (`v0.1.0-alpha.1` or next)
- [ ] rollback notes included in PR

## Public-facing assets

- [ ] release notes drafted from template (`docs/release_notes_template.md`)
- [ ] demo command list validated
- [ ] known caveats section finalized

## Exit condition

Phase 5 is considered closed when all required gates are checked and the release PR is approved for merge by maintainer.
