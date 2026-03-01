#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${DRIVE_ACCOUNT:?DRIVE_ACCOUNT is required}"
ROOT_NAME="opensitebackup"

mkfolder_json() {
  local name="$1" parent="${2:-}"
  if [[ -n "$parent" ]]; then
    gog drive mkdir "$name" --account "$DRIVE_ACCOUNT" --parent "$parent" --json --results-only --no-input
  else
    gog drive mkdir "$name" --account "$DRIVE_ACCOUNT" --json --results-only --no-input
  fi
}

extract_id() {
  python3 - <<'PY' "$1"
import json,sys
print(json.loads(sys.argv[1]).get('id',''))
PY
}

root_json="$(mkfolder_json "$ROOT_NAME")"
root_id="$(extract_id "$root_json")"

db_json="$(mkfolder_json "db" "$root_id")"
files_json="$(mkfolder_json "files" "$root_id")"
man_json="$(mkfolder_json "manifests" "$root_id")"
logs_json="$(mkfolder_json "logs" "$root_id")"

db_id="$(extract_id "$db_json")"
files_id="$(extract_id "$files_json")"
man_id="$(extract_id "$man_json")"
logs_id="$(extract_id "$logs_json")"

echo "DRIVE_INIT_SUMMARY root=$root_id db=$db_id files=$files_id manifests=$man_id logs=$logs_id"
echo "export DRIVE_ROOT_FOLDER_ID=\"$root_id\""
echo "export DRIVE_DB_FOLDER_ID=\"$db_id\""
echo "export DRIVE_FILES_FOLDER_ID=\"$files_id\""
echo "export DRIVE_MANIFESTS_FOLDER_ID=\"$man_id\""
echo "export DRIVE_LOGS_FOLDER_ID=\"$logs_id\""
