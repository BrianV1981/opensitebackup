#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
bash "$OSB_HOME/scripts/validate_env.sh" restore-local
exec bash "$OSB_HOME/scripts/with_lock.sh" restore "$OSB_HOME/adapters/wordpress/restore.sh" local
