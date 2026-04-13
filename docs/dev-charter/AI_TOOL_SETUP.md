# AI Tool Setup Guide

dev-charter を導入したプロジェクトで AI コンテキストファイルをどう構成すべきかを定義する。

## AI_CONTEXT.md

プロジェクト固有のコンテキストをまとめる単一ファイル。
憲章の全文は転記せず、このプロジェクトに直接関係する内容のみ抽出・要約する。
関係しない憲章ドキュメントはスキップしてよい。

以下のセクション構成で作成する：

### Project Overview
目的・技術スタック（言語・FW・バージョン）・主要ディレクトリ一覧

### Applied Charter Principles
このプロジェクトの開発・運用フローに直接影響する原則とルール。
憲章の参照先パスも記載する（AI が効率的に参照できるよう）。

例：
```
憲章参照: docs/dev-charter/CHARTER_INDEX.md でトピックを特定してから該当ファイルのみ読む
```

（`docs/dev-charter/` は実際の subtree パスに合わせて変更する）

### Project-Specific Rules
憲章に含まれない既存規約、または憲章を上書き・補足する事項

### AI Tool Assignments
使用する AI ツールの担当範囲（未使用ツールは省略する）

### Prohibited Actions
セキュリティ制約・スコープ外変更の禁止事項

## Agent Config Files

AI ツールごとの設定ファイルは `AI_CONTEXT.md` への参照のみを持ち、
**ツール固有の設定のみ**を追記する。`AI_CONTEXT.md` の内容は重複させない。

### CLAUDE.md（Claude Code）

```
@AI_CONTEXT.md

# Claude Code-specific settings
（ツール固有の設定があればここに追記）
```

### GEMINI.md（Gemini CLI）

```
@AI_CONTEXT.md

# Gemini CLI-specific settings
（ツール固有の設定があればここに追記）
```

### .github/copilot-instructions.md（GitHub Copilot）

```
See @AI_CONTEXT.md for shared project context.

# Copilot-specific settings
（ツール固有の設定があればここに追記）
```
