#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fail=0
while IFS= read -r -d '' file; do
  while IFS= read -r match; do
    rel="$(printf '%s' "$match" | tr -d '`')"
    rel="${rel%%#*}"
    [[ -n "$rel" ]] || continue
    [[ "$rel" == *.md ]] || continue
    [[ "$rel" =~ ^https?:// ]] && continue

    if [[ "$rel" == ./* || "$rel" == ../* ]]; then
      target="$(cd "$(dirname "$file")" && realpath -m "$rel")"
    elif [[ "$rel" == */* ]]; then
      target="$ROOT/$rel"
    else
      local_target="$(cd "$(dirname "$file")" && realpath -m "$rel")"
      if [[ -f "$local_target" ]]; then
        target="$local_target"
      else
        target="$ROOT/$rel"
      fi
    fi

    if [[ ! -f "$target" ]]; then
      echo "BROKEN_DOC_LINK file=$file target=$rel"
      fail=1
    fi
  done < <(grep -oE '`[^`]+\.md(#[-A-Za-z0-9_./]+)?`' "$file" || true)
done < <(find README.md docs strategy -type f -name '*.md' -print0 2>/dev/null)

if [[ $fail -ne 0 ]]; then
  exit 1
fi

echo "DOC_LINK_CHECK: OK"
