#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

REPORT_DIR="${OSB_STATE:-$OSB_HOME/data/state}"
REPORT_FILE="$REPORT_DIR/release_readiness_report.md"
mkdir -p "$REPORT_DIR"

run_and_capture() {
  local title="$1"
  shift
  local tmp
  tmp="$(mktemp)"
  local status=0
  if "$@" >"$tmp" 2>&1; then
    status=0
  else
    status=$?
  fi

  {
    echo "## $title"
    echo "- status: $([[ $status -eq 0 ]] && echo PASS || echo FAIL)"
    echo
    echo '```text'
    cat "$tmp"
    echo '```'
    echo
  } >> "$REPORT_FILE"

  rm -f "$tmp"
  return $status
}

{
  echo "# OpenSiteBackup Release Readiness Report"
  echo
  echo "Generated: $(date -Is)"
  echo "Branch: $(git -C "$OSB_HOME" rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git -C "$OSB_HOME" rev-parse --short HEAD)"
  echo
} > "$REPORT_FILE"

run_and_capture "Strict Preflight" bash "$OSB_HOME/scripts/preflight.sh" --strict
run_and_capture "Pre-release Check" bash "$OSB_HOME/scripts/pre_release_check.sh"
run_and_capture "Backend Matrix Smoke" bash "$OSB_HOME/scripts/backend_matrix_smoke.sh"

if [[ "${RUN_RESTORE_DRILL:-0}" == "1" ]]; then
  run_and_capture "Pre-release Check (with Restore Drill)" env RUN_RESTORE_DRILL=1 bash "$OSB_HOME/scripts/pre_release_check.sh"
fi

echo "RELEASE_PREPARE: report=$REPORT_FILE"
