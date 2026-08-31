#!/usr/bin/env bash
# LANGUAGE_POLICY.md: 日英ペアドキュメントの冒頭宣言（正本/参照）・末尾の
# 編集ルールフッターの有無を機械的に検証する。
#
# 文言は完全一致を要求せず、キーワードの有無で緩く判定する（実運用の
# README.md/README-jp.md でも "参照" 文の言い回しに揺れがあるため）。
# 対象はペアが両方存在するドキュメントのみ（日本語版だけの内部文書は対象外）。
set -euo pipefail

status=0

check_pair() {
  local jp="$1" en="$2"
  local head_jp head_tail_jp head_en tail_en

  head_jp=$(head -5 "$jp")
  head_tail_jp=$(tail -5 "$jp")
  head_en=$(head -5 "$en")
  tail_en=$(tail -5 "$en")

  if ! echo "$head_jp" | grep -q '正本'; then
    echo "error: ${jp} の冒頭に正本宣言がありません（LANGUAGE_POLICY.md）"
    status=1
  fi
  if ! { echo "$head_tail_jp" | grep -q '英語版' && echo "$head_tail_jp" | grep -qE '同一コミット|同じコミット'; }; then
    echo "error: ${jp} の末尾に編集ルールフッター（英語版があり同一コミットで更新する旨）がありません（LANGUAGE_POLICY.md）"
    status=1
  fi
  if ! echo "$head_en" | grep -qiE 'canonical|reference'; then
    echo "error: ${en} の冒頭に参照宣言がありません（LANGUAGE_POLICY.md）"
    status=1
  fi
  if ! { echo "$tail_en" | grep -qi 'canonical' && echo "$tail_en" | grep -qiE 'same commit'; }; then
    echo "error: ${en} の末尾に編集ルールフッター（正本があり同一コミットで更新する旨）がありません（LANGUAGE_POLICY.md）"
    status=1
  fi
}

while IFS= read -r jp; do
  [ -n "$jp" ] || continue
  en="${jp%-jp.*}.${jp##*.}"
  [ -f "$en" ] || continue
  check_pair "$jp" "$en"
done < <(git ls-files -- '*-jp.md')

exit "$status"
