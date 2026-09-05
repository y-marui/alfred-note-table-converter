# AI_CONTEXT.md — alfred-note-table-converter

> このファイルは開発憲章（`docs/dev-charter/`）をこのプロジェクト向けにまとめたものです。
> AIツールはセッション開始時にこのファイルを読むことで、憲章全体を参照しなくても
> プロジェクトの方針を把握できます。

## Reference Order

AI はタスク開始時に以下の順で参照する:

1. `README.md`（概要・セットアップ）
2. `DEVELOPING.md`（ビルド・実装規約・命名規則）

必要に応じて以下を参照する（順不同）:
- `CONTRIBUTING.md`（PR・Issue ルール）
- `docs/architecture.md`（モジュール・コンポーネント構造）
- `docs/file-map.md`（ファイルレベルの依存関係 ※情報が足りない・古い場合は適宜探索し、追記・更新する）
- `docs/specification.md`（機能仕様・データフロー）
- `docs/ui-design.md`（UI 設計・コンポーネント仕様）

不明点は `docs/dev-charter/CHARTER_INDEX.md` → 該当ファイルの順で参照する。

---

## Project Overview

Alfred 5 Script Filter ワークフロー。クリップボード上の表を Markdown ⇄ LaTeX で相互変換する。
Go（サードパーティ依存なし）、`cmd/`+`internal/` レイアウト、CI/CD 完備。
対象: 個人〜3人規模の開発チーム。ライセンス: MIT。

```
cmd/note-table-converter-alfred/  ← Alfred が実行する唯一のバイナリ
internal/tableconv/               ← Markdown ⇄ LaTeX 変換ロジック（コア、stdlib のみ）
internal/tableconvcmd/            ← クエリディスパッチ・Script Filter 応答の組み立て
internal/scriptfilter/            ← Alfred Script Filter JSON 型
workflow/                         ← Alfred パッケージ（info.plist / icon.png）
scripts/                          ← build-workflow.sh / extract-changelog.sh
```

詳細アーキテクチャ: `docs/architecture.md`

---

## Applied Charter Principles

### AI Context Priority (AI_CONTEXT_HIERARCHY)

1. タスクコンテキスト（Issue / Pull Request）
2. **プロジェクトコンテキスト（このファイル・プロジェクトドキュメント）** ← ここ
3. 開発憲章（`docs/dev-charter/`）
4. グローバルコンテキスト

### Software Design Principles (SOFTWARE_DESIGN_PRINCIPLES)

- **ローカルファースト** — Alfred ワークフローはオフラインで動作することを前提にする
- **インフラ最小化** — サーバーレス、外部依存なし（`go.mod` に依存ゼロ）
- **小さく始める** — 機能追加は必要性が確認されてから

### Change Design Principles (PRINCIPLES)

- **変更範囲は必要最小限** — Over-engineering しない
- **YAGNI** — 今必要ない機能は実装しない
- **DRY** — 2回の重複では抽象化しない。3回目で検討する
- **既存コードの再利用** — 新規実装前に類似機能がないか確認する
- **TODO/FIXME を残さない** — 実装するか、Issue として記録する（テンプレートの `# TODO:` コメントは「ユーザーが置き換える場所の目印」として例外的に許可）
- **既存パターンに従う** — 命名規則・アーキテクチャ・ディレクトリ構造を統一する

### AI Collaboration Rules (AI_COLLABORATION_RULES)

#### AI Behavior Principles
- **Scope 厳守** — 会話のタスク・ゴールを AI が勝手に変更しない
- **不明点は作業前に1回でまとめて質問する** — 重要な情報不足や曖昧さは質問する。軽微な不足は合理的な仮定で補い、仮定を明示する。推測で断定しない

#### Required Confirmations Before Coding
- ゴール（完了条件）
- 言語・FW・バージョン制約
- 新規 or 既存コード修正
- テストの要否
- 影響範囲

確認不要（既存コードに合わせて進める）: コードスタイル / ファイル配置 / 軽微な実装詳細

