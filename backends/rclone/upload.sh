#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"
: "${SOURCE_SITE_SLUG:=site}"
: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG}-live}}"

: "${RCLONE_REMOTE:?RCLONE_REMOTE is required (example: myremote:Backups/WordPress/<site-slug>)}"
RCLONE_FLAGS="${RCLONE_FLAGS:---progress}"

LATEST="$(ls -1dt "$LOCAL_BACKUP_ROOT"/* | head -n1)"
FILES_TAR="$(ls -1 "$LATEST"/*_files.tar.gz | head -n1)"
DB_SQL="$(ls -1 "$LATEST"/*_db.sql | head -n1)"
MANIFEST="$LATEST/manifest.txt"
LOCALSUMS="$LATEST/local_sha256.txt"

[[ -f "$MANIFEST" ]] || { echo "Run 02_verify_backup.sh first"; exit 1; }

retry_upload() {
  local tries="${OSB_UPLOAD_RETRIES:-2}"
  local delay="${OSB_UPLOAD_RETRY_DELAY_SEC:-3}"
  local n=1
  while true; do
    if "$@"; then
      return 0
    fi
    if (( n >= tries )); then
      return 1
    fi
    echo "[$(date -Is)] WARN upload failed attempt=${n}/${tries}; retrying in ${delay}s"
    sleep "$delay"
    n=$((n+1))
  done
}

upload_with_log() {
  local file="$1"
  local subdir="$2"
  local label="$3"
  local size start end dur
  size=$(du -h "$file" | awk '{print $1}')
  start=$(date +%s)
  echo "[$(date -Is)] START upload: $label | $(basename "$file") | size=$size"
  retry_upload rclone copy "$file" "${RCLONE_REMOTE}/${subdir}" $RCLONE_FLAGS
  end=$(date +%s)
  dur=$((end-start))
  echo "[$(date -Is)] DONE  upload: $label | duration=${dur}s"
}

upload_with_log "$DB_SQL" "db" "database"
upload_with_log "$FILES_TAR" "files" "files-archive"
upload_with_log "$MANIFEST" "manifests" "manifest"
upload_with_log "$LOCALSUMS" "manifests" "checksums"

echo "UPLOAD_VERIFY_SUMMARY backend=rclone files=4 status=pass (copy returned success)"
echo "Uploaded latest backup set via rclone to $RCLONE_REMOTE"
