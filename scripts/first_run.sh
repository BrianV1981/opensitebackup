#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

USE_DEFAULTS=1
RUN_BACKUP=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --guided)
      USE_DEFAULTS=0; shift ;;
    --run-backup)
      RUN_BACKUP=1; shift ;;
    --help|-h)
      cat <<EOF
Usage: bash scripts/first_run.sh [--guided] [--run-backup]

Default behavior:
  - runs installer
  - generates baseline config via setup wizard defaults
  - runs strict preflight

Options:
  --guided      Use interactive setup wizard prompts
  --run-backup  Run backup_now after preflight
EOF
      exit 0 ;;
    *)
      echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

echo "[1/4] install"
bash "$OSB_HOME/scripts/install.sh"

echo "[2/4] setup"
if [[ "$USE_DEFAULTS" == "1" ]]; then
  OSB_WIZARD_USE_DEFAULTS=1 bash "$OSB_HOME/scripts/setup_wizard.sh"
else
  bash "$OSB_HOME/scripts/setup_wizard.sh"
fi

echo "[3/4] preflight"
bash "$OSB_HOME/scripts/preflight.sh" --strict

echo "[4/4] finish"
if [[ "$RUN_BACKUP" == "1" ]]; then
  bash "$OSB_HOME/scripts/backup_now.sh"
fi

echo "FIRST_RUN: OK"
