#!/usr/bin/env bash
# Block commits that directly edit files under the installed dev-charter
# subtree (INSTALL_CHECKLIST.md: "docs/dev-charter/ 配下のファイルを直接
# 編集しないこと"). The only sanctioned way to change that tree is
# `git subtree add`/`pull --squash`.
#
# `git subtree` builds its "Squashed content" commit via `git commit-tree`,
# which never touches this hook — but the commit that actually joins that
# squashed history into the current branch (what `add`/`pull`/`merge` do
# last) is a real merge commit made via the normal commit machinery, which
# DOES run pre-commit hooks. An earlier version of this hook assumed
# subtree bypasses hooks entirely and got the working tree stuck mid-merge
# the first time a real (conflicting) subtree pull needed a manual
# `git commit` to finish.
#
# Skip the check only when MERGE_HEAD points at a commit carrying a
# `git-subtree-dir: $PREFIX` trailer — the marker `git subtree` itself
# writes into the squashed commit it merges in, exact-matching this hook's
# own prefix. A bare "we're mid-merge" check would exempt any merge,
# including an unrelated one that happens to also touch a file under the
# prefix (e.g. resolving a conflict on a branch where someone edited it
# directly).
#
# Override the subtree path with CHARTER_PREFIX if it was installed
# somewhere other than the default.
#
# Local-only safety net: this checks the staged diff (`git diff --cached`),
# which is what a real `git commit` sees. CI's `pre-commit run --all-files`
# runs against an already-committed working tree with nothing staged, so
# this hook is a no-op there — it does not catch a bad edit that already
# landed in a PR. Enforcing it in CI would need a separate check against
# the PR's base branch, not this script.
set -euo pipefail

PREFIX="${CHARTER_PREFIX:-docs/dev-charter}"

MERGE_HEAD_PATH=$(git rev-parse --git-path MERGE_HEAD 2>/dev/null || true)
if [ -n "$MERGE_HEAD_PATH" ] && [ -f "$MERGE_HEAD_PATH" ]; then
  MERGE_HEAD_SHA=$(cat "$MERGE_HEAD_PATH")
  if git log -1 --format=%B "$MERGE_HEAD_SHA" 2>/dev/null | grep -qx "git-subtree-dir: ${PREFIX}"; then
    exit 0
  fi
fi

CHANGED=$(git diff --cached --name-only -- "$PREFIX" || true)
[ -n "$CHANGED" ] || exit 0

echo "error: ${PREFIX}/ 配下は直接編集禁止です。"
echo "  変更が必要な場合は dev-charter リポジトリに Issue を立て、git subtree pull で取り込んでください。"
exit 1
