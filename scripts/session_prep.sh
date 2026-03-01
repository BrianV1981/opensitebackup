#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"

if [[ "${1:-}" == "--profile" ]]; then
  slug="${2:-}"
  [[ -n "$slug" ]] || { echo "Usage: bash scripts/session_prep.sh [--profile <slug>]"; exit 2; }
  bash "$OSB_HOME/scripts/use_site_profile.sh" "$slug"
  shift 2
fi

ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"
# shellcheck source=/dev/null
source "$OSB_HOME/scripts/log.sh"

: "${LIVE_SSH_HOST:?LIVE_SSH_HOST is required}"
: "${LIVE_SSH_USER:?LIVE_SSH_USER is required}"
: "${LIVE_SSH_KEY:?LIVE_SSH_KEY is required}"
: "${LIVE_SSH_PORT:=22}"

osb_log INFO "session_prep start"

if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
  eval "$(ssh-agent -s)" >/dev/null
  osb_log INFO "ssh-agent started"
fi

if ! ssh-add -l >/dev/null 2>&1; then
  if ssh-add "$LIVE_SSH_KEY" >/dev/null 2>&1; then
    osb_log INFO "ssh key added" "key=$LIVE_SSH_KEY"
  else
    osb_log WARN "ssh-add skipped/failed (likely passphrase-protected key in non-interactive shell)"
  fi
fi

if [[ "${OSB_SESSION_PREP_SKIP_SSH_TEST:-0}" == "1" ]]; then
  osb_log WARN "ssh test skipped by OSB_SESSION_PREP_SKIP_SSH_TEST=1"
else
  if ssh -o IdentitiesOnly=yes -o PreferredAuthentications=publickey -o BatchMode=yes -o ConnectTimeout=10 \
    -p "$LIVE_SSH_PORT" -i "$LIVE_SSH_KEY" "$LIVE_SSH_USER@$LIVE_SSH_HOST" "echo OSB_SSH_OK" >/dev/null; then
    osb_log INFO "ssh test passed"
  else
    osb_log WARN "ssh non-interactive test failed (run interactive ssh manually or set OSB_SESSION_PREP_SKIP_SSH_TEST=1)"
  fi
fi

backend="${OSB_BACKEND:-local}"
case "$backend" in
  gog)
    : "${DRIVE_ACCOUNT:?DRIVE_ACCOUNT is required}"
    gog drive ls --account "$DRIVE_ACCOUNT" --no-input >/dev/null
    osb_log INFO "gog auth warmup ok"
    ;;
  rclone)
    : "${RCLONE_REMOTE:?RCLONE_REMOTE is required}"
    rclone lsd "$RCLONE_REMOTE" >/dev/null
    osb_log INFO "rclone remote warmup ok" "remote=$RCLONE_REMOTE"
    ;;
  local)
    osb_log INFO "local backend selected"
    ;;
esac

bash "$OSB_HOME/scripts/preflight.sh" --strict
osb_log INFO "SESSION_READY" "backend=$backend" "ssh=$LIVE_SSH_USER@$LIVE_SSH_HOST:$LIVE_SSH_PORT"
