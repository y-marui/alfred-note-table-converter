#!/usr/bin/env bash
# topics/python/PYTHON_DEV_ENV.md: "pyproject.toml で依存関係を管理する
# （requirements.txt は使用しない）" "uv.lock をリポジトリに含め、
# 再現性を担保する" を機械的に検証する。
#
# pyproject.toml が無いプロジェクト（非 Python プロジェクト）は対象外。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

[ -f "${REPO_ROOT}/pyproject.toml" ] || exit 0

status=0

if [ -f "${REPO_ROOT}/requirements.txt" ]; then
  echo "error: requirements.txt が存在します。"
  echo "  (topics/python/PYTHON_DEV_ENV.md: pyproject.toml で依存関係を管理する。requirements.txt は使用しない)"
  status=1
fi

if [ ! -f "${REPO_ROOT}/uv.lock" ]; then
  echo "error: pyproject.toml があるのに uv.lock がありません。"
  echo "  (topics/python/PYTHON_DEV_ENV.md: uv.lock をリポジトリに含め、再現性を担保する)"
  status=1
fi

exit "$status"
