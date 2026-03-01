#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

MATRIX_LOG="${OSB_STATE:-$OSB_HOME/data/state}/backend_matrix_smoke.log"
mkdir -p "$(dirname "$MATRIX_LOG")"

run_backend() {
  local backend="$1"
  local ts status
  ts="$(date -Is)"
  echo "[$ts] START backend=$backend" | tee -a "$MATRIX_LOG"

  if OSB_BACKEND="$backend" bash "$OSB_HOME/scripts/03_upload_to_drive.sh"; then
    status="success"
  else
    status="failure"
  fi

  ts="$(date -Is)"
  echo "[$ts] END backend=$backend status=$status" | tee -a "$MATRIX_LOG"

  [[ "$status" == "success" ]]
}

echo "[matrix 1/3] strict preflight"
bash "$OSB_HOME/scripts/preflight.sh" --strict

echo "[matrix 2/3] verify artifacts"
bash "$OSB_HOME/scripts/02_verify_backup.sh"

echo "[matrix 3/3] backend upload matrix"

hard_fail=0

# local is always expected to pass
if ! run_backend local; then
  hard_fail=1
fi

# gog/rclone run conditionally based on available env/tools
if command -v gog >/dev/null 2>&1 && [[ -n "${DRIVE_ACCOUNT:-}" && -n "${DRIVE_DB_FOLDER_ID:-}" && -n "${DRIVE_FILES_FOLDER_ID:-}" && -n "${DRIVE_MANIFESTS_FOLDER_ID:-}" ]]; then
  if ! run_backend gog; then
    echo "[$(date -Is)] WARN backend=gog failed (optional backend)" | tee -a "$MATRIX_LOG"
  fi
else
  echo "[$(date -Is)] SKIP backend=gog reason=missing_tool_or_env" | tee -a "$MATRIX_LOG"
fi

if command -v rclone >/dev/null 2>&1 && [[ -n "${RCLONE_REMOTE:-}" ]]; then
  if ! run_backend rclone; then
    echo "[$(date -Is)] WARN backend=rclone failed (optional backend)" | tee -a "$MATRIX_LOG"
  fi
else
  echo "[$(date -Is)] SKIP backend=rclone reason=missing_tool_or_env" | tee -a "$MATRIX_LOG"
fi

echo "BACKEND_MATRIX_SMOKE: complete"
echo "log=$MATRIX_LOG"

if [[ $hard_fail -ne 0 ]]; then
  echo "BACKEND_MATRIX_SMOKE: FAIL (required local backend failed)"
  exit 1
fi

echo "BACKEND_MATRIX_SMOKE: PASS (required local backend ok)"
