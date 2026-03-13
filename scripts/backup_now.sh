#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

if [[ "${1:-}" == "--profile" ]]; then
  slug="${2:-}"
  [[ -n "$slug" ]] || { echo "Usage: bash scripts/backup_now.sh [--profile <slug>]"; exit 2; }
  bash "$OSB_HOME/scripts/use_site_profile.sh" "$slug"
  shift 2
fi

# shellcheck source=/dev/null
source "$OSB_HOME/scripts/log.sh"
osb_log INFO "backup_now start"

bash "$OSB_HOME/scripts/preflight.sh" --strict
bash "$OSB_HOME/scripts/01_pull_live_backup.sh"
bash "$OSB_HOME/scripts/02_verify_backup.sh"
bash "$OSB_HOME/scripts/03_upload_to_drive.sh"

bash "$OSB_HOME/scripts/status_snapshot.sh"

echo "BACKUP_NOW: OK"
