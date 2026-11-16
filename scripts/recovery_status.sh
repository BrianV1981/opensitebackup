#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

state_dir="${OSB_STATE:-$OSB_HOME/data/state}"
backup_root="${LOCAL_BACKUP_ROOT:-${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG:-site}-live}}"
latest_backup="$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR==1{print $2}')"

manifest=""
sums=""
if [[ -n "$latest_backup" ]]; then
  manifest="$latest_backup/manifest.txt"
  sums="$latest_backup/local_sha256.txt"
fi

restore_rows=0
[[ -f "$state_dir/restore_metrics.jsonl" ]] && restore_rows=$(wc -l < "$state_dir/restore_metrics.jsonl" | tr -d ' ')

status="GREEN"
reason="all core signals present"

if [[ -z "$latest_backup" || ! -f "$manifest" || ! -f "$sums" ]]; then
  status="RED"
  reason="missing verified backup artifacts"
elif [[ "$restore_rows" -eq 0 ]]; then
  status="YELLOW"
  reason="no restore drill metrics yet"
fi

cat <<EOF
RECOVERY_STATUS
status=$status
reason=$reason
site_slug=${SOURCE_SITE_SLUG:-site}
backend=${OSB_BACKEND:-local}
latest_backup=${latest_backup:-none}
manifest=$([[ -f "$manifest" ]] && echo present || echo missing)
checksums=$([[ -f "$sums" ]] && echo present || echo missing)
restore_metrics_rows=$restore_rows
release_report=$([[ -f "$state_dir/release_readiness_report.md" ]] && echo present || echo missing)
launch_packet=$([[ -f "$state_dir/launch_go_no_go_packet.md" ]] && echo present || echo missing)
EOF
