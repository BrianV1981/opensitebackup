# OpenSiteBackup — Release Checklist

Use this checklist before promoting `dev` changes to `main`.

## 1) Branch hygiene

- [ ] `dev` branch is clean (no uncommitted changes)
- [ ] `dev` is pushed and up to date with remote
- [ ] posterity/snapshot branch exists when needed

## 2) Validation gates

- [ ] `bash scripts/preflight.sh --strict`
- [ ] `bash scripts/pre_release_check.sh`
- [ ] `bash scripts/backend_matrix_smoke.sh`
- [ ] `bash scripts/release_prepare.sh`
- [ ] `RUN_RESTORE_DRILL=1 bash scripts/pre_release_check.sh` (when intentional)
- [ ] CI is green on PR

## 3) Artifact/restore confidence

- [ ] verify artifacts regenerated successfully (`manifest.txt`, `local_sha256.txt`)
- [ ] restore summary line captured (`RESTORE_SUMMARY ...`)
- [ ] `data/state/restore_metrics.jsonl` has at least one current successful row

## 4) Documentation coherence (root + docs)

- [ ] `README.md` reflects current script/layout behavior
- [ ] `CHANGELOG.md` includes all new behavior changes
- [ ] `docs/architecture.md` aligns with implementation
- [ ] `docs/runbook.md` and `docs/troubleshooting.md` current
- [ ] handoff docs updated (`docs/HANDOFF_PACK.md`, `docs/handoff_checklist.md`)

## 5) PR quality

- [ ] PR uses updated template sections
- [ ] includes strict preflight evidence
- [ ] includes pre_release_check evidence
- [ ] includes launch packet evidence (`data/state/launch_go_no_go_packet.md`)
- [ ] includes rollback notes and known caveats

## 6) Merge + tagging

- [ ] explicit human approval to merge
- [ ] merge strategy chosen (recommended: squash)
- [ ] create tag after merge (example: `v0.1.0-alpha.1`)
- [ ] verify default branch strategy remains intentional
