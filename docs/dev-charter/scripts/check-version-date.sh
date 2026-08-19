#!/usr/bin/env bash
# Check (and auto-update) VERSION to match the current hour (local) or the
# last non-merge commit's hour (CI).
#
# VERSION uses hour granularity (YYYY-MM-DDThhZ, UTC) rather than a plain
# date: multiple meaningful dev-charter updates can land on the same
# calendar day, and a date-only VERSION would make the second one
# indistinguishable from the first to every downstream freshness check
# (check-local-charter-version.sh, check-charter.yml, etc). Hour precision
# is coarse enough to avoid a race between when this hook writes VERSION
# and when `git commit` actually stamps the commit a few seconds later
# (minute precision made that a real, if rare, source of CI failures at
# merge time).
#
# Usage:
#   pre-commit run check-version-date            # local: auto-writes VERSION to match the current hour, like end-of-file-fixer
#   CI=1 pre-commit run --all-files              # CI: only checks against git log -1 --no-merges (never writes)
#   UPDATE=1 bash scripts/check-version-date.sh  # force-write explicitly (e.g. cloud/agent environments without pre-commit hooks)
set -euo pipefail

if [ -n "${CI:-}" ]; then
  EXPECTED=$(TZ=UTC git log -1 --no-merges --format="%ad" --date=format-local:"%Y-%m-%dT%HZ")
else
  EXPECTED=$(date -u +%Y-%m-%dT%HZ)
fi

ACTUAL=$(head -1 VERSION 2>/dev/null || echo "")

if [ "${UPDATE:-}" = "1" ]; then
  printf '%s\n' "${EXPECTED}" > VERSION
  echo "VERSION updated to ${EXPECTED}"
  exit 0
fi

if [ "$ACTUAL" = "$EXPECTED" ]; then
  exit 0
fi

if [ -n "${CI:-}" ]; then
  echo "VERSION (${ACTUAL}) must be ${EXPECTED}"
  echo "To fix: UPDATE=1 bash scripts/check-version-date.sh"
  exit 1
fi

# Local: auto-write like end-of-file-fixer / trailing-whitespace do --
# modify the file and exit 1 so pre-commit reports it as changed and the
# commit is retried with the fix staged.
printf '%s\n' "${EXPECTED}" > VERSION
echo "VERSION (${ACTUAL}) updated to ${EXPECTED}"
exit 1
