#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# CI-only matrix to ensure validate_env contexts remain healthy.
# Uses ephemeral env values; no network/destructive actions.

export OSB_HOME
export SOURCE_SITE_SLUG="ci-site"
export OSB_BACKUPS="$OSB_HOME/data/backups/ci-site-live"
export LOCAL_BACKUP_ROOT="$OSB_BACKUPS"
export LIVE_SSH_HOST="example.com"
export LIVE_SSH_USER="ciuser"
export LIVE_SITE_PATH="/home/ciuser/public_html"
export LIVE_SSH_KEY="$HOME/.ssh/id_ed25519"
export LOCAL_RESTORE_PATH="$OSB_HOME/data/sites/ci-site"
export LOCAL_URL="http://localhost:8080"
export LOCAL_DB_NAME="ci_db"
export LOCAL_DB_USER="ci_user"
export LOCAL_DB_PASSWORD="ci_pass"
export LOCAL_DB_HOST="localhost"
export DRIVE_ACCOUNT="ci@example.com"
export DRIVE_DB_FOLDER_ID="db-folder-id"
export DRIVE_FILES_FOLDER_ID="files-folder-id"
export DRIVE_MANIFESTS_FOLDER_ID="man-folder-id"
export DRIVE_DB_FILE_ID="db-file-id"
export DRIVE_FILES_FILE_ID="files-file-id"
export RCLONE_REMOTE="ci-remote:opensitebackup"

bash "$OSB_HOME/scripts/validate_env.sh" backup
bash "$OSB_HOME/scripts/validate_env.sh" verify
bash "$OSB_HOME/scripts/validate_env.sh" upload local
bash "$OSB_HOME/scripts/validate_env.sh" upload gog
bash "$OSB_HOME/scripts/validate_env.sh" upload rclone
bash "$OSB_HOME/scripts/validate_env.sh" restore-local
bash "$OSB_HOME/scripts/validate_env.sh" restore-drive
bash "$OSB_HOME/scripts/validate_env.sh" demo
bash "$OSB_HOME/scripts/validate_env.sh" release

echo "VALIDATE_ENV_MATRIX_CI: OK"
