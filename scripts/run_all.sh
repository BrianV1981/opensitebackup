#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

echo "[run_all 1/4] Strict preflight"
bash "$OSB_HOME/scripts/preflight.sh" --strict

echo "[run_all 2/4] Pull live backup"
bash "$OSB_HOME/scripts/01_pull_live_backup.sh"

echo "[run_all 3/4] Verify backup artifacts"
bash "$OSB_HOME/scripts/02_verify_backup.sh"

echo "[run_all 4/4] Upload with backend=${OSB_BACKEND:-gog}"
bash "$OSB_HOME/scripts/03_upload_to_drive.sh"

echo "RUN_ALL: OK"
