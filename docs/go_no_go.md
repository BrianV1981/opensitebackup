# OpenSiteBackup — Go/No-Go Decision Guide

Use this guide for final release decisions after Phase 5 gates are complete.

## Generate packet

```bash
bash scripts/generate_launch_packet.sh
```

Output:

- `data/state/launch_go_no_go_packet.md`

## Required inputs

- `data/state/release_readiness_report.md`
- `data/state/backend_matrix_smoke.log`
- `data/state/restore_metrics.jsonl`

## Decision rules

**GO** when all are true:

1. `preflight --strict` passes
2. `pre_release_check.sh` passes
3. backend matrix has no unexpected failures
4. restore evidence is present (`RESTORE_SUMMARY` + metrics rows)
5. CI is green on PR
6. maintainer explicitly approves merge

**NO-GO** if any of the above fail.

## Post-GO actions

1. Merge approved PR (`dev -> main`)
2. Create release tag (e.g., `v0.1.0-alpha.1`)
3. Publish release notes from `docs/release_notes_template.md`
4. Archive packet as release evidence
