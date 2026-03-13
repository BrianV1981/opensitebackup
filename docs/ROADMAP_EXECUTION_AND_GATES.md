# Roadmap Execution & Test Gates

This document defines how OpenSiteBackup work advances phase-by-phase with verifiable checks.

## Rule
Do not move to the next phase until the current phase gate passes.

---

## Gate commands

### Phase 0 gate (alignment + cleanup)
```bash
bash scripts/phase_gate.sh phase0
```

### Phase 1 gate (backup core)
```bash
bash scripts/phase_gate.sh phase1
```

### Phase 2 gate (verify + restore confidence)
```bash
bash scripts/phase_gate.sh phase2
```

### Phase 3 gate (backend upload reliability)
```bash
bash scripts/phase_gate.sh phase3
```

### Phase 4 gate (docs/handoff quality)
```bash
bash scripts/phase_gate.sh phase4
```

### Phase 5 gate (release readiness)
```bash
bash scripts/phase_gate.sh phase5
```

---

## Test suite levels

Run directly when needed:

```bash
bash scripts/test_suite.sh quick
bash scripts/test_suite.sh phase1
bash scripts/test_suite.sh phase2
bash scripts/test_suite.sh phase3
bash scripts/test_suite.sh full
```

Reports are written under:
- `data/state/test_runs/`

---

## What each level validates

- `quick`:
  - shell syntax
  - docs link consistency
  - env validation matrix

- `phase1`:
  - quick + strict preflight + doctor
  - backup adapter contract checks (`scripts/test_phase1_backup_core.sh`)

- `phase2`:
  - phase1 + backup verification
  - verify/restore contract checks (`scripts/test_phase2_verify_restore.sh`)

- `phase3`:
  - phase2 + backend contract checks (`scripts/test_phase3_backends.sh`)
  - backend smoke + local upload

- `phase4 gate` (via `scripts/phase_gate.sh phase4`):
  - phase3 suite
  - docs link checks
  - docs/handoff contract checks (`scripts/test_phase4_docs_handoff.sh`)

- `full`:
  - phase3 + pre-release check

---

## Process discipline

For each roadmap milestone:
1. Implement change
2. Run relevant phase gate
3. Save evidence in commit/PR notes
4. Update docs in same change

This keeps roadmap execution measurable and auditable.
