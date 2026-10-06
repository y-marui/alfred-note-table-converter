#!/usr/bin/env bash
# LANGUAGE_POLICY.md: "日本語版と英語版は同一コミットで更新する" を機械的に
# 検証する（同ポリシー: "構文・差分から判定できる項目は機械的に検証してよい"）。
#
# ペアは命名規則で判定する: <name>-jp.<ext> が正本（日本語）、<name>.<ext> が
# 参照（英語）。ペアの一方だけがステージされ、もう一方がリポジトリに存在する
# のに変更されていない場合はエラーにする。
set -euo pipefail

CHANGED=$(git diff --cached --name-only)
[ -n "$CHANGED" ] || exit 0

status=0
while IFS= read -r file; do
  [ -n "$file" ] || continue

  case "$file" in
    *-jp.*)
      pair="${file%-jp.*}.${file##*.}"
      ;;
    *)
      ext="${file##*.}"
      base="${file%.*}"
      pair="${base}-jp.${ext}"
      ;;
  esac

  [ "$pair" != "$file" ] || continue
  git ls-files --error-unmatch "$pair" >/dev/null 2>&1 || continue
  echo "$CHANGED" | grep -qxF "$pair" && continue

  echo "error: ${file} を変更していますが、対になる ${pair} が同一コミットで更新されていません。"
  echo "  (LANGUAGE_POLICY.md: 日本語版と英語版は同一コミットで更新する)"
  status=1
done <<< "$CHANGED"

exit "$status"
