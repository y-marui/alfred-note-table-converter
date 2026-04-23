# Docs Structure

プロジェクトのドキュメント構成を定義する。

**目的：**

- AI が自律的に開発できるようにする
- AI が全探索せずに済むようにする（token 効率の改善）
- 人間・AI 共用のナレッジベースとして維持する

---

## Typical Structure

```
project-root/
├── README.md                        # セットアップ・使い方（ユーザー向け）
├── README-jp.md                     # 日本語版（日英ペアで管理）
├── DEVELOPING.md                    # ビルド・実装規約・命名規則（開発者向け）
├── CONTRIBUTING.md                  # PR・Issue ルール（外部コントリビューター向け）
├── CHANGELOG.md                     # リリース履歴
├── LICENSE                          # ライセンス
├── Makefile                         # 開発タスク統一インターフェース
├── AI_CONTEXT.md                    # AI エントリーポイント
├── CLAUDE.md                        # @AI_CONTEXT.md + Claude Code 固有設定
├── GEMINI.md                        # @AI_CONTEXT.md + Gemini CLI 固有設定
├── .github/
│   └── copilot-instructions.md      # AI_CONTEXT.md 参照 + Copilot 固有設定
└── docs/
    ├── architecture.md              # モジュール・コンポーネント構造
    ├── file-map.md                  # ファイルレベルの依存関係（AI が追記）
    ├── specification.md             # 機能仕様・データフロー
    ├── ui-design.md                 # UI 設計（UI がない場合は「該当なし」）
    └── maintenance.md               # docs/ メンテナンス用プロンプト集
```

---

## Root Files

プロジェクトルートに配置する標準ファイルと、その責務を定める。

| ファイル | 責務 |
|---|---|
| `README.md` / `README-jp.md` | セットアップ・使い方・runbook・`docs/` への索引 |
| `DEVELOPING.md` | ビルド・テスト・実装規約・命名規則・デバッグ手順等 |
| `CONTRIBUTING.md` | PR・Issue ルール・コードレビューチェックリスト等（`DEVELOPING.md` を参照） |
| `CHANGELOG.md` | リリース履歴・破壊的変更の記録 |
| `LICENSE` | ライセンス（[LEGAL_POLICY.md](LEGAL_POLICY.md) 参照） |
| `Makefile` | 開発タスクの統一インターフェース（ビルド・テスト・lint 等）。プロジェクト固有のツール（npm scripts 等）で代替可能な場合を除き必須 |
| `AI_CONTEXT.md` | AI エントリーポイント（後述） |
| `CLAUDE.md` | `@AI_CONTEXT.md` + Claude Code 固有設定 |
| `GEMINI.md` | `@AI_CONTEXT.md` + Gemini CLI 固有設定 |
| `.github/copilot-instructions.md` | `AI_CONTEXT.md` 参照 + Copilot 固有設定 |

> 各ファイルの読者は包含関係にある。開発者は README も参照し、外部コントリビューターは README・DEVELOPING も参照し、AI はすべてを参照する。

AI ツール設定ファイルの詳細な構成仕様（セクション定義・重複排除ルール等）は [AI_TOOL_SETUP.md](AI_TOOL_SETUP.md) を参照。

### Responsibility Boundaries

各ファイルの読者と責務は以下の包含関係で定める:

| ファイル | 主な読者 | 責務 |
|---|---|---|
| `README.md` | ユーザー | インストール・使い方・runbook |
| `DEVELOPING.md` | 開発者 | ビルド・テスト・実装規約・命名規則・デバッグ |
| `CONTRIBUTING.md` | 外部コントリビューター | PR・Issue ルール（`DEVELOPING.md` を参照） |
| `AI_CONTEXT.md` | AI | プロジェクト構造・参照順序・AI 固有の指示 |

各ファイルは差分情報のみ持ち、情報を重複させない。上位の読者が必要な情報は参照で補う（例: `CONTRIBUTING.md` は `DEVELOPING.md` を参照する）。

- `README.md` と `README-jp.md` は日英ペアで管理し、同一コミットで更新する
- `README.md` は `docs/` の詳細ファイルへの索引とし、詳細を重複させない
  - プロジェクト README の構成詳細: [topics/PROJECT_README_GUIDELINES.md](topics/PROJECT_README_GUIDELINES.md)
  - テンプレートリポジトリ自体の README 設計: [topics/TEMPLATE_README_GUIDELINES.md](topics/TEMPLATE_README_GUIDELINES.md)

