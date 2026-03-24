# GitHub テンプレートリポジトリ規約

GitHub で新規テンプレートリポジトリを作成する際に従う規約。
他の憲章ドキュメントが複数プロジェクト横断の原則を定めるのに対し、このドキュメントはテンプレートリポジトリという特定の形態に限定した個別規約である。

---

## 1. 開発対象の定義

テンプレートリポジトリを作成する前に、以下を明記する。

| 項目 | 定義すべき内容 | 例 |
|---|---|---|
| 対象プラットフォーム | どの環境向けのテンプレートか | iOS app / Python package / Chrome extension |
| 技術スタック | 使用言語・FW・最低バージョン | Swift 5.9 / iOS 17 / SwiftUI |
| テンプレートの用途 | このテンプレートから何を作るか | 個人向け iOS アプリの雛形 |
| ビルド成果物 | 成果物の有無と形式 | あり（.app / .ipa）/ なし |

これらを `README-jp.md` のメタ情報テーブルに記載することで、利用者がテンプレートの用途を一目で判断できるようにする。

---

## 2. 開発環境の定義

### 2.1 人員・体制

テンプレートリポジトリの `README-jp.md` に以下を明記する。

| 項目 | 選択肢 | 記載方法 |
|---|---|---|
| 規模 | 個人 / 小規模チーム（1〜3人）/ OSS（メンテナ複数）/ 受託 | メタ情報テーブルの「開発環境」欄 |
| 意思決定 | 個人完結 / チーム合議 | 体制が複数人の場合のみ記載 |

### 2.2 使用 AI ツール

テンプレートが AI 支援開発を前提とする場合、使用する AI ツールとその役割をリポジトリに明示する。

**記載場所:** `AI_CONTEXT.md` の「AI ツール分担」セクション、および `README-jp.md` のメタ情報テーブル（オプション行）

| AI ツール | 標準的な役割 |
|---|---|
| Claude Code | 構成変更・大規模実装・アーキテクチャ設計 |
| GitHub Copilot | 細かな実装補助・テスト作成・typo 修正 |
| Gemini CLI | ドキュメント生成・翻訳補助（手動呼び出し） |

AI ツールを使用しない場合は「なし」と明記する。使用するツールのみ記載し、未使用ツールは省略する。

### 2.3 使用ソフトウェア・ツール

開発に必要なソフトウェアは `README-jp.md` の「動作要件」または「クイックスタート」に記載する。

**必須記載事項:**
- IDE・エディタ（バージョン指定）
- ランタイム・SDK（例: Xcode 15+、Python 3.11+）
- パッケージマネージャ（例: Homebrew、pip、npm）
- セキュリティフック（pre-commit を使用する場合）

---

## 3. 言語ポリシー

テンプレートリポジトリの言語は [LANGUAGE_POLICY.md](LANGUAGE_POLICY.md) に従う。テンプレート固有の追加ルールを以下に定める。

### 3.1 ドキュメント言語

| 用途 | 言語 | 根拠 |
|---|---|---|
| クローズドプロジェクト向けテンプレート | 日本語（正本）+ 英語（参照） | LANGUAGE_POLICY.md §1 |
| OSS・公開テンプレート | 英語（正本）+ 日本語（参照） | LANGUAGE_POLICY.md §2 |

### 3.2 コード内の言語

| 対象 | ルール |
|---|---|
| 識別子（変数名・関数名・クラス名） | 英語のみ |
| コードコメント | 主言語（日本語 or 英語）に統一 |
| コミットメッセージ | 英語（Conventional Commits 形式） |
| Issue / PR タイトル | 日本語可（クローズド）/ 英語推奨（OSS） |

### 3.3 README の言語対応

- 日本語正本: `README-jp.md`
- 英語版（参照）: `README.md`
- 両ファイルは**同一コミットで更新**する
- 冒頭に正本・参照の宣言を必ず記載する（下記参照）

**日本語版冒頭:**
```
> **このファイルは正本（日本語版）です。**
> 英語版（参照）は [README.md](README.md) を参照してください。
```

**英語版冒頭:**
```
> **This is the reference (English) version.**
> The canonical (Japanese) version is [README-jp.md](README-jp.md).
```

---

## 4. ライセンス

### 4.1 LICENSE ファイルの必須化

すべてのテンプレートリポジトリに `LICENSE` ファイルを含める。ライセンスなしでの公開は禁止。

### 4.2 ライセンスの選択基準

| 公開形態 | 推奨ライセンス | 備考 |
|---|---|---|
| OSS・公開テンプレート | MIT | 利用者が制限なく使えるよう MIT を基本とする |
| クローズド・社内限定 | All Rights Reserved | カスタム著作権表記を使用 |
| 商用利用を制限したい場合 | CC BY-NC 4.0 など | ドキュメント系テンプレートに限る |

### 4.3 All Rights Reserved テンプレート

クローズドプロジェクト向けには以下の形式を `LICENSE` ファイルとして使用する。

```
Copyright (c) [YEAR] [AUTHOR]

All rights reserved.

This software and associated documentation files are proprietary and
confidential. Unauthorized copying, distribution, modification, or use
of this software, in whole or in part, is strictly prohibited without
the express written permission of the author.
```

