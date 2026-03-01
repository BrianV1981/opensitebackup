#!/usr/bin/env bash
set -euo pipefail
if command -v shellcheck >/dev/null 2>&1; then
  find scripts -type f -name "*.sh" -print0 | xargs -0 -r shellcheck
  echo "shellcheck: OK"
else
  echo "shellcheck not installed; skipping"
fi
