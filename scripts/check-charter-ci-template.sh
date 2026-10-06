#!/usr/bin/env bash
# Compare this repo's .github/workflows/dev-charter-check.yml against the CI
# template documented in the installed dev-charter's README-jp.md
# ("## Version Check (CI)" section).
#
# - workflow file not present (optional feature not added yet) -> silent
# - installed dev-charter README missing (not installed here)  -> silent
# - template block not found in README-jp.md (README structure changed) -> warn only
# - workflow file differs from the template -> block
#
# Override with CHARTER_PREFIX env var if needed.
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
PREFIX="${CHARTER_PREFIX:-docs/dev-charter}"

WORKFLOW_FILE="${REPO_ROOT}/.github/workflows/dev-charter-check.yml"
TEMPLATE_SOURCE="${REPO_ROOT}/${PREFIX}/README-jp.md"

[ -f "$WORKFLOW_FILE" ] || exit 0
[ -f "$TEMPLATE_SOURCE" ] || exit 0

TEMPLATE=$(awk '
  /^## Version Check \(CI\)/ { in_section = 1 }
  in_section && /^```yaml/ { in_block = 1; next }
  in_section && in_block && /^```/ { exit }
  in_block { print }
' "$TEMPLATE_SOURCE")

if [ -z "$TEMPLATE" ]; then
  echo "warning: ${TEMPLATE_SOURCE} から CI テンプレートを抽出できませんでした（README 構成が変わった可能性があります）。" >&2
  exit 0
fi

if ! DIFF=$(diff -u <(printf '%s\n' "$TEMPLATE") <(sed 's/\r$//' "$WORKFLOW_FILE")); then
  echo "error: .github/workflows/dev-charter-check.yml が ${PREFIX}/README-jp.md の CI テンプレートと一致しません。" >&2
  echo "" >&2
  echo "$DIFF" >&2
  echo "" >&2
  echo "  ${PREFIX}/README-jp.md の \"Version Check (CI)\" セクションを参照して更新してください。" >&2
  exit 1
fi

exit 0
