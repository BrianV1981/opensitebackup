#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

ctx="${1:-}"
backend_override="${2:-${OSB_BACKEND:-local}}"

missing=0
need_var() {
  local n="$1"
  if [[ -z "${!n:-}" ]]; then
    echo "MISSING ENV: $n"
    missing=1
  fi
}

case "$ctx" in
  backup)
    need_var LIVE_SSH_HOST
    need_var LIVE_SSH_USER
    need_var LIVE_SITE_PATH
    need_var LIVE_SSH_KEY
    ;;
  verify)
    if [[ -z "${LOCAL_BACKUP_ROOT:-}" && -z "${OSB_BACKUPS:-}" ]]; then
      echo "MISSING ENV: LOCAL_BACKUP_ROOT (or OSB_BACKUPS)"
      missing=1
    fi
    ;;
  upload)
    case "$backend_override" in
      local)
        : # optional LOCAL_UPLOAD_ROOT
        ;;
      rclone)
        need_var RCLONE_REMOTE
        ;;
      gog)
        need_var DRIVE_ACCOUNT
        need_var DRIVE_DB_FOLDER_ID
        need_var DRIVE_FILES_FOLDER_ID
        need_var DRIVE_MANIFESTS_FOLDER_ID
        ;;
      *)
        echo "MISSING ENV: OSB_BACKEND valid value required (local|rclone|gog)"
        missing=1
        ;;
    esac
    ;;
  restore-local)
    need_var LOCAL_RESTORE_PATH
    need_var LOCAL_URL
    need_var LOCAL_DB_NAME
    need_var LOCAL_DB_USER
    need_var LOCAL_DB_PASSWORD
    ;;
  restore-drive)
    need_var LOCAL_RESTORE_PATH
    need_var LOCAL_URL
    need_var LOCAL_DB_NAME
    need_var LOCAL_DB_USER
    need_var LOCAL_DB_PASSWORD
    need_var DRIVE_ACCOUNT
    need_var DRIVE_DB_FILE_ID
    need_var DRIVE_FILES_FILE_ID
    ;;
  demo)
    "$SCRIPT_DIR/validate_env.sh" restore-drive
    ;;
  release)
    "$SCRIPT_DIR/validate_env.sh" upload "$backend_override"
    ;;
  *)
    echo "Usage: bash scripts/validate_env.sh <backup|verify|upload|restore-local|restore-drive|demo|release> [backend]"
    exit 2
    ;;
esac

if [[ $missing -ne 0 ]]; then
  exit 1
fi

echo "ENV_VALIDATE_OK context=$ctx"
