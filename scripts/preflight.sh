#!/usr/bin/env bash
set -euo pipefail

usage(){
  cat <<USAGE
Usage: bash scripts/preflight.sh [--strict]
Checks required tools, config presence, and backend-specific requirements.
USAGE
}

STRICT=0
[[ "${1:-}" == "--help" ]] && { usage; exit 0; }
[[ "${1:-}" == "--strict" ]] && STRICT=1

OSB_HOME="${OSB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
# shellcheck source=/dev/null
source "$OSB_HOME/scripts/log.sh"

osb_log INFO "preflight start" "osb_home=$OSB_HOME" "env_file=$ENV_FILE"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "MISSING: $1"; return 1; }; }
require_env(){
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "MISSING ENV: $name"
    return 1
  fi
}

fail=0
for bin in bash ssh scp tar wp; do
  need "$bin" || fail=1
done

if [[ -f "$ENV_FILE" ]]; then
  echo "ENV: present"
  # shellcheck source=/dev/null
  source "$ENV_FILE"
else
  echo "ENV: missing (copy config/env.example -> config/env.sh)"
  fail=1
fi

if [[ -n "${LIVE_SSH_KEY:-}" && ! -f "${LIVE_SSH_KEY}" ]]; then
  echo "MISSING FILE: LIVE_SSH_KEY=$LIVE_SSH_KEY"
  fail=1
fi

backend="${OSB_BACKEND:-local}"
echo "BACKEND=$backend"
if ! bash "$OSB_HOME/scripts/validate_env.sh" upload "$backend" >/dev/null 2>&1; then
  bash "$OSB_HOME/scripts/validate_env.sh" upload "$backend" || fail=1
fi
case "$backend" in
  gog)
    need gog || fail=1
    ;;
  local)
    ;;
  rclone)
    need rclone || fail=1
    ;;
  *)
    echo "INVALID ENV: OSB_BACKEND must be one of gog|local|rclone"
    fail=1
    ;;
esac

# Optional drive-restore env check (warn-only unless strict)
if [[ -n "${DRIVE_DB_FILE_ID:-}" || -n "${DRIVE_FILES_FILE_ID:-}" ]]; then
  for v in DRIVE_ACCOUNT DRIVE_DB_FILE_ID DRIVE_FILES_FILE_ID LOCAL_DB_NAME LOCAL_DB_USER LOCAL_DB_PASSWORD LOCAL_URL; do
    if [[ -z "${!v:-}" ]]; then
      echo "WARN: missing env for drive restore path: $v"
      [[ $STRICT -eq 1 ]] && fail=1
    fi
  done
fi

if [[ $STRICT -eq 1 && $fail -ne 0 ]]; then
  exit 1
fi

if [[ $fail -eq 0 ]]; then
  osb_log INFO "Preflight OK"
else
  osb_log WARN "Preflight warnings/errors present"
fi
