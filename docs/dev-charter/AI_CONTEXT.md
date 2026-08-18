## Reference Order

AI はタスク開始時に以下の順で参照する：

1. `README-jp.md`（このリポジトリの概要・導入・更新方法）
2. `CHARTER_INDEX.md`（タスクに関係する憲章ファイルの特定）
3. `CHARTER_INDEX.md` で特定したファイル（原則 1〜2 件）

## Project Overview

dev-charter の本体。他プロジェクトが `git subtree` で取り込む共有開発憲章。
ドキュメントのみのリポジトリ（ソースコードなし）。

このファイルは **dev-charter リポジトリ自体を作業する AI 向け**のコンテキスト。
採用先プロジェクトへの導入手順は `README-jp.md` を参照すること。

### Technology Stack

- Markdown：憲章・ガイドライン・チェックリスト
- Bash：インストール・バージョン検証スクリプト（CI・pre-commit の実行基盤）
- PowerShell：上記スクリプトの `.ps1` 版（`scripts/*.ps1`）。ローカル Windows 環境向けの並行実装で、CI では未使用（#57 参照）
- GitHub Actions / pre-commit：CI・セキュリティ・文書品質の検証
- アプリケーション用のランタイム・フレームワーク：なし

### Main Directories

| パス | 役割 |
|---|---|
| `/` | 共通原則・ポリシー・AI コンテキスト・導入手順 |
| `topics/` | 技術・運用トピック別の詳細ガイドライン |
| `scripts/` | インストール・バージョン検証スクリプト |
| `.github/workflows/` | CI・VERSION 更新・採用先向け更新ワークフロー |

## Applied Charter Principles

- コンテキストが競合する場合は `AI_CONTEXT_HIERARCHY.md` の優先順位に従う
- 変更範囲を必要最小限にし、YAGNI・既存パターン優先など `PRINCIPLES.md` の設計原則に従う
- シークレット管理と検証は `SECURITY_POLICY.md` に従う

## Document Sync Rule

仕様・ルール・構成に変更が生じたとき、変更と同じ作業内で関連ドキュメントを更新する。
対象は docs/ 内のファイルに限らず、AI_CONTEXT.md・README.md 等のルートファイルも含む。

## Project-Specific Rules

- **正本は日本語**。英語版（README.md）は翻訳。日本語版と英語版は同一コミットで更新する（`LANGUAGE_POLICY.md` 参照）
- **Conventional Commits**（feat/fix/docs/chore）でコミットする
- **コミット前に `VERSION` を今日の日付（UTC、`YYYY-MM-DD`）に更新する**。1日に複数回リリースしない（日付がバージョン識別子のため）。pre-commit フックが自動検証する
  - ローカルの更新コマンド：`UPDATE=1 bash scripts/check-version-date.sh`（`VERSION` を UTC 日付で更新）
  - **クラウド/エージェント環境**：ローカルの pre-commit フックが動作しない。CI の自動更新ワークフロー（`.github/workflows/update-version.yml`）が `VERSION` を自動的に更新してコミットするため、漏れた場合は CI が補完する。エージェントは可能な限り手動で VERSION を更新するのが望ましい
- **新規ドキュメントを追加するとき**は正本の索引である `CHARTER_INDEX.md` を更新する
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

pre-commit は、シークレット・ローカル絶対パス・VERSION 日付・ローカル dev-charter バージョン（sibling `../dev-charter` との比較）・Markdown の H2〜H6 の見出し言語・シェルスクリプトを機械的に検証する。日英文書の意味的一致など判断を要する項目は、AI または人間がレビューする。

確認コマンド：`git config core.hooksPath`

## AI Tool Assignments

- **使用ツール**：Claude Code、Codex、GitHub Copilot、Gemini CLI、ローカル LLM（Ollama）
- **標準担当の正本**：`AI_COLLABORATION_RULES.md` の「AI Tool Responsibilities」と「Rules for Multi-AI Usage」
- **このリポジトリ固有の上書き**：なし

## Prohibited Actions

- シークレット・認証情報のコミット
- 未完成・曖昧な原則のコミット（issue で管理する）
- プロジェクト固有のルールを憲章に追加すること
- ソースコード・ビルド成果物・ログのコミット
