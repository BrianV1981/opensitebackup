#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   source scripts/log.sh
#   osb_log INFO "message" key=value ...

: "${OSB_RUN_ID:=${OSB_RUN_ID:-$(date +%Y%m%d%H%M%S)-$$}}"

osb_log() {
  local level="$1"; shift
  local msg="$1"; shift || true
  local ts
  ts="$(date -Is)"

  if [[ "${OSB_LOG_JSON:-0}" == "1" ]]; then
    local extra=""
    local kv
    for kv in "$@"; do
      key="${kv%%=*}"
      val="${kv#*=}"
      extra+="\"${key//\"/}\":\"${val//\"/}\"," 
    done
    extra="${extra%, }"
    [[ -n "$extra" ]] && extra=",$extra"
    echo "{\"ts\":\"$ts\",\"level\":\"$level\",\"run_id\":\"$OSB_RUN_ID\",\"msg\":\"${msg//\"/}\"$extra}"
  else
    echo "[$ts] [$level] [run_id=$OSB_RUN_ID] $msg ${*:-}"
  fi
}
