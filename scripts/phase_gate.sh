#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
cd "$OSB_HOME"

PHASE="${1:-}"
if [[ -z "$PHASE" ]]; then
  echo "Usage: bash scripts/phase_gate.sh <phase0|phase1|phase2|phase3|phase4|phase5>" >&2
  exit 2
fi

case "$PHASE" in
  phase0)
    bash scripts/test_suite.sh quick
    test -f docs/storage_migration_plan.md
    ;;
  phase1)
    bash scripts/test_suite.sh phase1
    ;;
  phase2)
    bash scripts/test_suite.sh phase2
    ;;
  phase3)
    bash scripts/test_suite.sh phase3
    ;;
  phase4)
    bash scripts/test_suite.sh phase3
    bash scripts/check_docs_links.sh
    ;;
  phase5)
    bash scripts/test_suite.sh full
    ;;
  *)
    echo "Unknown phase: $PHASE" >&2
    exit 2
    ;;
esac

echo "PHASE_GATE_OK phase=$PHASE"
