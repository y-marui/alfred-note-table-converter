#!/usr/bin/env bash
# SECURITY_POLICY.md: .pre-commit-config.yaml の entry が指すスクリプトが
# 実在し実行可能か、およびフックと対で導入する補助スクリプトが揃っているかを
# 機械的に検証する。
#
# 導入手順のコピー漏れで、フックが存在しない補助スクリプトのパスを案内する
# （例: check-not-on-default-branch.sh が new-branch.sh を案内するが未導入）
# 事態を防ぐ。.pre-commit-config.yaml が無いプロジェクトは対象外。
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel)
CONFIG="${REPO_ROOT}/.pre-commit-config.yaml"

[ -f "$CONFIG" ] || exit 0

# フックスクリプト:対で導入する補助スクリプト
PAIRS=(
  "check-not-on-default-branch.sh:new-branch.sh"
)

status=0
referenced=()

while IFS= read -r entry; do
  entry="${entry%%#*}"
  read -r -a words <<<"$entry"
  [ "${#words[@]}" -gt 0 ] || continue
  script="${words[0]//[\"\']/}"
  case "$script" in
    */*.sh) ;;
    *) continue ;;
  esac
  referenced+=("$script")
  if [ ! -f "${REPO_ROOT}/${script}" ]; then
    echo "error: .pre-commit-config.yaml が指す ${script} が存在しません（SECURITY_POLICY.md）"
    status=1
  elif [ ! -x "${REPO_ROOT}/${script}" ]; then
    echo "error: ${script} に実行権限がありません（chmod +x ${script}）"
    status=1
  fi
done < <(sed -n -E 's/^[[:space:]]*entry:[[:space:]]*//p' "$CONFIG")

for pair in "${PAIRS[@]}"; do
  hook="${pair%%:*}"
  helper="${pair##*:}"
  for script in "${referenced[@]+"${referenced[@]}"}"; do
    [ "$(basename "$script")" = "$hook" ] || continue
    helper_path="$(dirname "$script")/${helper}"
    if [ ! -f "${REPO_ROOT}/${helper_path}" ]; then
      echo "error: ${hook} と対で導入する ${helper_path} が存在しません（SECURITY_POLICY.md）"
      status=1
    elif [ ! -x "${REPO_ROOT}/${helper_path}" ]; then
      echo "error: ${helper_path} に実行権限がありません（chmod +x ${helper_path}）"
      status=1
    fi
  done
done

exit "$status"
