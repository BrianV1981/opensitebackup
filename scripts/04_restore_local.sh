#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"
: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/tbsoftwash-live}}"

LATEST="$(ls -1dt "$LOCAL_BACKUP_ROOT"/* | head -n1)"
FILES_TAR="$(ls -1 "$LATEST"/*_files.tar.gz | head -n1)"
DB_SQL="$(ls -1 "$LATEST"/*_db.sql | head -n1)"

echo "About to restore into: $LOCAL_RESTORE_PATH"
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || exit 1

mkdir -p "$LOCAL_RESTORE_PATH"
find "$LOCAL_RESTORE_PATH" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

tar -xzf "$FILES_TAR" -C "$LOCAL_RESTORE_PATH"

cd "$LOCAL_RESTORE_PATH"
wp db import "$DB_SQL"
wp search-replace 'https://tbsoftwash.com' "$LOCAL_URL" --skip-columns=guid || true
wp cache flush || true

echo "Restore complete."
