#!/usr/bin/env bash
# AI_TOOL_SETUP.md: "AI ツールごとの設定ファイルは AI_CONTEXT.md への参照のみを
# 持ち、ツール固有の設定のみを追記する。AI_CONTEXT.md の内容は重複させない。"
# を機械的に検証する（参照の有無のみ。重複の有無は判定しない）。
#
# AI_CONTEXT.md が無いプロジェクト（未導入 or 導入前）は対象外。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

[ -f "${REPO_ROOT}/AI_CONTEXT.md" ] || exit 0

status=0
for f in CLAUDE.md GEMINI.md AGENTS.md .github/copilot-instructions.md; do
  path="${REPO_ROOT}/${f}"
  [ -f "$path" ] || continue
  grep -q 'AI_CONTEXT\.md' "$path" || {
    echo "error: ${f} が AI_CONTEXT.md を参照していません（AI_TOOL_SETUP.md）"
    status=1
  }
done

exit "$status"
