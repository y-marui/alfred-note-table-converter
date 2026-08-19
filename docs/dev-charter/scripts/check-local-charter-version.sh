#!/usr/bin/env bash
# Compare this repo's installed dev-charter VERSION against a sibling
# ../dev-charter checkout's main branch.
#
# Expected layout:
#   <parent>/dev-charter/     a local clone of dev-charter
#   <parent>/<this-repo>/     this repository
#
# - sibling main newer than installed  -> block (a confirmed, actionable gap: run git subtree pull)
# - sibling main older than installed  -> warn only (sibling itself may just be un-pulled)
# - equal, or either VERSION unavailable -> silent
#
# Reads VERSION from the sibling's local `main` ref (not its working tree), so
# the result doesn't depend on whatever branch happens to be checked out there.
# Override with CHARTER_PREFIX / CHARTER_LOCAL_PATH / CHARTER_LOCAL_REF env vars if needed.
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
PREFIX="${CHARTER_PREFIX:-docs/dev-charter}"
LOCAL_CHARTER="${CHARTER_LOCAL_PATH:-$(dirname "$REPO_ROOT")/dev-charter}"
LOCAL_REF="${CHARTER_LOCAL_REF:-main}"

INSTALLED_VERSION_FILE="${REPO_ROOT}/${PREFIX}/VERSION"

[ -f "$INSTALLED_VERSION_FILE" ] || exit 0
[ -d "$LOCAL_CHARTER" ] || exit 0

INSTALLED=$(head -1 "$INSTALLED_VERSION_FILE")
LOCAL=$(git -C "$LOCAL_CHARTER" show "${LOCAL_REF}:VERSION" 2>/dev/null | head -1) || exit 0
[ -n "$LOCAL" ] || exit 0

if [ "$LOCAL" = "$INSTALLED" ]; then
  exit 0
fi

if [[ "$LOCAL" > "$INSTALLED" ]]; then
  echo "error: ${LOCAL_CHARTER} の ${LOCAL_REF} ブランチの VERSION (${LOCAL}) が ${PREFIX}/VERSION (${INSTALLED}) より新しいです。"
  echo "  git subtree pull で dev-charter を更新してからコミットしてください。"
  exit 1
fi

echo "warning: ${LOCAL_CHARTER} の ${LOCAL_REF} ブランチの VERSION (${LOCAL}) は ${PREFIX}/VERSION (${INSTALLED}) より古いです。"
echo "  (${LOCAL_CHARTER} の ${LOCAL_REF} 自体が fetch/pull 済みでない可能性があるため、警告にとどめています)"
exit 0
