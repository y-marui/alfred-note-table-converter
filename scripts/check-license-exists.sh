#!/usr/bin/env bash
# LEGAL_POLICY.md: "すべてのリポジトリに LICENSE ファイルを含める。
# ライセンスなしでの公開は禁止。" を機械的に検証する。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

shopt -s nullglob nocaseglob
matches=("${REPO_ROOT}"/LICENSE*)
shopt -u nullglob nocaseglob

if [ ${#matches[@]} -eq 0 ]; then
  echo "error: LICENSE ファイルがありません。"
  echo "  (LEGAL_POLICY.md: すべてのリポジトリに LICENSE ファイルを含める)"
  exit 1
fi

exit 0
