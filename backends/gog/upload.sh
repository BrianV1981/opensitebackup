#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"
: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/tbsoftwash-live}}"

LATEST="$(ls -1dt "$LOCAL_BACKUP_ROOT"/* | head -n1)"
FILES_TAR="$(ls -1 "$LATEST"/*_files.tar.gz | head -n1)"
DB_SQL="$(ls -1 "$LATEST"/*_db.sql | head -n1)"
MANIFEST="$LATEST/manifest.txt"
LOCALSUMS="$LATEST/local_sha256.txt"

[[ -f "$MANIFEST" ]] || { echo "Run 02_verify_backup.sh first"; exit 1; }

upload_with_log() {
  local file="$1"
  local parent="$2"
  local label="$3"
  local size
  size=$(du -h "$file" | awk '{print $1}')
  local start end dur
  start=$(date +%s)
  echo "[$(date -Is)] START upload: $label | $(basename "$file") | size=$size"
  gog drive upload "$file" --account "$DRIVE_ACCOUNT" --parent "$parent" --no-input
  end=$(date +%s)
  dur=$((end-start))
  echo "[$(date -Is)] DONE  upload: $label | duration=${dur}s"
}

upload_with_log "$DB_SQL" "$DRIVE_DB_FOLDER_ID" "database"
upload_with_log "$FILES_TAR" "$DRIVE_FILES_FOLDER_ID" "files-archive"
upload_with_log "$MANIFEST" "$DRIVE_MANIFESTS_FOLDER_ID" "manifest"
upload_with_log "$LOCALSUMS" "$DRIVE_MANIFESTS_FOLDER_ID" "checksums"

echo "Uploaded latest backup set to Google Drive."
