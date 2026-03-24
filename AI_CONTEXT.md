# AI_CONTEXT.md — alfred-workflow-template

> このファイルは開発憲章（`docs/dev-charter/`）をこのプロジェクト向けにまとめたものです。
> AIツールはセッション開始時にこのファイルを読むことで、憲章全体を参照しなくても
> プロジェクトの方針を把握できます。

---

## プロジェクト概要

Alfred 5 Script Filter ワークフロー用の OSS テンプレート。
Python 3.9+、レイヤードアーキテクチャ、CI/CD 完備。
対象: 個人〜3人規模の開発チーム。

```
src/alfred/     ← Alfred SDK（response / router / cache / config / logger / safe_run）
src/app/        ← アプリケーション層（commands / services / clients）
workflow/       ← Alfred パッケージ（info.plist / scripts/entry.py / vendor/）
tests/          ← pytest テストスイート
scripts/        ← build.sh / dev.sh / release.sh / vendor.sh
```

詳細アーキテクチャ: `docs/architecture.md`

---

## AI コンテキスト優先順位（AI_CONTEXT_HIERARCHY）

1. タスクコンテキスト（Issue / Pull Request）
2. **プロジェクトコンテキスト（このファイル・プロジェクトドキュメント）** ← ここ
3. 開発憲章（`docs/dev-charter/`）
4. グローバルコンテキスト

---

## 開発原則（PRINCIPLES）

### 基本哲学
- **ローカルファースト** — Alfred ワークフローはオフラインで動作することを前提にする
- **インフラ最小化** — サーバーレス、外部依存なし（vendor/ に完結）
- **小さく始める** — 機能追加は必要性が確認されてから

### コード設計
- **変更範囲は必要最小限** — Over-engineering しない
- **YAGNI** — 今必要ない機能は実装しない
- **DRY** — 2回の重複では抽象化しない。3回目で検討する
- **既存コードの再利用** — 新規実装前に類似機能がないか確認する
- **TODO/FIXME を残さない** — 実装するか、Issue として記録する（テンプレートの `# TODO:` コメントは「ユーザーが置き換える場所の目印」として例外的に許可）
- **既存パターンに従う** — 命名規則・アーキテクチャ・ディレクトリ構造を統一する

---

## コードスタイル（CODE_STYLE）

- コメントは **「なぜそうするか」のみ** 書く。コードから自明な処理には書かない
- ruff + black、行長 100
- すべての public 関数に型ヒント必須
- 各モジュール先頭に `from __future__ import annotations`

---

## AI 協働ルール（AI_COLLABORATION_RULES）

### AI 行動原則
- **Scope 厳守** — 会話のタスク・ゴールを AI が勝手に変更しない
- **不明点は作業前に1回でまとめて質問する** — 推測で進めない

### コーディング前の確認必須項目
- ゴール（完了条件）
- 言語・FW・バージョン制約
- 新規 or 既存コード修正
- テストの要否
- 影響範囲

### エラー対応
- **原因分析 → 修正方針説明 → 実装** の順で進める
- エラーログ・スタックトレースは全文確認してから対応
- デバッグ用の `print` 文は本番コードに残さない

### AIツールの役割分担

| ツール | 担当 |
|---|---|
| Claude Code | プロジェクト立ち上げ・大規模変更・アーキテクチャ設計・リファクタリング |
| GitHub Copilot | バグ修正・細かな実装補助・単体テスト作成 |
| Gemini CLI | プライバシーポリシー作成・更新 / ストア説明文 / 審査用ドキュメント / プロジェクト全体のドキュメント管理 |

### 作業スタンス

- 大きな変更前に方針を説明してから着手する
- **不要な依存追加禁止** — 既存の依存で解決できないか先に検討する

### AI 並用時のルール
- Claude Code 作業中は Copilot 提案を**参考程度**に（盲目的に受け入れない）
- Copilot の提案がプロジェクト規約に反する場合は無視し、Claude Code でレビュー後採用

