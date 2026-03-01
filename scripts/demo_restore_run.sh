#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${LOCAL_RESTORE_PATH:?LOCAL_RESTORE_PATH is required}"
: "${LOCAL_URL:?LOCAL_URL is required}"

start_ts=$(date +%s)
restore_ok=false
restore_error=""

capture_failure_metrics() {
  local code=$?
  local end_ts duration
  end_ts=$(date +%s)
  duration=$((end_ts-start_ts))
  if [[ "$restore_ok" != "true" ]]; then
    RESTORE_SOURCE_TYPE="drive_restore" \
    RESTORE_DURATION_SEC="$duration" \
    RESTORE_SUCCESS="false" \
    RESTORE_ERROR="${restore_error:-demo_restore_run_failed_exit_${code}}" \
    bash "$OSB_HOME/scripts/collect_restore_metrics.sh" || true
  fi
  exit $code
}
trap capture_failure_metrics EXIT

echo "[demo 1/4] Preflight"
bash "$OSB_HOME/scripts/preflight.sh" --strict

echo "[demo 2/4] Restore from Drive"
if ! bash "$OSB_HOME/scripts/05_restore_from_drive.sh"; then
  restore_error="restore_from_drive_failed"
  exit 1
fi

echo "[demo 3/4] Post-restore checks"
cd "$LOCAL_RESTORE_PATH"
siteurl="$(wp option get siteurl)"
blogname="$(wp option get blogname)"
theme="$(wp option get template)"
pages="$(wp post list --post_type=page --format=count)"

end_ts=$(date +%s)
restore_duration=$((end_ts-start_ts))

echo "[demo 4/4] Metrics capture"
RESTORE_SOURCE_TYPE="drive_restore" \
RESTORE_DURATION_SEC="$restore_duration" \
RESTORE_SUCCESS="true" \
bash "$OSB_HOME/scripts/collect_restore_metrics.sh"

restore_ok=true
trap - EXIT

echo
printf '==== DEMO SUCCESS ====\n'
printf 'LOCAL_URL=%s\n' "$LOCAL_URL"
printf 'SITEURL=%s\n' "$siteurl"
printf 'BLOGNAME=%s\n' "$blogname"
printf 'THEME=%s\n' "$theme"
printf 'PAGES=%s\n' "$pages"
printf 'RESTORE_DURATION_SEC=%s\n' "$restore_duration"
printf '======================\n'
