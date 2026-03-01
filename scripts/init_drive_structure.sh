#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${DRIVE_ACCOUNT:?DRIVE_ACCOUNT is required}"
ROOT_NAME="opensitebackup"

mkfolder() {
  local name="$1" parent="${2:-}"
  if [[ -n "$parent" ]]; then
    gog drive mkdir "$name" --account "$DRIVE_ACCOUNT" --parent "$parent" --json --results-only --no-input
  else
    gog drive mkdir "$name" --account "$DRIVE_ACCOUNT" --json --results-only --no-input
  fi
}

root_json="$(mkfolder "$ROOT_NAME")"
root_id="$(python3 - <<'PY' "$root_json"
import json,sys
print(json.loads(sys.argv[1]).get('id',''))
PY
)"

db_json="$(mkfolder "db" "$root_id")"
files_json="$(mkfolder "files" "$root_id")"
man_json="$(mkfolder "manifests" "$root_id")"
logs_json="$(mkfolder "logs" "$root_id")"

extract_id() {
  python3 - <<'PY' "$1"
import json,sys
print(json.loads(sys.argv[1]).get('id',''))
PY
}

DRIVE_ROOT_FOLDER_ID="$root_id"
DRIVE_DB_FOLDER_ID="$(extract_id "$db_json")"
DRIVE_FILES_FOLDER_ID="$(extract_id "$files_json")"
DRIVE_MANIFESTS_FOLDER_ID="$(extract_id "$man_json")"
DRIVE_LOGS_FOLDER_ID="$(extract_id "$logs_json")"

echo "DRIVE_INIT_SUMMARY root=$DRIVE_ROOT_FOLDER_ID db=$DRIVE_DB_FOLDER_ID files=$DRIVE_FILES_FOLDER_ID manifests=$DRIVE_MANIFESTS_FOLDER_ID logs=$DRIVE_LOGS_FOLDER_ID"