#### Error Handling
- **原因分析 → 修正方針説明 → 実装** の順で進める
- エラーログ・スタックトレースは全文確認してから対応
- 推測で修正しない（必要なら既存コードを確認する）
- デバッグ用の `print` 文は本番コードに残さない

#### Working Stance
- 大きな変更前に方針を説明してから着手する
- **不要な依存追加禁止** — 既存の依存で解決できないか先に検討する
- **ドキュメント同期** — 仕様・ルール・構成に変更が生じたとき、変更と同じ作業内で関連ドキュメントを更新する（対象: `docs/` 内ファイル、`AI_CONTEXT.md`、`README.md` 等）

#### dev-charter Modification Rules

`docs/dev-charter/` 配下のファイルを**直接編集しない**。

- 変更が必要な場合は dev-charter リポジトリ本体に Issue を立て、`git subtree pull` でアップデートを取り込む
- `git subtree pull` によるアップデートのみ許可する
- このプロジェクト固有のルールは `AI_CONTEXT.md` または専用ファイルに記載する

#### Charter Lookup

不明点が憲章に関係する場合は**全ファイルを検索せず**、以下の手順で参照する:

1. `docs/dev-charter/CHARTER_INDEX.md` を読み、該当トピックのファイルを特定する
2. 特定したファイル（原則 1〜2 件）のみを読む
3. 参照後にユーザーへ提案・確認を行う

推測で断定せず、憲章を参照してからユーザーに提案・質問する。

#### Multi-AI Usage
- Claude Code 作業中は Copilot 提案を**参考程度**に（盲目的に受け入れない）
- Copilot の提案がプロジェクト規約に反する場合は無視し、Claude Code でレビュー後採用

#### GitHub Operations

Issue を作成する場合は、必ずリポジトリオーナーを `assignee` に設定する。

```bash
gh issue create --title "..." --body "..." --assignee @me
```

### Language Policy (LANGUAGE_POLICY)

OSS プロジェクトのため、**公開面は英語を主言語**とする。
**日本語版が編集の起点（正本）であり、英語版はその翻訳として同期する。**

| 対象 | 言語 |
|---|---|
| `README.md` | 英語（参照版） |
| `README-jp.md` | 日本語（正本） |
| コミットメッセージ | 英語 |
| Issue / PR のタイトルと本文 | 英語 |
| 公開 API / public 関数 docstring | 英語 |
| examples/ のコメント | 英語 |
| エラーメッセージ・ログ | 英語 |
| private 関数・実装詳細のコメント | 日本語 OK |
| 変数名・識別子 | 英語 |

両言語ファイルが存在する場合: **日本語を正本として編集し、英語はそれに合わせて同一コミットで更新する**。

### Project Lifecycle (PROJECT_LIFECYCLE)

- 規模: 個人〜3人。アジャイルで迅速な意思決定
- **コミット粒度** — 機能単位・動作確認 OK 後にコミット
- **コミットメッセージ** — Conventional Commits 形式（feat / fix / refactor / docs / chore）
- **WIP 禁止** — 動作しないコードはコミットしない

### Security (SECURITY_POLICY)

#### Two-Layer Structure
1. **個人 git フック**（`~/.config/git/hooks/pre-commit`）— 開発者個人のマシン全体に適用
2. **per-repo pre-commit フック**（`.pre-commit-config.yaml`）— チーム強制・CI でも動作

#### Automatically Blocked Items
- `.env` ファイルのコミット（`.env.example` は許可）
- SSH 秘密鍵・クラウドトークン（gitleaks で検知）
- ローカル絶対パスのハードコード（環境依存コードの防止。`.md`・`docs/` は allowlist で除外）
- 500 KB を超えるファイル
- Markdown の H2〜H6 に日本語を使用（セクションヘッダ言語の統一）

