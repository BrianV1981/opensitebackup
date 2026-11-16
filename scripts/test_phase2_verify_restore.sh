#!/usr/bin/env bash
set -euo pipefail

OSB_HOME="${OSB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
VERIFY_SH="$OSB_HOME/adapters/wordpress/verify.sh"
RESTORE_SH="$OSB_HOME/adapters/wordpress/restore.sh"

bash -n "$VERIFY_SH" "$RESTORE_SH"

echo "[phase2] verify contract markers"
grep -Fq "sha256sum" "$VERIFY_SH"
grep -Fq "tar -tzf" "$VERIFY_SH"
grep -Fq "CREATE TABLE" "$VERIFY_SH"
grep -Fq "INSERT INTO" "$VERIFY_SH"
grep -Fq "manifest.txt" "$VERIFY_SH"

echo "[phase2] restore safety + summary contract"
grep -Fq "atomic_restore_apply" "$RESTORE_SH"
grep -Fq "restore-db-rollback" "$RESTORE_SH"
grep -Fq "validate_staged_restore" "$RESTORE_SH"
grep -Fq "RESTORE_SUMMARY" "$RESTORE_SH"
grep -Fq "Type YES to continue" "$RESTORE_SH"
grep -Fq "local|drive" "$RESTORE_SH"

echo "PHASE2_VERIFY_RESTORE_TEST: OK"
