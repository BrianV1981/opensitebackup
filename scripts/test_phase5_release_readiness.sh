#!/usr/bin/env bash
set -euo pipefail

OSB_HOME="${OSB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$OSB_HOME"

bash scripts/release_prepare.sh >/dev/null
bash scripts/generate_launch_packet.sh >/dev/null

REPORT="${OSB_STATE:-$OSB_HOME/data/state}/release_readiness_report.md"
PACKET="${OSB_STATE:-$OSB_HOME/data/state}/launch_go_no_go_packet.md"

[[ -f "$REPORT" ]] || { echo "MISSING_RELEASE_REPORT"; exit 1; }
[[ -f "$PACKET" ]] || { echo "MISSING_LAUNCH_PACKET"; exit 1; }

grep -Fq "# OpenSiteBackup Release Readiness Report" "$REPORT"
grep -Fq "Strict Preflight" "$REPORT"
grep -Fq "Pre-release Check" "$REPORT"
grep -Fq "Backend Matrix Smoke" "$REPORT"

grep -Fq "# OpenSiteBackup Launch Go/No-Go Packet" "$PACKET"
grep -Fq "Go/No-Go checklist" "$PACKET"

echo "PHASE5_RELEASE_READINESS_TEST: OK"
