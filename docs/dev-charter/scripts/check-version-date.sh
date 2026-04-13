#!/usr/bin/env bash
# Check (or update) VERSION to match today's date (local) or the last non-merge commit date (CI).
#
# Usage:
#   pre-commit run check-version-date            # local: compares to today
#   CI=1 pre-commit run --all-files              # CI: compares to git log -1 --no-merges date
#   UPDATE=1 bash scripts/check-version-date.sh  # write expected date to VERSION
set -euo pipefail

if [ -n "${CI:-}" ]; then
  EXPECTED=$(git log -1 --no-merges --format="%ad" --date=format:"%Y-%m-%d")
else
  EXPECTED=$(date +%Y-%m-%d)
fi

ACTUAL=$(head -1 VERSION 2>/dev/null || echo "")

if [ "${UPDATE:-}" = "1" ]; then
  printf '%s\n' "${EXPECTED}" > VERSION
  echo "VERSION updated to ${EXPECTED}"
  exit 0
fi

if [ "$ACTUAL" != "$EXPECTED" ]; then
  echo "VERSION (${ACTUAL}) must be ${EXPECTED}"
  echo "To fix: UPDATE=1 bash scripts/check-version-date.sh"
  exit 1
fi
