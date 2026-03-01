#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# shellcheck source=/dev/null
source "$OSB_HOME/scripts/log.sh"
osb_log INFO "run_all start"
osb_log INFO "stage" "name=preflight"
bash "$OSB_HOME/scripts/preflight.sh" --strict

osb_log INFO "stage" "name=backup"
bash "$OSB_HOME/scripts/01_pull_live_backup.sh"

osb_log INFO "stage" "name=verify"
bash "$OSB_HOME/scripts/02_verify_backup.sh"

osb_log INFO "stage" "name=upload" "backend=${OSB_BACKEND:-local}"
bash "$OSB_HOME/scripts/03_upload_to_drive.sh"

osb_log INFO "RUN_ALL OK"
