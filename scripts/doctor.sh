#!/usr/bin/env bash
set -euo pipefail

# Non-destructive health diagnostics for operators.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

echo "[doctor 1/6] preflight"
bash "$OSB_HOME/scripts/preflight.sh" --strict

echo "[doctor 2/6] env matrix"
bash "$OSB_HOME/scripts/validate_env_matrix_ci.sh"

echo "[doctor 3/6] docs links"
bash "$OSB_HOME/scripts/check_docs_links.sh"

echo "[doctor 4/6] status snapshot"
bash "$OSB_HOME/scripts/status_snapshot.sh"

echo "[doctor 5/6] verify latest backup presence"
if ! bash "$OSB_HOME/scripts/02_verify_backup.sh" >/tmp/osb-doctor-verify.log 2>&1; then
  echo "DOCTOR_WARN verify stage failed (likely no backup yet)"
  tail -n 5 /tmp/osb-doctor-verify.log || true
else
  echo "DOCTOR_OK verify stage"
fi

echo "[doctor 6/6] backend matrix smoke"
OSB_MATRIX_INCLUDE_OPTIONAL_BACKENDS="${OSB_MATRIX_INCLUDE_OPTIONAL_BACKENDS:-0}" bash "$OSB_HOME/scripts/backend_matrix_smoke.sh"

echo "DOCTOR: OK"
