#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

cd "$OSB_HOME"

echo "[1/5] Shell syntax checks"
bash -n scripts/*.sh adapters/wordpress/*.sh backends/*/upload.sh

echo "[2/5] Strict preflight"
bash scripts/preflight.sh --strict

echo "[3/5] Verify latest backup artifacts"
bash scripts/02_verify_backup.sh

echo "[4/5] Local backend upload smoke"
OSB_BACKEND=local bash scripts/03_upload_to_drive.sh

echo "[5/5] Optional restore drill"
if [[ "${OSB_RC_MODE:-0}" == "1" && "${RUN_RESTORE_DRILL:-0}" != "1" ]]; then
  echo "RC_MODE requires restore drill. Set RUN_RESTORE_DRILL=1"
  exit 1
fi

if [[ "${RUN_RESTORE_DRILL:-0}" == "1" ]]; then
  echo "RUN_RESTORE_DRILL=1 -> executing drive restore drill"
  OSB_RESTORE_CONFIRM_REQUIRED=0 bash scripts/05_restore_from_drive.sh
else
  echo "Skipping restore drill (set RUN_RESTORE_DRILL=1 to include)"
fi

echo "PRE_RELEASE_CHECK: OK"
