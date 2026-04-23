# AI_CONTEXT.md

## About This Repository

dev-charter の本体。他プロジェクトが `git subtree` で取り込む共有開発憲章。
ドキュメントのみのリポジトリ（ソースコードなし）。

このファイルは **dev-charter リポジトリ自体を作業する AI 向け**のコンテキスト。
採用先プロジェクトへの導入手順は `README-jp.md` を参照すること。

## Maintenance Rules

- **正本は日本語**。英語版（README.md）は翻訳。日本語版と英語版は同一コミットで更新する
- **Conventional Commits**（feat/fix/docs/chore）でコミットする
- **コミット前に `VERSION` を今日の日付（UTC、`YYYY-MM-DD`）に更新する**。1日に複数回リリースしない（日付がバージョン識別子のため）。pre-commit フックが自動検証する
  - ローカルの更新コマンド：`UPDATE=1 bash scripts/check-version-date.sh`（`VERSION` を UTC 日付で更新）
  - **クラウド/エージェント環境**：ローカルの pre-commit フックが動作しない。CI の自動更新ワークフロー（`.github/workflows/update-version.yml`）が `VERSION` を自動的に更新してコミットするため、漏れた場合は CI が補完する。エージェントは可能な限り手動で VERSION を更新するのが望ましい
- **新規ドキュメントを追加するとき**は両言語の README のドキュメント一覧テーブルも更新する
- **憲章に追加できる原則・ルール**は複数の異なるプロジェクトに適用できるものに限る（1プロジェクト固有のルールは不可）
- **dev-charter 全ドキュメントのセクションヘッダ**：日本語ドキュメントでも英語で記載する

## CI Workflows

このリポジトリには以下の GitHub Actions ワークフローが存在する：

| ファイル | 目的 |
|---|---|
| `.github/workflows/ci.yml` | PR・main push に対して `pre-commit run --all-files` を実行し、`check-version-date` 等のフックを強制する |
| `.github/workflows/update-version.yml` | 非フォーク PR で `VERSION` が古い場合に自動更新コミットを行う（cloud/agent 対応） |
| `.github/workflows/check-charter.yml` | 採用先プロジェクトから呼び出す再利用可能ワークフロー（dev-charter 本体の CI ではない） |

`ci.yml` の `Build` ジョブが Branch Protection の必須ステータスチェックとして機能する。

## Security Hooks

`core.hooksPath` が設定済みかどうかで手順が異なる：

- **設定済み**（グローバルフックが pre-commit を呼ぶ）：`pre-commit install` 不要。`pre-commit run --all-files` で動作確認
- **未設定**：`pre-commit install` 後に `pre-commit run --all-files` で動作確認

確認コマンド：`git config core.hooksPath`

## AI Tool Responsibilities

- **Claude Code**：憲章の構成変更・大規模な追記・ポリシー設計
- **GitHub Copilot**：文章の微修正・翻訳補助・typo 修正
- **Gemini CLI**：`GEMINI.md` を用意済み。`@AI_CONTEXT.md` による自動読み込みをサポート

## Prohibited Actions

- シークレット・認証情報のコミット
- 未完成・曖昧な原則のコミット（issue で管理する）
- プロジェクト固有のルールを憲章に追加すること
- ソースコード・ビルド成果物・ログのコミット
