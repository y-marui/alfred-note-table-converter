#!/usr/bin/env bash
# デフォルトブランチ (main/master/develop) 上でのコミットが
# check-not-on-default-branch.sh にブロックされたときの回避手段。
# ステージ済み・未ステージの変更は git checkout -b の標準動作で
# そのまま新ブランチへ引き継がれるため、変更を退避する処理は不要。
set -euo pipefail

if [ $# -ne 1 ] || [ -z "$1" ]; then
  echo "usage: $0 <branch-name>" >&2
  exit 1
fi

BRANCH_NAME="$1"

case "$BRANCH_NAME" in
  main|master|develop)
    echo "error: '${BRANCH_NAME}' は予約されたブランチ名です。別の名前を指定してください（例: work/<short-description>）。" >&2
    exit 1
    ;;
esac

git checkout -b "$BRANCH_NAME"
echo "ブランチ '${BRANCH_NAME}' を作成し、そちらに移動しました。"
