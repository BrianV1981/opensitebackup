#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

echo "OpenSiteBackup installer"
echo "home=$OSB_HOME"

need() { command -v "$1" >/dev/null 2>&1; }

missing=()
for b in bash ssh scp tar; do
  need "$b" || missing+=("$b")
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Missing required tools: ${missing[*]}"
  echo "Install them, then rerun: bash scripts/install.sh"
  exit 1
fi

mkdir -p "$OSB_HOME"/{data/backups,data/logs,data/tmp,data/state,data/sites,config/sites}

if [[ ! -f "$OSB_HOME/config/env.sh" ]]; then
  cp "$OSB_HOME/config/env.example" "$OSB_HOME/config/env.sh"
  chmod 600 "$OSB_HOME/config/env.sh"
  echo "Created config/env.sh from env.example"
else
  echo "Config already present: config/env.sh"
fi

echo "Running baseline health checks..."
bash "$OSB_HOME/scripts/check_docs_links.sh"
bash "$OSB_HOME/scripts/validate_env_matrix_ci.sh"

echo
echo "INSTALL_READY: OK"
echo "Next: bash scripts/setup_wizard.sh"
echo "Then: bash scripts/backup_now.sh"
