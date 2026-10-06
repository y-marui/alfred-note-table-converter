#!/usr/bin/env bash
# PROJECT_LIFECYCLE.md: "コミットメッセージ：Conventional Commits形式
# （feat/fix/refactor/docs）" を機械的に検証する。
#
# 憲章の例示は feat/fix/refactor/docs の4種だが、Conventional Commits
# 仕様の標準セット（+chore/test/style/perf/build/ci）を広く許可する。
#
# merge コミットは対象外にする: pre-commit の commit-msg ステージには
# git commit-msg フックの第2引数（コミットソース）が渡らないため、
# 代わりにメッセージファイルのパス（マージ時は .git/MERGE_MSG）で判定する。
#
# Usage (pre-commit commit-msg stage): scripts/check-conventional-commit.sh <commit-msg-file>
set -euo pipefail

MSG_FILE="$1"

case "$(basename "$MSG_FILE")" in
  MERGE_MSG|SQUASH_MSG) exit 0 ;;
esac

FIRST_LINE=$(head -1 "$MSG_FILE")

# コメント行のみ・空メッセージは対象外（git commit --amend --no-edit 等の
# 一部ケースで空になることがある）
[[ -n "${FIRST_LINE//[[:space:]]/}" ]] || exit 0
[[ "$FIRST_LINE" == \#* ]] && exit 0

# Revert メッセージ（git revert が自動生成、"Revert \"...\"" 形式）は対象外
[[ "$FIRST_LINE" == Revert\ * ]] && exit 0

PATTERN='^(feat|fix|docs|refactor|chore|test|style|perf|build|ci)(\([a-zA-Z0-9_./-]+\))?!?: .+'

if [[ "$FIRST_LINE" =~ $PATTERN ]]; then
  exit 0
fi

echo "error: コミットメッセージが Conventional Commits 形式ではありません: ${FIRST_LINE}"
echo "  (PROJECT_LIFECYCLE.md: コミットメッセージは Conventional Commits 形式)"
echo "  例: feat: 新機能の説明 / fix: バグ修正の説明"
exit 1
