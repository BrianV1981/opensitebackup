#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
OUT="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"

prompt(){
  local var="$1"; local msg="$2"; local def="${3:-}"
  read -rp "$msg [${def}]: " val || true
  val="${val:-$def}"
  printf -v "$var" '%s' "$val"
}

echo "OpenSiteBackup Setup Wizard"
mkdir -p "$(dirname "$OUT")"

prompt SOURCE_SITE_SLUG "Site slug (lowercase)" "site"
prompt LIVE_SSH_HOST "Live SSH host" ""
prompt LIVE_SSH_USER "Live SSH user" ""
prompt LIVE_SITE_PATH "Live site path" ""
prompt LIVE_SSH_KEY "SSH private key path" "$HOME/.ssh/id_ed25519"
prompt LOCAL_RESTORE_PATH "Local restore path" "$OSB_HOME/data/sites/$SOURCE_SITE_SLUG"
prompt LOCAL_URL "Local restore URL" "http://localhost:8080"
prompt LOCAL_DB_NAME "Local DB name" "wp_local"
prompt LOCAL_DB_USER "Local DB user" "wp_user"
prompt LOCAL_DB_PASSWORD "Local DB password" ""
prompt LOCAL_DB_HOST "Local DB host" "localhost"
prompt OSB_BACKEND "Backend (local|rclone|gog)" "local"
prompt LOCAL_UPLOAD_ROOT "Local upload root" "$OSB_HOME/data/state/local_uploads"

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

export OSB_UPLOAD_RETRIES="2"
export OSB_UPLOAD_RETRY_DELAY_SEC="3"
export OSB_RESTORE_CONFIRM_REQUIRED="1"
export OSB_RETENTION_DAILY="7"
export OSB_RETENTION_WEEKLY="8"
export OSB_RETENTION_MONTHLY="12"
export OSB_RETENTION_PRUNE_EMPTY="1"
EOF

chmod 600 "$OUT"
echo "Wrote config: $OUT"

echo "Next: bash scripts/validate_env.sh backup && bash scripts/preflight.sh --strict"