---

## docs/ Directory

プロジェクト内の `docs/` ディレクトリに配置する標準ファイルを定める。

### Common Files (全プロジェクト共通)

| ファイル | 内容 |
|---|---|
| `docs/architecture.md` | モジュール・コンポーネント間の依存関係、エントリーポイント |
| `docs/file-map.md` | ファイルレベルの依存関係（AI が作業のたびに追記していく運用） |
| `docs/specification.md` | 機能仕様・動作定義・データフロー |
| `docs/ui-design.md` | UI 設計・コンポーネント仕様（UI がない場合は「該当なし」と記載） |
| `docs/maintenance.md` | docs/ メンテナンス用プロンプト集（ローカル LLM 向け） |

`docs/file-map.md` は AI が初回探索後に追記していく運用とし、初期状態は最小限でよい。

### Format Specification

各ファイルのフォーマットを統一することで、AI が全件探索せずに必要な情報に直接アクセスできる。

#### docs/architecture.md

```markdown
# Architecture

## Overview
<!-- プロジェクト全体像を3行以内で記述 -->

## Entry Points
- `パス/ファイル` — 説明

## Directory Structure
| ディレクトリ | 役割 |
|---|---|
| `src/` | ... |

## Key Dependencies
| ライブラリ / モジュール | 用途 |
|---|---|
| `requests` | HTTP クライアント |
```

- Overview は3行以内
- ファイルレベルの詳細は記載しない（`file-map.md` に委譲）
- 主要な依存のみ列挙し、全依存を網羅しない

#### docs/file-map.md

```markdown
# File Map

_最終更新: YYYY-MM-DD_

## [モジュール / 機能名]
| ファイル | 役割 | 主な依存先 |
|---|---|---|
| `src/foo.py` | 説明 | `src/bar.py` |
```

- 全ファイルを網羅しなくてよい。AI が参照・編集したファイルを順次追記する
- 未探索ファイルは記載しない（不正確な記述を避ける）
- 更新のたびに `最終更新` 日付を更新する

### docs/maintenance.md

ローカル LLM で `docs/` ファイルをメンテナンスするためのプロンプト集。
インストール時に AI がプロジェクトの技術スタック（言語・ビルドツール等）に合わせて生成する。

含める内容：

- `docs/architecture.md` を更新するプロンプト（フォーマット仕様をインラインで埋め込む）
- `docs/file-map.md` を更新するプロンプト（同上）

プロンプトは以下の構造にする：

```
[タスク説明]

手順：
1. [調査ステップ（ディレクトリ構造確認・主要ファイルの読み込み等）]
2. [既存ファイルを読む（存在する場合）]
3. [フォーマット仕様を明示したうえで、ファイルを上書き保存する]

注意：[制約・注意事項]
```

> ローカル LLM はファイルへの保存を省略しやすいため、「上書き保存する」を手順の最終ステップとして明示する。

---

### Project-Type-Specific Files

| プロジェクト種別 | ファイル | 内容 |
|---|---|---|
| Alfred ワークフロー | `docs/configuration-builder.md` | 設定ビルダーの仕様 |
| GitHub テンプレートリポジトリ | `README_TEMPLATE.md` / `README_TEMPLATE-jp.md` | プロジェクト化後の README 雛形（[topics/TEMPLATE_README_GUIDELINES.md](topics/TEMPLATE_README_GUIDELINES.md) 参照） |

---

## AI_CONTEXT.md — Reference Order

`AI_CONTEXT.md` の冒頭に、AI が作業開始時に参照する順序を明記する。

```
## Reference Order

AI はタスク開始時に以下の順で参照する:

1. README.md（概要・セットアップ）
2. DEVELOPING.md（ビルド・実装規約・命名規則）

必要に応じて以下を参照する（順不同）:
- CONTRIBUTING.md（PR・Issue ルール）
- docs/architecture.md（モジュール・コンポーネント構造）
- docs/file-map.md（ファイルレベルの依存関係 ※情報が足りない・古い場合は適宜探索し、追記・更新する）
- docs/specification.md（機能仕様・データフロー）
- docs/ui-design.md（UI 設計・コンポーネント仕様）
```

これにより、AI は全ファイルを探索せず必要なドキュメントに直接アクセスできる。

`AI_CONTEXT.md` の全体的な構成仕様（セクション定義・AIツール設定ファイルとの関係）は
[AI_TOOL_SETUP.md](AI_TOOL_SETUP.md) を参照すること。
