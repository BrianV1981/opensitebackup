#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
cd "$OSB_HOME"

LEVEL="${1:-quick}"
if [[ "$LEVEL" == "--level" ]]; then
  LEVEL="${2:-quick}"
fi

RUN_ID="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="$OSB_HOME/data/state/test_runs/$RUN_ID"
mkdir -p "$OUT_DIR"
LOG="$OUT_DIR/test_suite.log"
REPORT="$OUT_DIR/report.md"

pass=0
fail=0

run_step() {
  local name="$1"; shift
  echo "\n== $name ==" | tee -a "$LOG"
  if "$@" >>"$LOG" 2>&1; then
    echo "PASS: $name" | tee -a "$LOG"
    pass=$((pass+1))
  else
    echo "FAIL: $name" | tee -a "$LOG"
    fail=$((fail+1))
  fi
}

run_quick() {
  run_step "shell syntax" bash -c 'bash -n scripts/*.sh adapters/wordpress/*.sh backends/*/upload.sh'
  run_step "docs links" bash scripts/check_docs_links.sh
  run_step "env matrix" bash scripts/validate_env_matrix_ci.sh
}

run_phase1() {
  run_step "strict preflight" bash scripts/preflight.sh --strict
  run_step "doctor" bash scripts/doctor.sh
  run_step "phase1 backup core contract" bash scripts/test_phase1_backup_core.sh
}

run_phase2() {
  run_step "verify latest backup" bash scripts/02_verify_backup.sh
  run_step "phase2 verify+restore contract" bash scripts/test_phase2_verify_restore.sh
}

run_phase3() {
  run_step "backend smoke" bash scripts/backend_matrix_smoke.sh
  run_step "local upload" bash -c 'OSB_BACKEND=local bash scripts/03_upload_to_drive.sh'
}

run_full() {
  run_step "pre_release_check" bash scripts/pre_release_check.sh
}

case "$LEVEL" in
  quick)
    run_quick
    ;;
  phase1)
    run_quick
    run_phase1
    ;;
  phase2)
    run_quick
    run_phase1
    run_phase2
    ;;
  phase3)
    run_quick
    run_phase1
    run_phase2
    run_phase3
    ;;
  full)
    run_quick
    run_phase1
    run_phase2
    run_phase3
    run_full
    ;;
  *)
    echo "Unknown level: $LEVEL (use quick|phase1|phase2|phase3|full)" >&2
    exit 2
    ;;
esac

status="PASS"
if [[ "$fail" -gt 0 ]]; then
  status="FAIL"
fi

cat > "$REPORT" <<EOF
# OpenSiteBackup Test Suite Report

- Run ID: $RUN_ID
- Level: $LEVEL
- Status: $status
- Passed: $pass
- Failed: $fail
- Log: $LOG

EOF

echo "TEST_SUITE_STATUS=$status"
echo "TEST_SUITE_REPORT=$REPORT"

if [[ "$fail" -gt 0 ]]; then
  exit 1
fi
