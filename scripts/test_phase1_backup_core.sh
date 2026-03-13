#!/usr/bin/env bash
set -euo pipefail

OSB_HOME="${OSB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BACKUP_SH="$OSB_HOME/adapters/wordpress/backup.sh"

echo "[phase1] backup adapter syntax"
bash -n "$BACKUP_SH"

echo "[phase1] stage marker contract"
for stage in "[1/5]" "[2/5]" "[3/5]" "[4/5]" "[5/5]"; do
  grep -Fq "$stage" "$BACKUP_SH"
done

echo "[phase1] remote cleanup trap contract"
grep -Fq "cleanup_on_error" "$BACKUP_SH"
grep -Fq "REMOTE_CREATED=1" "$BACKUP_SH"
grep -Fq "attempting remote temp cleanup after failure" "$BACKUP_SH"

echo "PHASE1_BACKUP_CORE_TEST: OK"
