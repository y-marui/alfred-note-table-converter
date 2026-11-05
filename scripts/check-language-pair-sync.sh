#!/usr/bin/env bash
# LANGUAGE_POLICY.md: "日本語版と英語版は同一コミットで更新する" を機械的に
# 検証する（同ポリシー: "構文・差分から判定できる項目は機械的に検証してよい"）。
#
# ペアは命名規則で判定する: <name>-jp.<ext> が正本（日本語）、<name>.<ext> が
# 参照（英語）。ペアの一方だけがステージされ、もう一方がリポジトリに存在する
# のに変更されていない場合はエラーにする。
#
# 例外: 変更が冒頭の正本/参照宣言と末尾の編集ルールフッター（LANGUAGE_POLICY.md
# "When Using Separate Files"）だけの場合は、対になるファイルの更新を求めない。
# 宣言・フッターを標準文に揃える修正は、片側だけが基準からずれている場合に
# もう一方へ意味のない編集を入れさせないための例外（内容の変更は従来どおり
# 同一コミットを要求する）。
set -euo pipefail

# 標準入力の Markdown から、冒頭の宣言（先頭 8 行以内の引用ブロックで、
# 正本/参照/canonical/reference を含むもの）、末尾 6 行以内の `---` 以降の
# フッター（同一コミット/same commit を含むもの）、空行を除いて出力する。
strip_markers() {
  awk '
    { l[NR] = $0 }
    END {
      n = NR; a = 0; b = 0; f = 0
      for (i = 1; i <= n && i <= 8; i++) if (l[i] ~ /^>/) { a = i; break }
      if (a) {
        b = a
        while (b + 1 <= n && l[b + 1] ~ /^>/) b++
        blk = ""
        for (i = a; i <= b; i++) blk = blk l[i]
        if (blk !~ /正本|参照|[Cc]anonical|[Rr]eference/) { a = 0; b = 0 }
      }
      for (i = n; i >= 1 && i > n - 6; i--) if (l[i] == "---") { f = i; break }
      if (f) {
        ft = ""
        for (i = f; i <= n; i++) ft = ft l[i]
        if (ft !~ /同一コミット|同じコミット|[Ss]ame commit/) f = 0
      }
      for (i = 1; i <= n; i++) {
        if (a && i >= a && i <= b) continue
        if (f && i >= f) continue
        if (l[i] ~ /^[[:space:]]*$/) continue
        print l[i]
      }
    }'
}

# ステージされた変更が宣言・フッターだけなら 0 を返す（HEAD に無い新規ファイルは 1）。
only_markers_changed() {
  local file="$1" old new
  git cat-file -e "HEAD:${file}" 2>/dev/null || return 1
  old=$(git show "HEAD:${file}" | strip_markers)
  new=$(git show ":${file}" | strip_markers)
  [ "$old" = "$new" ]
}

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
  grep -qxF "$pair" <<<"$CHANGED" && continue
  only_markers_changed "$file" && continue

  echo "error: ${file} を変更していますが、対になる ${pair} が同一コミットで更新されていません。"
  echo "  (LANGUAGE_POLICY.md: 日本語版と英語版は同一コミットで更新する)"
  status=1
done <<< "$CHANGED"

exit "$status"
