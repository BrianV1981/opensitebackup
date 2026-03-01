#!/usr/bin/env bash
set -euo pipefail

# Usage: bash scripts/with_lock.sh <lock-name> <command> [args...]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
STATE_DIR="${OSB_STATE:-$OSB_HOME/data/state}"
LOCK_DIR="$STATE_DIR/locks"
mkdir -p "$LOCK_DIR"

name="${1:-}"
shift || true
[[ -n "$name" ]] || { echo "lock name required"; exit 2; }
[[ $# -gt 0 ]] || { echo "command required"; exit 2; }

lockfile="$LOCK_DIR/${name}.lock"
meta="$LOCK_DIR/${name}.meta"

exec 9>"$lockfile"
if ! flock -n 9; then
  echo "LOCKED: $name (another run is active)"
  if [[ -f "$meta" ]]; then
    echo "LOCK_META: $(cat "$meta")"
  fi
  exit 99
fi

echo "pid=$$ started=$(date -Is) cmd=$*" > "$meta"

cleanup(){
  rm -f "$meta"
}
trap cleanup EXIT

"$@"
