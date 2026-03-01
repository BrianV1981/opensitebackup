#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"
: "${SOURCE_SITE_SLUG:=site}"
: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG}-live}}"

LOCAL_UPLOAD_ROOT="${LOCAL_UPLOAD_ROOT:-${OSB_STATE:-$OSB_HOME/data/state}/local_uploads}"
mkdir -p "$LOCAL_UPLOAD_ROOT"

LATEST="$(ls -1dt "$LOCAL_BACKUP_ROOT"/* | head -n1)"
DEST="$LOCAL_UPLOAD_ROOT/$(basename "$LATEST")"
mkdir -p "$DEST"

cp -av "$LATEST"/* "$DEST/"
echo "Local backend upload complete: $DEST"
