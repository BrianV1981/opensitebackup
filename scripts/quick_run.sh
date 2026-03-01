#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"
# shellcheck source=/dev/null
source "$OSB_HOME/scripts/log.sh"

osb_log INFO "quick_run start"

bash "$OSB_HOME/scripts/session_prep.sh"
bash "$OSB_HOME/scripts/01_pull_live_backup.sh"
bash "$OSB_HOME/scripts/02_verify_backup.sh"
bash "$OSB_HOME/scripts/03_upload_to_drive.sh"

latest="$(ls -1dt "${LOCAL_BACKUP_ROOT:-${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG:-site}-live}}"/* | head -n1)"
files_tar="$(ls -1 "$latest"/*_files.tar.gz | head -n1)"
db_sql="$(ls -1 "$latest"/*_db.sql | head -n1)"
files_size="$(du -h "$files_tar" | awk '{print $1}')"
db_size="$(du -h "$db_sql" | awk '{print $1}')"

cat <<EOF
QUICK_RUN_SUMMARY
latest_backup_path=$latest
backend_used=${OSB_BACKEND:-local}
files_archive=$files_tar
files_size=$files_size
db_dump=$db_sql
db_size=$db_size
upload_status=success
next_step_hint=bash scripts/05_restore_from_drive.sh
EOF
