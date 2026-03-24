# AI_CONTEXT.md

このファイルは Claude Code・GitHub Copilot など AI ツールが参照するコンテキストです。

## このリポジトリについて

dev-charter の本体。他プロジェクトが `git subtree` で取り込む共有開発憲章。
ドキュメントのみのリポジトリ（ソースコードなし）。

## メンテナンスルール

- **正本は日本語**。英語版（README.md）は翻訳。日本語版と英語版は同一コミットで更新する
- **このファイルを更新したとき**は `.github/copilot-instructions.md` も同一コミットで同期する
- **Conventional Commits**（feat/fix/docs/chore）でコミットする
- **新規ドキュメントを追加するとき**は両言語の README のドキュメント一覧テーブルも更新する
- **憲章に追加できる原則・ルール**は複数の異なるプロジェクトに適用できるものに限る（1プロジェクト固有のルールは不可）

## セキュリティフック

`core.hooksPath` が設定済みかどうかで手順が異なる：

- **設定済み**（グローバルフックが pre-commit を呼ぶ）：`pre-commit install` 不要。`pre-commit run --all-files` で動作確認
- **未設定**：`pre-commit install` 後に `pre-commit run --all-files` で動作確認

確認コマンド：`git config core.hooksPath`

## AI ツール分担

- **Claude Code**：憲章の構成変更・大規模な追記・ポリシー設計
- **GitHub Copilot**：文章の微修正・翻訳補助・typo 修正
- **Gemini CLI**：自動読み込み不可。使用時に手動で渡すこと。自動読み込み機能が追加された際はこの記述を更新すること

## 禁止事項

- シークレット・認証情報のコミット
- 未完成・曖昧な原則のコミット（issue で管理する）
- プロジェクト固有のルールを憲章に追加すること
- ソースコード・ビルド成果物・ログのコミット
