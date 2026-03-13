#!/usr/bin/env bash
set -euo pipefail

OSB_HOME="${OSB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$OSB_HOME"

for f in scripts/install.sh scripts/first_run.sh scripts/backup_now.sh scripts/test_restore_local.sh scripts/recovery_status.sh; do
  [[ -f "$f" ]] || { echo "MISSING_SCRIPT: $f"; exit 1; }
  bash -n "$f"
done

grep -Fq "INSTALL_READY: OK" scripts/install.sh
grep -Fq "FIRST_RUN: OK" scripts/first_run.sh
grep -Fq "BACKUP_NOW: OK" scripts/backup_now.sh
grep -Fq "TEST_RESTORE_LOCAL: OK" scripts/test_restore_local.sh
grep -Fq "RECOVERY_STATUS" scripts/recovery_status.sh

echo "ADOPTION_UX_TEST: OK"