#### Manual Compliance Items
- API キー・パスワードをコードに書かない（Alfred の暗号化キーチェーンを使う）
- 誤ってコミットしたシークレットは、履歴から削除した上で即座にローテーションする
- AI に秘密情報を含むファイルやコードを渡さない
- AI が生成したコードは必ずレビューしてからコミットする
- AI との会話ログをリポジトリにコミットしない

#### Code Review
- `main` に到達するコミットは可能な限り他の開発者がレビューする（個人開発の場合は PR を経由してセルフレビューする）
- 認証・認可・暗号化・データアクセスに関わる変更はセキュリティレビューを必須とする

詳細: `SECURITY.md`、`docs/dev-charter/SECURITY_POLICY.md`

### UI Guidelines (UI_GUIDELINES)

Alfred Script Filter のレスポンス（JSON items）に適用するルール:

- **Unicode 絵文字禁止** — Alfred の結果アイテムの `title` / `subtitle` に Unicode 絵文字を使わない
  - 代替: ASCII 記号（`>`、`*`、`[x]` など）または何も使わない
- アイコンは `workflow/icon.png` で制御する（PNG ファイル）
- 外観モード（ライト/ダーク）は Alfred が制御するため、ワークフロー側での対応は不要

### Monetization (MONETIZATION_POLICY)

OSS プロジェクトのため、以下の方式を採用する:

- **Buy Me a Coffee**: https://www.buymeacoffee.com/y.marui
- **GitHub Sponsors**: リポジトリの Sponsors 機能

README.md のバッジ行に GitHub Sponsors と Buy Me a Coffee バッジを掲載する（サポートセクションは設けず、バッジで代替）。
マネタイズを本格検討する場合は `MONETIZATION.md` を作成し、このファイルに概要を追記する。

### Localization (LOCALIZATION_POLICY)

Alfred ワークフローは現時点では UI テキストのローカライゼーション機能を持たない。
将来的に対応する場合の優先言語順:

1. ユーザー設定
2. システム言語設定
3. 英語（デフォルト）

対応候補言語: 日本語 / 英語 / 中国語 / ヒンディー語 / スペイン語 / フランス語 / ポルトガル語

---

## Project-Specific Rules

### Architecture Constraints

- `cmd/note-table-converter-alfred/main.go` は Alfred が実行する**唯一のバイナリ**。ビジネスロジックを書かない
- `internal/tableconvcmd/` はクエリディスパッチ・Script Filter 応答の組み立てのみ — 変換ロジックは `internal/tableconv/` に置く
- `internal/tableconv/` は Alfred 非依存の純粋ロジック — stdlib のみ使用し、単体でテスト可能に保つ
- すべての応答は `internal/scriptfilter.Response.Write()` を経由する
- `main()` は panic を `recover()` でラップする（未捕捉 panic = Alfred が空白表示になる）

### Native vs. Go

クリップボードの読み取り（`{clipboard}` → `clipboard_text` 変数、Arguments and Variables 経由）と
変換結果の貼り付け（Copy to Clipboard の `autopaste`）はどちらもネイティブ Alfred オブジェクトが
担い、Go 側は変換ロジックとコマンドディスパッチだけを行う（`docs/architecture.md` 参照）。新しい
macOS 連携を追加する前に
[`docs/alfred-workflow-notes/workflow-object-schema.md`](docs/alfred-workflow-notes/workflow-object-schema.md)
と dev-charter の `topics/ALFRED_DEV_ENV.md` を確認し、ネイティブで代替できないか検討する。

### Testing Conventions

- `internal/tableconv/`・`internal/tableconvcmd/` をテスト対象とする（`go test ./...`）
- クリップボード読み取りは Alfred の `{clipboard}` プレースホルダー経由でのみ渡され、Go コードは
  `pbpaste`/`pbcopy` を一切呼ばないため、実クリップボードの退避・復元は不要
- 変換ロジック（`internal/tableconv`）は外部 I/O を行わない純粋関数としてテストする

詳細な開発フロー・命名規則・コードレビュー手順は `DEVELOPING.md` を参照する。

