#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
OUT="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"

prompt(){
  local var="$1"; local msg="$2"; local hint="$3"; local def="${4:-}"
  echo "\n$msg"
  echo "  hint: $hint"
  read -rp "  value [${def}]: " val || true
  val="${val:-$def}"
  printf -v "$var" '%s' "$val"
}

echo "OpenSiteBackup Setup Wizard (guided)"
mkdir -p "$(dirname "$OUT")"

prompt SOURCE_SITE_SLUG "Site slug" "lowercase identifier, e.g. ayrianna" "site"
prompt LIVE_SSH_HOST "Live SSH host" "from hosting SSH panel" ""
prompt LIVE_SSH_USER "Live SSH user" "from hosting SSH panel" ""
prompt LIVE_SITE_PATH "Live WP path" "often /home/<user>/public_html" ""
prompt LIVE_SSH_KEY "SSH private key" "WSL path, e.g. ~/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519"
prompt LOCAL_RESTORE_PATH "Local restore path" "where local drill files will live" "$OSB_HOME/data/sites/$SOURCE_SITE_SLUG"
prompt LOCAL_URL "Local restore URL" "e.g. http://localhost:8080" "http://localhost:8080"
prompt LOCAL_DB_NAME "Local DB name" "local mysql db name" "wp_local"
prompt LOCAL_DB_USER "Local DB user" "local mysql user" "wp_user"
prompt LOCAL_DB_PASSWORD "Local DB password" "local mysql password" ""
prompt LOCAL_DB_HOST "Local DB host" "usually localhost" "localhost"
prompt OSB_BACKEND "Upload backend" "local|rclone|gog" "local"
prompt LOCAL_UPLOAD_ROOT "Local upload root" "for local backend copies" "$OSB_HOME/data/state/local_uploads"

cat > "$OUT" <<EOF
export OSB_HOME="$OSB_HOME"
export OSB_CONFIG="$OUT"
export SOURCE_KIND="wordpress"
export SOURCE_SITE_SLUG="$SOURCE_SITE_SLUG"

export OSB_BACKUPS="\$OSB_HOME/data/backups/\${SOURCE_SITE_SLUG}-live"
export OSB_LOGS="\$OSB_HOME/data/logs"
export OSB_TMP="\$OSB_HOME/data/tmp"
export OSB_STATE="\$OSB_HOME/data/state"

export LIVE_SSH_HOST="$LIVE_SSH_HOST"
export LIVE_SSH_USER="$LIVE_SSH_USER"
export LIVE_SSH_PORT="22"
export LIVE_SITE_PATH="$LIVE_SITE_PATH"
export LIVE_SSH_KEY="$LIVE_SSH_KEY"

export LOCAL_RESTORE_PATH="$LOCAL_RESTORE_PATH"
export LOCAL_URL="$LOCAL_URL"
export LOCAL_DB_NAME="$LOCAL_DB_NAME"
export LOCAL_DB_USER="$LOCAL_DB_USER"
export LOCAL_DB_PASSWORD="$LOCAL_DB_PASSWORD"
export LOCAL_DB_HOST="$LOCAL_DB_HOST"
export LOCAL_DB_PORT="3306"

export OSB_REWRITE_FROM_1="https://example.com"
export OSB_REWRITE_TO_1="$LOCAL_URL"

export OSB_BACKEND="$OSB_BACKEND"
export LOCAL_UPLOAD_ROOT="$LOCAL_UPLOAD_ROOT"

# gog optional
# export DRIVE_ACCOUNT="you@example.com"
# export DRIVE_ROOT_FOLDER_ID=""
# export DRIVE_DB_FOLDER_ID=""
# export DRIVE_FILES_FOLDER_ID=""
# export DRIVE_MANIFESTS_FOLDER_ID=""
# export DRIVE_LOGS_FOLDER_ID=""

export OSB_UPLOAD_RETRIES="2"
export OSB_UPLOAD_RETRY_DELAY_SEC="3"
export OSB_LOCK_TIMEOUT_SEC="600"
export OSB_LOCK_CLEAR_STALE="0"
export OSB_RESTORE_CONFIRM_REQUIRED="1"
export OSB_RC_MODE="0"
export OSB_LOG_JSON="0"

export OSB_RETENTION_DAILY="7"
export OSB_RETENTION_WEEKLY="8"
export OSB_RETENTION_MONTHLY="12"
export OSB_RETENTION_PRUNE_EMPTY="1"
EOF

chmod 600 "$OUT"
echo "\nWrote config: $OUT"

if [[ "$OSB_BACKEND" == "gog" ]]; then
  read -rp "Initialize Drive structure now (opensitebackup/db/files/manifests/logs)? [y/N]: " ans || true
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    source "$OUT"
    init_out="$(bash "$OSB_HOME/scripts/init_drive_structure.sh")"
    echo "$init_out"
    root_id="$(echo "$init_out" | sed -n 's/.*root=\([^ ]*\).*/\1/p')"
    db_id="$(echo "$init_out" | sed -n 's/.*db=\([^ ]*\).*/\1/p')"
    files_id="$(echo "$init_out" | sed -n 's/.*files=\([^ ]*\).*/\1/p')"
    man_id="$(echo "$init_out" | sed -n 's/.*manifests=\([^ ]*\).*/\1/p')"
    logs_id="$(echo "$init_out" | sed -n 's/.*logs=\([^ ]*\).*/\1/p')"
    {
      echo "export DRIVE_ROOT_FOLDER_ID=\"$root_id\""
      echo "export DRIVE_DB_FOLDER_ID=\"$db_id\""
      echo "export DRIVE_FILES_FOLDER_ID=\"$files_id\""
      echo "export DRIVE_MANIFESTS_FOLDER_ID=\"$man_id\""
      echo "export DRIVE_LOGS_FOLDER_ID=\"$logs_id\""
    } >> "$OUT"
    echo "Appended Drive folder IDs to $OUT"
  fi
fi

mkdir -p "$OSB_HOME/config/sites"
cp "$OUT" "$OSB_HOME/config/sites/${SOURCE_SITE_SLUG}.env"

source "$OUT"
bash "$OSB_HOME/scripts/preflight.sh" --strict
read -rp "Run first backup now? [y/N]: " run_now || true
if [[ "$run_now" =~ ^[Yy]$ ]]; then
  bash "$OSB_HOME/scripts/01_pull_live_backup.sh"
  bash "$OSB_HOME/scripts/02_verify_backup.sh"
fi

echo "Setup complete."
