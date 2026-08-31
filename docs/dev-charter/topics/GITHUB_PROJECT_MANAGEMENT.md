# GitHub Project Management

「今後やること（一時的な情報）」と「今こうなっている（恒久的な情報）」をリポジトリ内で混在させない。前者は GitHub の Issues/Projects/Milestones に任せ、リポジトリ内ドキュメントは後者だけを持つ。

## Principle

- **一時的な情報**（TODO・バックログ・スプリント計画・ロードマップ）は GitHub の標準機能で管理する。リポジトリに `TODO.md` / `ROADMAP.md` / `BACKLOG.md` 等のファイルを置かない
- **恒久的な情報**（仕様・アーキテクチャ・設計判断）は `docs/` 等のリポジトリ内ドキュメントに置く（構成は [DOCS_STRUCTURE.md](../DOCS_STRUCTURE.md) 参照）
- 理由：Markdown の TODO/ROADMAP は更新が漏れて陳腐化しやすく、検索・フィルタ・担当者アサイン・進捗集計もできない。GitHub の標準機能はこれらを無料で提供し、かつ Issue/PR とリンクする

## Mapping Table

| 用途 | 使う機能 |
|---|---|
| 個別のタスク・バグ・機能要望 | Issues（Issue Types・Labels） |
| タスクの分解（チェックリストの代替） | Sub-issues |
| リリース単位の締切・進捗管理 | Milestones |
| ボード表示（カンバン） | Projects (v2) — Board view |
| 時系列のロードマップ表示 | Projects (v2) — Roadmap view |
| スプリント管理 | Projects (v2) — Iteration field |

## Issues

- Issue Types（`Task` / `Bug` / `Feature` 等）で種別を分類する
- Labels は優先度・領域等、Issue Types と重複しない軸で使う
- 大きな Issue は Markdown 内のネストしたチェックリストではなく **Sub-issues** で分解する。親 Issue に進捗（`n/m` 完了）が自動表示される
- 複数ステップ・Sub-issues を持つ大きな Issue を実装する場合は `epic/<name>` ブランチを作成し、作成時点で親 Issue にコメントで報告する（詳細: [PROJECT_LIFECYCLE.md](../PROJECT_LIFECYCLE.md) の Branch Strategy）

## Milestones

リリース単位・締切単位で Issue/PR をグルーピングする。進捗率が自動集計されるため、`ROADMAP.md` に手動で進捗を書く必要がない。

## Projects (v2)

- ビューは Table / Board / Roadmap の3種。同じデータを用途に応じて切り替えて表示するだけで、実体の二重管理にはならない
- カスタムフィールド（single-select・date・iteration 等）でスプリントや優先度を管理できる
- built-in workflow で「条件一致時に自動追加」「クローズ時に自動アーカイブ」等を設定し、手動更新の漏れを防ぐ
- 複数リポジトリを横断するロードマップが必要な場合に特に有効（Organization/User 単位で作成できる）

### Scale Guidance

個人〜少人数（[PROJECT_LIFECYCLE.md](../PROJECT_LIFECYCLE.md) 参照）で、単一リポジトリ・小規模な場合は Issues + Labels + Milestones だけで十分なことが多い。Projects (v2) は「複数リポジトリを横断したい」「ロードマップを可視化したい」等、具体的な必要が生じてから導入すればよい（YAGNI）。

## What Stays in the Repository

`docs/architecture.md` や `docs/specification.md` 等は「現在の仕様・設計」を記述する恒久ドキュメントであり、「次に何をするか」の記述場所ではない（[DOCS_STRUCTURE.md](../DOCS_STRUCTURE.md) 参照）。実装予定・未着手の機能は Issue を作成して参照する。

## Anti-pattern

- `TODO.md` / `ROADMAP.md` / `BACKLOG.md` 等をリポジトリに新規作成しない
- 既存プロジェクトにこれらのファイルがある場合、内容を Issues/Milestones/Projects に移行し、ファイルは削除する
