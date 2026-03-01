#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/use_site_profile.sh <slug>
# Loads config/sites/<slug>.env by copying to config/env.sh (with backup).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SITES_DIR="$OSB_HOME/config/sites"
TARGET_ENV="$OSB_HOME/config/env.sh"
slug="${1:-}"

[[ -n "$slug" ]] || { echo "Usage: bash scripts/use_site_profile.sh <slug>"; exit 2; }
PROFILE="$SITES_DIR/${slug}.env"
[[ -f "$PROFILE" ]] || { echo "Profile not found: $PROFILE"; exit 1; }

mkdir -p "$SITES_DIR"
if [[ -f "$TARGET_ENV" ]]; then
  ts="$(date +%Y%m%d_%H%M%S)"
  cp "$TARGET_ENV" "$OSB_HOME/config/env.backup.${ts}.sh"
fi

cp "$PROFILE" "$TARGET_ENV"
chmod 600 "$TARGET_ENV"

echo "PROFILE_SELECTED slug=$slug env=$TARGET_ENV"
