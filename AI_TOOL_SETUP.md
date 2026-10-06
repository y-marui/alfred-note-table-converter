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

### Document Sync Rule

以下を必ず含める：

```
仕様・ルール・構成に変更が生じたとき、変更と同じ作業内で関連ドキュメントを更新する。
対象は docs/ 内のファイルに限らず、AI_CONTEXT.md・README.md 等のルートファイルも含む。
```

### Project-Specific Rules
憲章に含まれない既存規約、または憲章を上書き・補足する事項

### AI Tool Assignments

使用する AI ツールと、プロジェクト固有の担当変更を記載する。
標準的な役割分担の正本は `AI_COLLABORATION_RULES.md` とし、`AI_CONTEXT.md` に共通の役割を転記しない。

以下の形式で記載する：

```
- **使用ツール**：Claude Code、Codex、GitHub Copilot、Gemini CLI、ローカル LLM（Ollama）
- **標準担当の正本**：`docs/dev-charter/AI_COLLABORATION_RULES.md` の「AI Tool Responsibilities」と「Rules for Multi-AI Usage」
- **プロジェクト固有の上書き**：なし
```

担当を変更する場合は「プロジェクト固有の上書き」に差分だけを記載する。未使用ツールは「使用ツール」から省略する。
subtree の配置先が `docs/dev-charter/` 以外の場合は、正本へのパスを実際の配置先に合わせる。
ローカル LLM の接続情報と委任条件は `AI_COLLABORATION_RULES.md` の「Local LLM Delegation」に従う。

### Prohibited Actions
セキュリティ制約・スコープ外変更の禁止事項

## Agent Config Files

AI ツールごとの設定ファイルは `AI_CONTEXT.md` への参照のみを持ち、
**ツール固有の設定のみ**を追記する。`AI_CONTEXT.md` の内容は重複させない。
ツール固有の設定がない場合は、以下の最小構成だけを記載する。

### CLAUDE.md

```
@AI_CONTEXT.md
```

### GEMINI.md

```
@AI_CONTEXT.md
```

### AGENTS.md

Codex は `@` によるファイルの自動展開を前提としないため、読み込み指示を明記する。

```
`AI_CONTEXT.md` を参照。
```

### .github/copilot-instructions.md

```
`AI_CONTEXT.md` を参照。
```
