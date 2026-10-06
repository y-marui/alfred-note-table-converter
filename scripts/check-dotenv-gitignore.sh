#!/usr/bin/env bash
# SECURITY_POLICY.md: ".env の正しい扱い方：.env は絶対にコミットしない。
# ダミー値のみを含む .env.example をコミットする。" を機械的に検証する。
#
# .env.example（または .env.sample / .env.template）がリポジトリに存在する
# のに .gitignore が .env を無視していない場合、開発者が誤って本物の .env を
# ステージしてしまうリスクが残るためエラーにする（コミット自体の検知は
# detect-dotenv フックが別途担う。これはその一次防御）。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

found_example=0
for name in .env.example .env.sample .env.template; do
  [ -f "${REPO_ROOT}/${name}" ] && found_example=1
done
[ "$found_example" -eq 1 ] || exit 0

GITIGNORE="${REPO_ROOT}/.gitignore"
if [ -f "$GITIGNORE" ] && grep -vE '^\s*#' "$GITIGNORE" | grep -q '\.env'; then
  exit 0
fi

echo "error: .env.example 等が存在しますが、.gitignore に .env を無視するパターンがありません。"
echo "  (SECURITY_POLICY.md: .env は絶対にコミットしない)"
echo "  .gitignore に '.env' を追加してください。"
exit 1
