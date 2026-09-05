#!/usr/bin/env bash
# Extract release notes for a given version tag from CHANGELOG.md.
#
# Usage:
#   scripts/extract-changelog.sh v1.2.3
#   scripts/extract-changelog.sh 1.2.3
#
# Prints the CHANGELOG.md section for that version (matching a "## [x.y.z]"
# or "## x.y.z" heading), or a fallback "Release <version>" message if no
# matching heading is found. Always exits 0 so a missing entry never fails
# CI (see .github/workflows/release.yml).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHANGELOG="${REPO_ROOT}/CHANGELOG.md"

if [[ $# -lt 1 ]]; then
  echo "Usage: extract-changelog.sh <version>" >&2
  exit 1
fi

VERSION="${1#v}"

awk -v version="$VERSION" '
  function heading_matches(line,    h) {
    h = line
    sub(/^## /, "", h)
    sub(/^\[/, "", h)
    sub(/\].*$/, "", h)
    sub(/ .*$/, "", h)
    return h == version
  }
  BEGIN { state = 0; found = 0; n = 0 }
  /^## / {
    if (state == 1) { state = 2 }
    else if (state == 0 && heading_matches($0)) { state = 1; found = 1 }
    next
  }
  state == 1 { lines[n++] = $0 }
  END {
    if (!found) { print "Release " version; exit }
    start = 0
    end = n - 1
    while (start < n && lines[start] ~ /^[[:space:]]*$/) start++
    while (end >= 0 && lines[end] ~ /^[[:space:]]*$/) end--
    for (i = start; i <= end; i++) print lines[i]
  }
' "$CHANGELOG"
