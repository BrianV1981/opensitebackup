#!/usr/bin/env bash
set -euo pipefail

OSB_HOME="${OSB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
GOG_SH="$OSB_HOME/backends/gog/upload.sh"
RCLONE_SH="$OSB_HOME/backends/rclone/upload.sh"
LOCAL_SH="$OSB_HOME/backends/local/upload.sh"
MATRIX_SH="$OSB_HOME/scripts/backend_matrix_smoke.sh"

bash -n "$GOG_SH" "$RCLONE_SH" "$LOCAL_SH" "$MATRIX_SH"

echo "[phase3] retry/log contracts"
for f in "$GOG_SH" "$RCLONE_SH"; do
  grep -Fq "retry_upload()" "$f"
  grep -Fq "upload_with_log()" "$f"
  grep -Fq "START upload:" "$f"
  grep -Fq "DONE  upload:" "$f"
done

echo "[phase3] backend summaries"
grep -Fq "UPLOAD_VERIFY_SUMMARY backend=gog" "$GOG_SH"
grep -Fq "UPLOAD_VERIFY_SUMMARY backend=rclone" "$RCLONE_SH"
grep -Fq "Local backend upload complete" "$LOCAL_SH"

echo "[phase3] matrix policy"
grep -Fq "required local backend" "$MATRIX_SH"
grep -Fq "optional backend" "$MATRIX_SH"
grep -Fq "BACKEND_MATRIX_SMOKE: PASS" "$MATRIX_SH"

echo "PHASE3_BACKENDS_TEST: OK"
