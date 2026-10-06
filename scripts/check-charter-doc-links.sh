#!/usr/bin/env bash
# Adopting repos sometimes update a docs/dev-charter/... reference to anticipate
# an upstream restructuring (e.g. a topics/<stack>/ move) before actually running
# `make update-charter` to pull it in, leaving a broken link until a follow-up
# subtree-sync PR lands (see dev-charter#131's python-package-template/
# python-closed-template follow-up). This hook catches that at commit time by
# verifying every docs/dev-charter/... path mentioned in the adopting repo's own
# tracked Markdown files actually exists on disk.
#
# AI_CONTEXT.md が無いプロジェクト（未導入 or 導入前）は対象外。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# dev-charter 自身のリポジトリには docs/dev-charter/ が存在しない（配布物であり
# 自分自身の subtree ではないため）。この場合は未導入と同様に対象外とする。
[ -d "docs/dev-charter" ] || exit 0

status=0
while IFS= read -r file; do
  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    if [ ! -e "$ref" ]; then
      echo "error: ${file} が存在しないパスを参照しています: ${ref}"
      status=1
    fi
  done < <(grep -oE 'docs/dev-charter/[A-Za-z0-9_./-]+\.md' "$file" | sort -u)
done < <(git ls-files '*.md' | grep -v '^docs/dev-charter/')

exit "$status"