---

## 言語ポリシー（LANGUAGE_POLICY）

このプロジェクトは **OSS** のため、**英語を主言語**とする。

- `README.md` — 英語（国際的な参照用）
- `README-jp.md` — 日本語（正本）
- ソースコード内コメント・変数名 — 英語
- Issue / PR 本文 — 英語または日本語（どちらでも可）
- 両言語が存在する場合は**日本語を主として編集**し、英語はそれに合わせて更新する

---

## ローカライゼーション（LOCALIZATION_POLICY）

Alfred ワークフローは現時点では UI テキストのローカライゼーション機能を持たない。
将来的に対応する場合の優先言語順:

1. ユーザー設定
2. システム言語設定
3. 英語（デフォルト）

対応候補言語: 日本語 / 英語 / 中国語 / ヒンディー語 / スペイン語 / フランス語 / ポルトガル語

---

## プロジェクトライフサイクル（PROJECT_LIFECYCLE）

- 規模: 個人〜3人。アジャイルで迅速な意思決定
- **コミット粒度** — 機能単位・動作確認 OK 後にコミット
- **コミットメッセージ** — Conventional Commits 形式（feat / fix / refactor / docs / chore）
- **WIP 禁止** — 動作しないコードはコミットしない

---

## UI ガイドライン（UI_GUIDELINES）

Alfred Script Filter のレスポンス（JSON items）に適用するルール:

- **Unicode 絵文字禁止** — Alfred の結果アイテムの `title` / `subtitle` に Unicode 絵文字を使わない
  - 代替: ASCII 記号（`>`、`*`、`[x]` など）または何も使わない
- アイコンは `workflow/icon.png` で制御する（PNG ファイル）
- 外観モード（ライト/ダーク）は Alfred が制御するため、ワークフロー側での対応は不要

---

## マネタイズ（MONETIZATION_POLICY）

OSS プロジェクトのため、以下の方式を採用する:

- **Buy Me a Coffee**: https://www.buymeacoffee.com/y.marui
- **GitHub Sponsors**: リポジトリの Sponsors 機能

README.md の末尾に Buy Me a Coffee バッジを掲載する。
マネタイズを本格検討する場合は `MONETIZATION.md` を作成し、このファイルに概要を追記する。

---

## セキュリティ（SECURITY_POLICY）

### 二層構造
1. **個人 git フック**（`~/.config/git/hooks/pre-commit`）— 開発者個人のマシン全体に適用
2. **per-repo pre-commit フック**（`.pre-commit-config.yaml`）— チーム強制・CI でも動作

### 自動ブロック項目
- `.env` ファイルのコミット（`.env.example` は許可）
- SSH 秘密鍵・クラウドトークン（gitleaks で検知）
- ローカル絶対パスのハードコード（環境依存コードの防止）
- 500 KB を超えるファイル

### 手動遵守事項
- API キー・パスワードをコードに書かない（Alfred の暗号化キーチェーンを使う）
- AI に秘密情報を含むファイルやコードを渡さない
- AI が生成したコードは必ずレビューしてからコミットする
- AI との会話ログをリポジトリにコミットしない

詳細: `SECURITY.md`、`docs/dev-charter/SECURITY_POLICY.md`

---

## 開発コマンド

```bash
make install          # dev 依存関係をインストール
make run Q="search foo"  # Alfred をローカルでシミュレート
make test             # テスト実行
make lint             # ruff + black チェック
make typecheck        # mypy
make build            # dist/*.alfredworkflow を生成
make vendor           # workflow/vendor/ を更新
```

## リリース手順

```bash
# pyproject.toml のバージョンを更新
git tag v1.2.3
git push --tags
# GitHub Actions が .alfredworkflow を生成して GitHub Release を作成
```

---

*このファイルは `docs/dev-charter/` の内容をプロジェクト向けにまとめたものです。
憲章が更新された場合（`git subtree pull`後）は、このファイルも更新してください。*