### Go Development Environment (GO_TOOLCHAIN)

| 役割 | ツール |
|---|---|
| Go バージョン管理 | `go.mod` の `go` ディレクティブに従う |
| Linter / Formatter | `gofmt` + `go vet` |
| テスト | `go test` |
| 依存管理 | 標準の `go.mod`（サードパーティ依存は原則追加しない） |

新しい Go コードを追加する場合、または依存関係を変更する場合はこのツールチェーンに従う。

### Alfred Runtime (RUNTIME)

Alfred は Script Filter ノードからユニバーサル（amd64+arm64）バイナリを直接実行する。
インタプリタ選択や実行時ラッパースクリプトは不要。

`workflow/info.plist` の Script Filter ノードの `script` キー:

```bash
./note-table-converter-alfred "$1"
```

`tbl` キーワード（Keyword input）→ Arguments and Variables（`clipboard_text` を `{clipboard}` から設定）
→ この Script Filter、という配線になっている。バイナリはクリップボードを自分で読まない。

### Configuration Management (CONFIG_BUILDER)

- **ユーザーが設定する値はすべて Config Builder に入れる** — `workflow/info.plist` の `userconfigurationconfig` 配列に追加する
- Alfred の `variables` キー（environment variable）は使わない。Config Builder で代替できる場合は必ず Config Builder を使う
- Config Builder の値は Alfred がスクリプト実行時に環境変数として自動で渡すため、スクリプト側では `os.Getenv()` で読める
- 新しい設定項目を追加するときは以下の型から選ぶ: `textfield` / `checkbox` / `select` / `file` / `password`
- 現在このワークフローに Config Builder 変数はない（`userconfigurationconfig` は空配列。`tbl config` /
  `tbl config reset` コマンドは既存の永続設定ストアの名残で、実際には何も読み書きしない —
  `docs/specification.md` 参照）

### Code Style

- コメントは **「なぜそうするか」のみ** 書く。コードから自明な処理には書かない
- `gofmt` + `go vet`。CI で強制する
- すべての exported 関数・型に doc コメントを検討する（自明でないもののみ）

命名規則・コミットメッセージ形式・PR チェックリストは `DEVELOPING.md` を参照する。

### Performance

- Script Filter のレスポンスタイム目標: **100ms 未満**（コンパイル済みバイナリのため通常余裕がある）

### Dependency Management

- サードパーティ依存の追加は原則禁止（`go.mod` は依存なしを維持）
- ランタイム依存は最小限に保つ（パッケージ追加 = ワークフローサイズ・起動時間の増加）

---

## AI Tool Assignments

- **使用ツール**: Claude Code、GitHub Copilot、Gemini CLI
- **標準担当の正本**: `docs/dev-charter/AI_COLLABORATION_RULES.md` の「AI Tool Responsibilities」と「Rules for Multi-AI Usage」
- **プロジェクト固有の上書き**: なし

---

## Prohibited Actions

- シークレット・認証情報・`.env` ファイルのコミット
- pre-commit フックのスキップ（`--no-verify` 禁止）
- `cmd/note-table-converter-alfred/main.go` へのビジネスロジックの追加
- テストでの実際の HTTP 通信
- デバッグ用 `fmt.Print*` 文の本番コードへの残置
- Alfred 結果アイテムへの Unicode 絵文字の使用
- ハードコードされた絶対パス（`$HOME` を使う）
- Config Builder で代替できる設定を Alfred の `variables` キー（environment variable）に直接書くこと
- AI に秘密情報を含むファイルやコードを渡すこと
- AI との会話ログのリポジトリへのコミット

---

## Development Commands and Release Process

開発フロー・コマンド一覧・リリース手順は `DEVELOPING.md` を参照する。

---

*このファイルは `docs/dev-charter/` の内容をプロジェクト向けにまとめたものです。
憲章が更新された場合（`git subtree pull` 後）は、このファイルも更新してください。*
