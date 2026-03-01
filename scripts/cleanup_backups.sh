#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${SOURCE_SITE_SLUG:=site}"
: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG}-live}}"
: "${OSB_RETENTION_DAILY:=7}"
: "${OSB_RETENTION_WEEKLY:=8}"
: "${OSB_RETENTION_MONTHLY:=12}"
: "${OSB_RETENTION_PRUNE_EMPTY:=1}"

DRY_RUN=1
[[ "${1:-}" == "--apply" ]] && DRY_RUN=0

echo "cleanup target=$LOCAL_BACKUP_ROOT dry_run=$DRY_RUN"

[[ -d "$LOCAL_BACKUP_ROOT" ]] || { echo "No backup dir present"; exit 0; }

if [[ "$OSB_RETENTION_PRUNE_EMPTY" == "1" ]]; then
  while IFS= read -r -d '' d; do
    echo "PRUNE_EMPTY $d"
    [[ $DRY_RUN -eq 0 ]] && rmdir "$d" || true
  done < <(find "$LOCAL_BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -empty -print0)
fi

mapfile -t dirs < <(find "$LOCAL_BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | awk '{print $2}')
keep=$((OSB_RETENTION_DAILY + OSB_RETENTION_WEEKLY + OSB_RETENTION_MONTHLY))

if (( ${#dirs[@]} <= keep )); then
  echo "No pruning needed total=${#dirs[@]} keep=$keep"
  exit 0
fi

for ((i=keep; i<${#dirs[@]}; i++)); do
  d="${dirs[$i]}"
  echo "PRUNE_OLD $d"
  [[ $DRY_RUN -eq 0 ]] && rm -rf "$d" || true
done

echo "cleanup complete"
