#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
STATE_DIR="${OSB_STATE:-$OSB_HOME/data/state}"
PACKET="$STATE_DIR/launch_go_no_go_packet.md"

mkdir -p "$STATE_DIR"

release_report="$STATE_DIR/release_readiness_report.md"
backend_log="$STATE_DIR/backend_matrix_smoke.log"
restore_metrics="$STATE_DIR/restore_metrics.jsonl"

last_restore_summary="(not found)"
if [[ -f "$STATE_DIR/release_readiness_report.md" ]]; then
  last_restore_summary="$(grep -E 'RESTORE_SUMMARY' -m1 "$release_report" || true)"
  [[ -n "$last_restore_summary" ]] || last_restore_summary="(not found in release report)"
fi

metrics_rows=0
if [[ -f "$restore_metrics" ]]; then
  metrics_rows=$(wc -l < "$restore_metrics" | tr -d ' ')
fi

backend_last="(not found)"
if [[ -f "$backend_log" ]]; then
  backend_last="$(tail -n 5 "$backend_log" | sed 's/^/- /')"
fi

{
  echo "# OpenSiteBackup Launch Go/No-Go Packet"
  echo
  echo "Generated: $(date -Is)"
  echo "Branch: $(git -C "$OSB_HOME" rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git -C "$OSB_HOME" rev-parse --short HEAD)"
  echo
  echo "## Evidence summary"
  echo "- release_readiness_report: $([[ -f "$release_report" ]] && echo present || echo missing)"
  echo "- backend_matrix_smoke.log: $([[ -f "$backend_log" ]] && echo present || echo missing)"
  echo "- restore_metrics.jsonl rows: $metrics_rows"
  echo
  echo "## Last restore summary marker"
  echo '```text'
  echo "$last_restore_summary"
  echo '```'
  echo
  echo "## Backend matrix tail"
  echo "$backend_last"
  echo
  echo "## Go/No-Go checklist"
  echo "- [ ] CI green on release PR"
  echo "- [ ] release_readiness_report.md PASS sections reviewed"
  echo "- [ ] backend matrix results reviewed"
  echo "- [ ] known caveats accepted"
  echo "- [ ] maintainer merge approval"
} > "$PACKET"

echo "LAUNCH_PACKET: $PACKET"
