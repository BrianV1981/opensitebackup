#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${LIVE_SSH_HOST:?LIVE_SSH_HOST is required}"
: "${LIVE_SSH_USER:?LIVE_SSH_USER is required}"
: "${LIVE_SSH_KEY:?LIVE_SSH_KEY is required}"
: "${LIVE_SSH_PORT:=22}"

echo "SSH_TROUBLESHOOT"
echo "host=$LIVE_SSH_HOST user=$LIVE_SSH_USER port=$LIVE_SSH_PORT key=$LIVE_SSH_KEY"

if [[ ! -f "$LIVE_SSH_KEY" ]]; then
  echo "ERROR: key file missing: $LIVE_SSH_KEY"
  exit 1
fi

echo "-- key permissions --"
ls -l "$LIVE_SSH_KEY" || true

echo "-- ssh key fingerprint --"
ssh-keygen -lf "$LIVE_SSH_KEY" || true

echo "-- ssh auth debug probe --"
ssh -vvv -o IdentitiesOnly=yes -o PreferredAuthentications=publickey -o BatchMode=yes -o ConnectTimeout=10 \
  -p "$LIVE_SSH_PORT" -i "$LIVE_SSH_KEY" "$LIVE_SSH_USER@$LIVE_SSH_HOST" "echo OSB_SSH_OK" 2>&1 | tail -n 60 || true

echo "-- recommended fixes --"
echo "chmod 700 ~/.ssh"
echo "chmod 600 $LIVE_SSH_KEY"
echo "ssh-add $LIVE_SSH_KEY"
echo "ssh -p $LIVE_SSH_PORT -i $LIVE_SSH_KEY $LIVE_SSH_USER@$LIVE_SSH_HOST"
