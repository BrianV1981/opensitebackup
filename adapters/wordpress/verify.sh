#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"
: "${SOURCE_SITE_SLUG:=site}"
: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG}-live}}"

if [[ ! -d "$LOCAL_BACKUP_ROOT" ]]; then
  echo "No backup directory found: $LOCAL_BACKUP_ROOT"
  echo "Run: bash scripts/01_pull_live_backup.sh"
  exit 64
fi

LATEST="$(find "$LOCAL_BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | awk 'NR==1{print $2}')"
if [[ -z "$LATEST" ]]; then
  echo "No backups found in: $LOCAL_BACKUP_ROOT"
  echo "Run: bash scripts/01_pull_live_backup.sh"
  exit 64
fi

FILES_TAR="$(ls -1 "$LATEST"/*_files.tar.gz 2>/dev/null | head -n1 || true)"
DB_SQL="$(ls -1 "$LATEST"/*_db.sql 2>/dev/null | head -n1 || true)"

if [[ -z "$FILES_TAR" || -z "$DB_SQL" ]]; then
  echo "Backup artifacts incomplete in: $LATEST"
  echo "Expected *_files.tar.gz and *_db.sql"
  exit 65
fi

sha256sum "$FILES_TAR" "$DB_SQL" | tee "$LATEST/local_sha256.txt"
tar -tzf "$FILES_TAR" >/dev/null
grep -m1 '^CREATE TABLE' "$DB_SQL" >/dev/null
grep -m1 '^INSERT INTO' "$DB_SQL" >/dev/null

{
  echo "timestamp=$(date -Is)"
  echo "backup_dir=$LATEST"
  echo "files_tar=$FILES_TAR"
  echo "db_sql=$DB_SQL"
  echo "files_size=$(du -h "$FILES_TAR" | awk '{print $1}')"
  echo "db_size=$(du -h "$DB_SQL" | awk '{print $1}')"
  echo "tar_entries=$(tar -tzf "$FILES_TAR" | wc -l)"
} | tee "$LATEST/manifest.txt"

echo "Integrity check passed: $LATEST"
