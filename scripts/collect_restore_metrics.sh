#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${LOCAL_RESTORE_PATH:?LOCAL_RESTORE_PATH is required}"
: "${RESTORE_SOURCE_TYPE:=unknown}"
: "${RESTORE_SUCCESS:=true}"
: "${RESTORE_ERROR:=}"

METRICS_FILE="${OSB_STATE:-$OSB_HOME/data/state}/restore_metrics.jsonl"
mkdir -p "$(dirname "$METRICS_FILE")"

latest_backup=""
files_tar=""
db_sql=""
files_size_bytes=0
db_size_bytes=0
backup_root="${LOCAL_BACKUP_ROOT:-${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG:-site}-live}}"
if [[ -d "$backup_root" ]]; then
  latest_backup="$(ls -1dt "$backup_root"/* 2>/dev/null | head -n1 || true)"
fi

if [[ -n "$latest_backup" ]]; then
  files_tar="$(ls -1 "$latest_backup"/*_files.tar.gz 2>/dev/null | head -n1 || true)"
  db_sql="$(ls -1 "$latest_backup"/*_db.sql 2>/dev/null | head -n1 || true)"
fi

if [[ -n "$files_tar" && -f "$files_tar" ]]; then
  files_size_bytes=$(stat -c %s "$files_tar")
fi
if [[ -n "$db_sql" && -f "$db_sql" ]]; then
  db_size_bytes=$(stat -c %s "$db_sql")
fi

siteurl=""
blogname=""
pages="0"
theme=""
if [[ -d "$LOCAL_RESTORE_PATH" ]]; then
  cd "$LOCAL_RESTORE_PATH"
  WP_SAFE=(wp --skip-plugins --skip-themes)
  siteurl="$(${WP_SAFE[@]} option get siteurl 2>/dev/null || echo "")"
  blogname="$(${WP_SAFE[@]} option get blogname 2>/dev/null || echo "")"
  pages="$(${WP_SAFE[@]} post list --post_type=page --format=count 2>/dev/null || echo "0")"
  theme="$(${WP_SAFE[@]} option get template 2>/dev/null || echo "")"
fi

[[ "$pages" =~ ^[0-9]+$ ]] || pages=0
restore_duration_sec="${RESTORE_DURATION_SEC:-0}"
backup_duration_sec="${BACKUP_DURATION_SEC:-0}"
[[ "$restore_duration_sec" =~ ^[0-9]+$ ]] || restore_duration_sec=0
[[ "$backup_duration_sec" =~ ^[0-9]+$ ]] || backup_duration_sec=0

python3 - <<PY >> "$METRICS_FILE"
import json, datetime
row = {
  "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
  "backup_source_type": ${RESTORE_SOURCE_TYPE@Q},
  "files_archive_size_bytes": int(${files_size_bytes}),
  "db_size_bytes": int(${db_size_bytes}),
  "backup_duration_sec": int(${backup_duration_sec}),
  "restore_duration_sec": int(${restore_duration_sec}),
  "page_count": int(${pages}),
  "theme_slug": ${theme@Q},
  "siteurl": ${siteurl@Q},
  "blogname": ${blogname@Q},
  "success": ${RESTORE_SUCCESS@Q}.lower() == "true",
  "error_reason": ${RESTORE_ERROR@Q}
}
print(json.dumps(row, ensure_ascii=False))
PY

echo "Metrics appended: $METRICS_FILE"
