#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

if [[ "${1:-}" == "--profile" ]]; then
  slug="${2:-}"
  [[ -n "$slug" ]] || { echo "Usage: bash scripts/test_restore_local.sh [--profile <slug>]"; exit 2; }
  bash "$OSB_HOME/scripts/use_site_profile.sh" "$slug"
  shift 2
fi

: "${OSB_RESTORE_CONFIRM_REQUIRED:=0}"
export OSB_RESTORE_CONFIRM_REQUIRED

# shellcheck source=/dev/null
source "$OSB_HOME/scripts/log.sh"
osb_log INFO "test_restore_local start" "confirm_required=$OSB_RESTORE_CONFIRM_REQUIRED"

bash "$OSB_HOME/scripts/preflight.sh" --strict
bash "$OSB_HOME/scripts/04_restore_local.sh"

echo "TEST_RESTORE_LOCAL: OK"
