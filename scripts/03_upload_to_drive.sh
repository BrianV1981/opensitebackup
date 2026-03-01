#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

BACKEND="${OSB_BACKEND:-gog}"
BACKEND_SCRIPT="$OSB_HOME/backends/${BACKEND}/upload.sh"

if [[ ! -f "$BACKEND_SCRIPT" ]]; then
  echo "Unknown backend: $BACKEND (expected: local|gog|rclone)" >&2
  exit 60
fi

if [[ ! -x "$BACKEND_SCRIPT" ]]; then
  echo "Backend script is not executable: $BACKEND_SCRIPT" >&2
  exit 60
fi

exec "$BACKEND_SCRIPT"
