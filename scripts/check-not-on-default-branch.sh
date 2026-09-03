#!/usr/bin/env bash
# GitHub の Ruleset（CI_POLICY.md「Branch Protection (Ruleset)」参照）は
# デフォルトブランチへの直接 push をサーバ側で止めるが、push 前にローカルで
# デフォルトブランチへコミットを重ねてしまうこと自体は防げない。このフックは
# 同じ制約をコミット時点で機械的に強制する（人・AIエージェントを問わない）。
#
# GitHub Actions のチェックアウトは detached HEAD または PR ref で、
# ローカルブランチ名を持たないため、CI 上では意味を持たない（$CI で判定しスキップ）。
set -euo pipefail

[ -z "${CI:-}" ] || exit 0


# rev-parse --abbrev-ref HEAD は unborn HEAD（初回コミット前）で解決に失敗する
# （HEAD がまだどのコミットも指していないため）。symbolic-ref は HEAD が指す
# ブランチ名をコミットの有無に関係なく返すため、新規リポジトリのセットアップ
# 手順（初回コミット前に pre-commit run --all-files を実行する）でも正しく
# 検知できる。detached HEAD の場合は symbolic-ref 自体が失敗するので、
# その場合も安全にスキップされる。
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null) || exit 0

DEFAULT_BRANCH=""
if git remote get-url origin >/dev/null 2>&1; then
  DEFAULT_BRANCH=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || true)
fi

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ] || { [ -n "$DEFAULT_BRANCH" ] && [ "$BRANCH" = "$DEFAULT_BRANCH" ]; }; then
  echo "error: デフォルトブランチ (${BRANCH}) への直接コミットはブロックされています。"
  echo "  作業用ブランチを作成してください: git checkout -b work/<short-description>"
  exit 1
fi

exit 0
