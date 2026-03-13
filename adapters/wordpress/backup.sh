#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"
: "${SOURCE_SITE_SLUG:=site}"
: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG}-live}}"

TS="$(date +%Y%m%d_%H%M%S)"
RUN_DIR="$LOCAL_BACKUP_ROOT/$TS"
mkdir -p "$RUN_DIR"

REMOTE_CREATED=0

cleanup_on_error() {
  local code=$?
  trap - EXIT
  if [[ $code -ne 0 ]]; then
    if [[ "$REMOTE_CREATED" -eq 1 && -n "${SSH_OPTS:-}" && -n "${REMOTE_FILES:-}" ]]; then
      echo "[$(date -Is)] Cleanup: attempting remote temp cleanup after failure ..."
      ssh $SSH_OPTS "${LIVE_SSH_USER}@${LIVE_SSH_HOST}" "rm -f '${REMOTE_FILES}' '${REMOTE_DB}' '${REMOTE_SUMS}'" >/dev/null 2>&1 || true
    fi

    if [[ -d "$RUN_DIR" ]] && [[ -z "$(find "$RUN_DIR" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
      rmdir "$RUN_DIR" 2>/dev/null || true
      echo "[$(date -Is)] Cleanup: removed empty failed run dir $RUN_DIR"
    fi
  fi
  exit $code
}
trap cleanup_on_error EXIT

SSH_OPTS="-o IdentitiesOnly=yes -o PreferredAuthentications=publickey"
if [[ -n "${LIVE_SSH_KEY:-}" ]]; then
  SSH_OPTS="-i $LIVE_SSH_KEY $SSH_OPTS"
fi

REMOTE_PREFIX="${SOURCE_SITE_SLUG}_live_${TS}"
REMOTE_FILES="/home/${LIVE_SSH_USER}/${REMOTE_PREFIX}_files.tar.gz"
REMOTE_DB="/home/${LIVE_SSH_USER}/${REMOTE_PREFIX}_db.sql"
REMOTE_SUMS="/home/${LIVE_SSH_USER}/${REMOTE_PREFIX}_sha256.txt"

echo "[$(date -Is)] [1/5] Creating remote archives on ${LIVE_SSH_HOST} ..."
REMOTE_CREATED=1
ssh $SSH_OPTS "${LIVE_SSH_USER}@${LIVE_SSH_HOST}" bash <<EOF
set -e
cd "${LIVE_SITE_PATH}"
if [[ ! -f wp-config.php ]]; then
  echo "ERROR: wp-config.php not found in ${LIVE_SITE_PATH}" >&2
  exit 1
fi

echo "remote: archiving files ..."
tar --ignore-failed-read \
  --warning=no-file-changed \
  --exclude='./wp-content/uploads/wpforms/.htaccess*' \
  -czf "${REMOTE_FILES}" .

echo "remote: exporting database ..."
if command -v wp >/dev/null 2>&1; then
  wp db export "${REMOTE_DB}" --path="${LIVE_SITE_PATH}"
else
  echo "ERROR: wp-cli not found on live host. Install WP-CLI or run mysqldump manually." >&2
  exit 1
fi

echo "remote: checksums ..."
sha256sum "${REMOTE_FILES}" "${REMOTE_DB}" > "${REMOTE_SUMS}"
ls -lh "${REMOTE_FILES}" "${REMOTE_DB}" "${REMOTE_SUMS}"
EOF

echo "[$(date -Is)] [2/5] Downloading files archive ..."
scp $SSH_OPTS "${LIVE_SSH_USER}@${LIVE_SSH_HOST}:${REMOTE_FILES}" "$RUN_DIR/"
echo "[$(date -Is)] [3/5] Downloading database dump ..."
scp $SSH_OPTS "${LIVE_SSH_USER}@${LIVE_SSH_HOST}:${REMOTE_DB}" "$RUN_DIR/"
echo "[$(date -Is)] [4/5] Downloading checksum manifest ..."
scp $SSH_OPTS "${LIVE_SSH_USER}@${LIVE_SSH_HOST}:${REMOTE_SUMS}" "$RUN_DIR/"

echo "[$(date -Is)] [5/5] Cleaning remote temp files ..."
ssh $SSH_OPTS "${LIVE_SSH_USER}@${LIVE_SSH_HOST}" "rm -f '${REMOTE_FILES}' '${REMOTE_DB}' '${REMOTE_SUMS}'"

trap - EXIT
echo "Pulled backup into: $RUN_DIR"
