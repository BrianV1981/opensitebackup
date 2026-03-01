#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

backup_root="${LOCAL_BACKUP_ROOT:-${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG:-site}-live}}"
latest_backup="$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR==1{print $2}')"

files_size="n/a"
db_size="n/a"
if [[ -n "$latest_backup" ]]; then
  files_tar="$(ls -1 "$latest_backup"/*_files.tar.gz 2>/dev/null | head -n1 || true)"
  db_sql="$(ls -1 "$latest_backup"/*_db.sql 2>/dev/null | head -n1 || true)"
  [[ -n "$files_tar" ]] && files_size="$(du -h "$files_tar" | awk '{print $1}')"
  [[ -n "$db_sql" ]] && db_size="$(du -h "$db_sql" | awk '{print $1}')"
fi

cat <<EOF
OSB_STATUS_SNAPSHOT
branch=$(git -C "$OSB_HOME" rev-parse --abbrev-ref HEAD)
commit=$(git -C "$OSB_HOME" rev-parse --short HEAD)
site_slug=${SOURCE_SITE_SLUG:-site}
backend=${OSB_BACKEND:-local}
backup_root=$backup_root
latest_backup=${latest_backup:-none}
latest_files_size=$files_size
latest_db_size=$db_size
release_report=$([[ -f "${OSB_STATE:-$OSB_HOME/data/state}/release_readiness_report.md" ]] && echo present || echo missing)
launch_packet=$([[ -f "${OSB_STATE:-$OSB_HOME/data/state}/launch_go_no_go_packet.md" ]] && echo present || echo missing)
EOF