### 4.4 MIT テンプレート

OSS テンプレートには以下の形式を使用する。

```
MIT License

Copyright (c) [YEAR] [AUTHOR]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 5. README 整備規約

### 5.1 必須ファイル

| ファイル | 必須 | 内容 |
|---|---|---|
| `README-jp.md` | ✅ | 日本語版（正本） |
| `README.md` | ✅ | 英語版（参照） |
| `LICENSE` | ✅ | §4 に従ったライセンス |
| `AI_CONTEXT.md` | AI 対応時 | AI ツール向けコンテキスト |
| `CLAUDE.md` | Claude Code 使用時 | `@AI_CONTEXT.md` を記載 |
| `.github/copilot-instructions.md` | Copilot 使用時 | AI_CONTEXT.md の内容をコピー |

### 5.2 README の必須セクション（順序厳守）

1. **タイトル** — `# [技術名] [種類] Template` の形式
2. **言語宣言** — 正本・参照の宣言（§3.3 の形式）
3. **バッジ** — CI バッジ（GitHub Actions がある場合）＋ ライセンスバッジ
4. **一行概要** — 「[技術スタック]で[開発対象]を作るためのテンプレート。[開発環境]向け。」
5. **メタ情報テーブル** — 開発対象・開発環境・主言語（+ オプション: AI ツール・動作環境）
6. **特徴** — 5〜8 項目、`✅` チェックマーク必須、技術名は具体的に
7. **クイックスタート** — `git clone` から始め、環境構築コマンドまで
8. **コマンド一覧** — Makefile に 3 つ以上のターゲットがある場合
9. **プロジェクト構造** — `tree` コマンドベース、3 階層まで、主要ディレクトリにコメント
10. **ドキュメント索引** — `docs/architecture.md`・`docs/development.md` は最低限必須
11. **ライセンス** — ライセンス名と `LICENSE` ファイルへのリンク

### 5.3 条件付きセクション

以下のセクションは条件を満たす場合のみ追加する。

| セクション | 挿入条件 | 挿入位置 |
|---|---|---|
| 動作要件 | 複数プラットフォーム、または依存関係が 3 つ以上 | 「特徴」の直後 |
| インストール | ビルド成果物あり + OSS 公開 | 「一行概要」の直後 |
| 使い方 | CLI / ワークフロー / 拡張機能でコマンド体系がある | 「クイックスタート」の直後 |
| カスタマイズ手順 | 初回セットアップで必須の編集がある | 「ドキュメント索引」の直後 |
| AI 支援開発 | Claude Code / Copilot を使用 + `AI_CONTEXT.md` が存在 | 「ドキュメント索引」の直後 |
| リリース手順 | ビルド成果物あり + 配布プロセスがある | 「ライセンス」の直前 |

### 5.4 AI が README を生成する際の情報収集

AI は README 生成前に以下を確認する。情報が不足している場合は推測せずユーザーに質問すること。
既存ファイル（`Package.swift`、`pyproject.toml` 等）から判定可能な項目は自動入力してよい。

```
README 生成に必要な情報を教えてください:
1. 開発対象: [iOS app / Python package / Chrome extension 等]
2. 開発環境: [個人 / 小規模チーム(1-3人) / OSS / 受託]
3. 主言語: [日本語 / 英語]
4. リポジトリ名: [例: swift-app-template]
5. 技術スタック: [例: Swift 5.9 / iOS 17 / SwiftUI]
6. ビルド成果物: [あり(.app / .zip 等) / なし]
7. AI 対応: [Claude Code / GitHub Copilot / なし]
```

### 5.5 検証チェックリスト

README 作成後、以下を確認する。

```
[ ] 必須セクション（§5.2）が全て存在し、順序通りか
[ ] 言語宣言が主言語（日本語 / 英語）と一致しているか
[ ] メタ情報テーブルに開発対象・開発環境・主言語の 3 フィールドがあるか
[ ] 特徴セクションが 5〜8 項目か
[ ] プロジェクト構造にコメントが付いているか
[ ] ドキュメント索引に最低 2 つのリンクがあるか
[ ] LICENSE ファイルが存在し、README からリンクされているか
[ ] 日本語版・英語版が同一コミットで更新されているか
[ ] 変数の置換漏れ（[user]、[repo]、[YEAR] 等）がないか
```

---

## 6. テンプレートリポジトリの作成手順

1. GitHub で **"New repository"** → **"Template repository"** にチェックを入れる
2. §1 に従い開発対象・技術スタックを決定する
3. §2 に従い開発環境・AI ツール・使用ソフトウェアを定義する
4. §3 に従い言語ポリシーを決定する
5. §4 に従い `LICENSE` ファイルを作成する
6. §5 に従い `README-jp.md`（日本語正本）と `README.md`（英語版）を作成する
7. AI 対応の場合は `AI_CONTEXT.md` と `CLAUDE.md` を作成する
8. `.github/copilot-instructions.md` を作成する（Copilot 使用時）
