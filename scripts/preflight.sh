#!/usr/bin/env bash
set -euo pipefail

usage(){
  cat <<USAGE
Usage: bash scripts/preflight.sh [--strict]
Checks required tools and config presence.
USAGE
}

STRICT=0
[[ "${1:-}" == "--help" ]] && { usage; exit 0; }
[[ "${1:-}" == "--strict" ]] && STRICT=1

OSB_HOME="${OSB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"

echo "OSB_HOME=$OSB_HOME"
echo "ENV_FILE=$ENV_FILE"

need(){ command -v "$1" >/dev/null 2>&1 || { echo "MISSING: $1"; return 1; }; }

fail=0
for bin in bash ssh scp tar wp; do
  need "$bin" || fail=1
done

if [[ -f "$ENV_FILE" ]]; then
  echo "ENV: present"
else
  echo "ENV: missing (copy config/env.example -> config/env.sh)"
  fail=1
fi

if [[ $STRICT -eq 1 && $fail -ne 0 ]]; then
  exit 1
fi

[[ $fail -eq 0 ]] && echo "Preflight OK" || echo "Preflight warnings present"
