#!/usr/bin/env bash
# topics/PROJECT_README_GUIDELINES.md: 配布用ファイル（LICENSE・
# .github/FUNDING.yml・README）に残ったプレースホルダ（[YEAR] [AUTHOR]
# [USERNAME] [BMC_USERNAME]）を機械的に検証する。
#
# {user}/{repo}/{workflow}（CI バッジ）は対象外にする: dev-charter 自身の
# README.md が「採用先への導入方法の説明」としてこれらの文字列を意図的に
# 使っており、コードブロック解析なしでは確実に区別できないため。
#
# README_TEMPLATE.md が存在するリポジトリはテンプレートリポジトリ自体
# であり、これらのプレースホルダは意図的に残す（
# topics/GITHUB_SETTINGS.md, topics/TEMPLATE_README_GUIDELINES.md 参照）
# ため対象外。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)

[ -f "${REPO_ROOT}/README_TEMPLATE.md" ] && exit 0
[ -f "${REPO_ROOT}/README_TEMPLATE-jp.md" ] && exit 0

status=0

check_file() {
  local file="$1"
  shift
  local path="${REPO_ROOT}/${file}"
  [ -f "$path" ] || return 0

  local pattern
  for pattern in "$@"; do
    if grep -qF "$pattern" "$path"; then
      echo "error: ${file} にプレースホルダ ${pattern} が残っています。"
      echo "  (topics/PROJECT_README_GUIDELINES.md: プレースホルダを実際の値に置換する)"
      status=1
    fi
  done
}

check_file "LICENSE" "[YEAR]" "[AUTHOR]"
check_file ".github/FUNDING.yml" "[USERNAME]" "[BMC_USERNAME]"
check_file "README.md" "[USERNAME]" "[BMC_USERNAME]"
check_file "README-jp.md" "[USERNAME]" "[BMC_USERNAME]"

exit "$status"
