#!/usr/bin/env bash
set -euo pipefail

OSB_HOME="${OSB_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$OSB_HOME"

required_files=(
  README.md
  docs/DOCS_INDEX.md
  docs/HANDOFF_PACK.md
  docs/handoff_checklist.md
  docs/ROADMAP_EXECUTION_AND_GATES.md
  docs/PRICING_AND_PACKAGING.md
  docs/storage_migration_plan.md
  strategy/90_day_execution_plan.md
  strategy/12_month_monetization_roadmap.md
)

for f in "${required_files[@]}"; do
  [[ -f "$f" ]] || { echo "MISSING_DOC: $f"; exit 1; }
done

# Ensure roadmap execution doc references gate scripts
grep -Fq "scripts/phase_gate.sh" docs/ROADMAP_EXECUTION_AND_GATES.md
grep -Fq "scripts/test_suite.sh" docs/ROADMAP_EXECUTION_AND_GATES.md

# Ensure docs index includes key newly-added docs
grep -Fq "docs/PRICING_AND_PACKAGING.md" docs/DOCS_INDEX.md
grep -Fq "docs/ROADMAP_EXECUTION_AND_GATES.md" docs/DOCS_INDEX.md
grep -Fq "docs/storage_migration_plan.md" docs/DOCS_INDEX.md

echo "PHASE4_DOCS_HANDOFF_TEST: OK"
