#!/usr/bin/env bash
# Fail when a branch changes ONLY files under the installed dev-charter
# subtree (docs/dev-charter) without a sign that UPDATE_CHECKLIST was run.
#
# A mechanical `git subtree pull` update PR touches nothing but the subtree,
# so the checklist (AI_CONTEXT / README / hook sync) is easy to skip. This
# check is meant for the pre-push stage and CI, NOT for commit time:
# `git subtree pull` creates commits that only touch the subtree, and a
# commit-time check would block that legitimate import.
#
# Passes when any of these holds:
#   1. the diff against the base has no file under the subtree
#   2. the diff also contains at least one file outside the subtree
#   3. a commit in base..HEAD carries the trailer line `Update-Checklist: done`
#      (e.g. via `git commit --allow-empty`) for "nothing needed fixing"
#
# Base ref: $CHARTER_CHECK_BASE, else origin/HEAD, else origin/main.
# Subtree path: $CHARTER_PREFIX (default docs/dev-charter).
set -euo pipefail

PREFIX="${CHARTER_PREFIX:-docs/dev-charter}"
PREFIX="${PREFIX%/}"

BASE="${CHARTER_CHECK_BASE:-}"
if [ -z "$BASE" ]; then
  BASE=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)
fi

if ! git rev-parse --verify --quiet "${BASE}^{commit}" >/dev/null; then
  echo "warning: base ref '${BASE}' not found; skipping UPDATE_CHECKLIST check" >&2
  exit 0
fi

CHANGED=$(git diff --name-only "${BASE}...HEAD" 2>/dev/null) || {
  echo "warning: no merge base with '${BASE}'; skipping UPDATE_CHECKLIST check" >&2
  exit 0
}
[ -n "$CHANGED" ] || exit 0

INSIDE=$(printf '%s\n' "$CHANGED" | grep -c "^${PREFIX}/" || true)
OUTSIDE=$(printf '%s\n' "$CHANGED" | grep -vc "^${PREFIX}/" || true)

[ "$INSIDE" -gt 0 ] || exit 0
[ "$OUTSIDE" -eq 0 ] || exit 0

if git log "${BASE}..HEAD" --format=%B | grep -Eq '^Update-Checklist: done[[:space:]]*$'; then
  exit 0
fi

echo "error: ${PREFIX}/ のみを変更する差分に UPDATE_CHECKLIST 実施の印がありません。"
echo "  ${PREFIX}/UPDATE_CHECKLIST.md を実行し、反映があれば同じブランチに含めてください。"
echo "  反映が不要なら、trailer 付きの空 commit を足してください:"
echo "    git commit --allow-empty -m \"chore: confirm UPDATE_CHECKLIST\" -m \"Update-Checklist: done\""
exit 1
