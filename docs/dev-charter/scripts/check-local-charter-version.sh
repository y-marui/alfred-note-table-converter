#!/usr/bin/env bash
# Compare this repo's installed dev-charter VERSION against a sibling
# ../dev-charter checkout.
#
# Expected layout:
#   <parent>/dev-charter/     a local clone of dev-charter
#   <parent>/<this-repo>/     this repository
#
# - sibling newer than installed  -> block (a confirmed, actionable gap: run git subtree pull)
# - sibling older than installed  -> warn only (sibling itself may just be un-pulled)
# - equal, or either VERSION file missing -> silent
#
# Override with CHARTER_PREFIX / CHARTER_LOCAL_PATH env vars if needed.
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
PREFIX="${CHARTER_PREFIX:-docs/dev-charter}"
LOCAL_CHARTER="${CHARTER_LOCAL_PATH:-$(dirname "$REPO_ROOT")/dev-charter}"

INSTALLED_VERSION_FILE="${REPO_ROOT}/${PREFIX}/VERSION"
LOCAL_VERSION_FILE="${LOCAL_CHARTER}/VERSION"

[ -f "$INSTALLED_VERSION_FILE" ] || exit 0
[ -f "$LOCAL_VERSION_FILE" ] || exit 0

INSTALLED=$(head -1 "$INSTALLED_VERSION_FILE")
LOCAL=$(head -1 "$LOCAL_VERSION_FILE")

if [ "$LOCAL" = "$INSTALLED" ]; then
  exit 0
fi

if [[ "$LOCAL" > "$INSTALLED" ]]; then
  echo "error: ${LOCAL_CHARTER} の VERSION (${LOCAL}) が ${PREFIX}/VERSION (${INSTALLED}) より新しいです。"
  echo "  git subtree pull で dev-charter を更新してからコミットしてください。"
  exit 1
fi

echo "warning: ${LOCAL_CHARTER} の VERSION (${LOCAL}) は ${PREFIX}/VERSION (${INSTALLED}) より古いです。"
echo "  (${LOCAL_CHARTER} 自体が fetch/pull 済みでない可能性があるため、警告にとどめています)"
exit 0
