#!/usr/bin/env bash
set -euo pipefail

# Build a concise PR evidence markdown from current state artifacts.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
STATE_DIR="${OSB_STATE:-$OSB_HOME/data/state}"
OUT="$STATE_DIR/pr_evidence.md"

mkdir -p "$STATE_DIR"

report="$STATE_DIR/release_readiness_report.md"
packet="$STATE_DIR/launch_go_no_go_packet.md"
matrix="$STATE_DIR/backend_matrix_smoke.log"

extract_section() {
  local file="$1" title="$2"
  [[ -f "$file" ]] || { echo "(missing: $file)"; return 0; }
  awk -v t="$title" '
    $0 ~ "^## "t"$" {insec=1; print; next}
    insec && $0 ~ "^## " {exit}
    insec {print}
  ' "$file"
}

{
  echo "# OpenSiteBackup PR Evidence"
  echo
  echo "Generated: $(date -Is)"
  echo "Branch: $(git -C "$OSB_HOME" rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git -C "$OSB_HOME" rev-parse --short HEAD)"
  echo
  echo "## Strict preflight"
  extract_section "$report" "Strict Preflight"
  echo
  echo "## Pre-release check"
  extract_section "$report" "Pre-release Check"
  echo
  echo "## Backend matrix summary (tail)"
  if [[ -f "$matrix" ]]; then
    echo '```text'
    tail -n 12 "$matrix"
    echo '```'
  else
    echo "(missing: $matrix)"
  fi
  echo
  echo "## Launch packet summary"
  if [[ -f "$packet" ]]; then
    echo '```text'
    sed -n '1,80p' "$packet"
    echo '```'
  else
    echo "(missing: $packet)"
  fi
} > "$OUT"

echo "PR_EVIDENCE: $OUT"
