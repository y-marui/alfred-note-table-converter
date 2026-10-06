# Project README Guidelines

テンプレートから作成したプロジェクトの README に含めるべき内容を定める。
主に AI ツールが参照し、README の作成・更新時の判断基準として使用する。

テンプレートリポジトリ自体の README 設計は [TEMPLATE_README_GUIDELINES.md](TEMPLATE_README_GUIDELINES.md) を参照。

> **AI への注意:** テンプレートから作成した直後のプレースホルダ置換・メタ情報更新等の初期セットアップ手順は、プロジェクトの `AI_CONTEXT.md` に記載すること。このドキュメントはプロジェクト README の構成定義に専念する。

---

## 1. Required Sections (Follow Order)

1. **タイトル** — プロジェクト名
2. **言語宣言** — 正本・参照の宣言（[LANGUAGE_POLICY.md](../LANGUAGE_POLICY.md) `### When Using Separate Files` 参照）
3. **バッジ** — ライセンス → CI（GitHub Actions がある場合のみ）→ dev-charter（導入済みの場合）の順で配置（§7 参照）
4. **一行概要** — 「何を・誰のために・どう解決するか」を 1 文で
5. **セットアップ** — ビルド・インストール手順（§2 参照）
6. **使い方** — 主なコマンド・操作フロー（§3 参照）
7. **ライセンス** — ライセンス名と `LICENSE` ファイルへのリンク

---

## 2. Setup Section

「動かせる状態」になるまでの最小手順を記載する。終点の定義は対象によって異なる。

| 対象 | セットアップの終点 |
|---|---|
| iOS / Mac アプリ | ビルド成功 → Simulator / 実機で起動 |
| Python app / library | `pip install -e .`（または `uv sync`）→ 動作確認コマンド実行 |
| Chrome 拡張 | `npm run build` → `chrome://extensions` でロード完了 |
| Alfred ワークフロー | `.alfredworkflow` をダブルクリック → Alfred に読み込み完了 |

**必須記載:**
- 依存関係のインストールコマンド
- ビルドコマンド（成果物がある場合）
- 初回設定（環境変数・設定ファイル等）

**記載しない:**
- テンプレート固有のカスタマイズ手順
- プレースホルダ置換手順（AI_CONTEXT.md に記載）

---

## 3. Usage Section

日常的な操作に必要なコマンド・フローを記載する。

**対象別の記載内容:**

| 対象 | 記載する内容 |
|---|---|
| CLI ツール / スクリプト | 主要コマンドと代表的なオプション |
| GUI アプリ（iOS / Mac） | 典型的な操作フロー。スクリーンショットは任意。 |
| ライブラリ / API | インポートから結果表示までの最小コードスニペット |
| Chrome 拡張 | 拡張アイコンのクリック方法・ポップアップ操作・設定項目 |
| Alfred ワークフロー | キーワード・ホットキー等のトリガー方法と設定項目 |

**コマンド一覧の形式（管理コマンドが 3 つ以上ある場合）:**

`make` / `npm run` / `invoke` 等ツールを問わず、以下の形式で表形式にまとめる。

| コマンド | 説明 |
|---|---|
| `make test` | テスト実行 |
| `make build` | ビルド |
| `make lint` | リント |

---

## 4. Notes (Optional)

以下の場合のみ追加する。不要な場合はセクションごと省略する。

| 追加条件 | 内容 |
|---|---|
| 既知の制約・ハマりポイントがある | 具体的な回避策とともに記載 |
| プラットフォーム固有の注意点がある | 対象プラットフォームを明示して記載 |
| 破壊的操作がある | 警告と安全な代替手段を記載 |

---

## 5. Conditional Sections

以下のセクションは条件を満たす場合のみ追加する。

| セクション | 挿入条件 | 挿入位置 |
|---|---|---|
| 動作要件 | 複数プラットフォーム対応、または依存関係が 3 つ以上 | 「一行概要」の直後 |
| 設定リファレンス | 設定ファイル・環境変数が 3 つ以上ある場合 | 「セットアップ」の直後 |
| API リファレンス | ライブラリで公開 API がある場合 | 「使い方」の直後 |
| プロジェクト構造 | 複数ディレクトリで構成される、または構造の把握がセットアップに必要な場合 | 「セットアップ」の直後 |
| ドキュメント索引 | `docs/` 配下にドキュメントが存在する場合 | 「使い方」の直後 |
| Contributing | OSS で外部コントリビューターを想定する場合 | 「ライセンス」の直前 |
| Changelog | リリース管理がある場合 | 「ライセンス」の直前 |

プロジェクト構造は `tree` コマンドベース（3 階層まで）で出力し、主要ディレクトリにコメントを付ける。

---

## 6. Initial Setup: Placeholder Replacement

テンプレートから作成した直後に、以下のプレースホルダをプロジェクトに合わせて置き換える。

| プレースホルダ | 置換先 | 対象ファイル |
|---|---|---|
| `[YEAR]` | 現在の年 | `LICENSE` |
| `[AUTHOR]` | 著作権者名 | `LICENSE` |
| `[USERNAME]` | GitHub ユーザー名 | `.github/FUNDING.yml`・サポートバッジ |
| `[BMC_USERNAME]` | Buy Me a Coffee ユーザー名 | `.github/FUNDING.yml`・サポートバッジ |
| `{user}` / `{repo}` / `{workflow}` | このプロジェクトのリポジトリ情報 | `README-jp.md`・`README.md`（CI バッジ） |

### License

ライセンスの引き継ぎ・変更も初期セットアップ時に決定する。

| ケース | 対応 |
|---|---|
| テンプレートのライセンスを引き継ぐ | `[YEAR]` と `[AUTHOR]` を更新するだけでよい |
| ライセンスを変更する | [LEGAL_POLICY.md](../LEGAL_POLICY.md) を参照してライセンスを選択し、`LICENSE` ファイルを差し替える |

README のライセンスセクション・ライセンスバッジは選択したライセンスと一致させること。

---

## 7. Badge Format

バッジは**言語宣言の直後**（§1 位置 3）に、**ライセンス → CI → dev-charter** の順で配置する。

**ライセンスバッジ（プロジェクトの実際のライセンスに対応する行を使用）:**

| ライセンス | バッジ |
|---|---|
| MIT | `[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)` |
| All Rights Reserved | `[![License: All Rights Reserved](https://img.shields.io/badge/License-All%20Rights%20Reserved-red.svg)](LICENSE)` |
| AGPL v3 | `[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](LICENSE)` |
| GPL v3 | `[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)` |
| LGPL v3 | `[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-blue.svg)](LICENSE)` |
| CC BY 4.0 | `[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](LICENSE)` |
| CC BY-SA 4.0 | `[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](LICENSE)` |
| CC BY-ND 4.0 | `[![License: CC BY-ND 4.0](https://img.shields.io/badge/License-CC%20BY--ND%204.0-lightgrey.svg)](LICENSE)` |
| CC BY-NC-SA 4.0 | `[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](LICENSE)` |
| CC BY-NC-ND 4.0 | `[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC%20BY--NC--ND%204.0-lightgrey.svg)](LICENSE)` |

ライセンスバッジのリンク先は常にリポジトリルートの `LICENSE` ファイル。テンプレートと異なるライセンスを選択した場合はバッジも変更すること。

**CI バッジ:**

```
[![CI](https://github.com/{user}/{repo}/actions/workflows/{workflow}.yml/badge.svg)](https://github.com/{user}/{repo}/actions/workflows/{workflow}.yml)
```

⚠️ テンプレートから作成した場合、CI バッジの URL はテンプレートリポジトリを指したままになる。**このプロジェクト固有の `{user}` / `{repo}` / `{workflow}` に必ず更新すること。**

**dev-charter バッジ（dev-charter を導入済みの場合）:**

```
[![Charter Check](https://github.com/{user}/{repo}/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/{user}/{repo}/actions/workflows/dev-charter-check.yml)
```

`{user}` / `{repo}` をこのプロジェクトのリポジトリ情報に置き換える。

**サポートバッジ（GitHub で公開しているプロジェクトの場合）:**

dev-charter バッジの後に、GitHub Sponsors と Buy Me a Coffee のバッジを追加する。
サポートセクションは README に設けず、バッジで代替する。
バッジの URL は `.github/FUNDING.yml` の設定と一致させること（[MONETIZATION_POLICY.md](../MONETIZATION_POLICY.md) 参照）。

```
[![GitHub Sponsors](https://img.shields.io/github/sponsors/[USERNAME]?style=social)](https://github.com/sponsors/[USERNAME])
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-donate-yellow.svg)](https://www.buymeacoffee.com/[BMC_USERNAME])
```

`[USERNAME]` を GitHub ユーザー名、`[BMC_USERNAME]` を Buy Me a Coffee のユーザー名に置き換える（`~/.identity/accounts.yaml` 参照）。

---

## 8. Sections NOT Needed

プロジェクト README には不要（テンプレート固有）:

- テンプレートのメタ情報テーブル（詳細版）
- 「このテンプレートを使う」ボタン・クローン手順
- テンプレートのカスタマイズ手順
- 特徴セクションの `✅` リスト（プロジェクト固有の特徴に書き換えるか、一行概要に統合する）

---

## 9. AI Info Gathering

AI は README 生成前に以下を確認する。情報が不足している場合は推測せずユーザーに質問すること。既存ファイル（`pyproject.toml`・`Package.swift`・`manifest.json` 等）から判定可能な項目は自動入力してよい。

```
PROJECT README 生成に必要な情報を教えてください:
1. 対象種別: [iOS/Mac アプリ / Python app / Python library / Chrome 拡張 / Alfred ワークフロー]
2. インストール・入手方法: [pip install / App Store / Chrome Web Store / ローカルビルドのみ 等]
3. 主な操作・コマンド（使い方セクションの内容）:
4. 注意点・既知の制約（あれば）:
```

---

## 10. Validation Checklist

README 作成・更新後に確認する。⚠️ は人間による確認が必要な項目。

```
[ ] 必須セクション（§1）が全て存在し、順序通りか
[ ] CI バッジの URL がこのプロジェクトリポジトリを指しているか（テンプレートの URL のままになっていないか）
[ ] dev-charter を導入済みの場合、charter-check バッジが存在するか（§7 参照）
[ ] ライセンスバッジ・READMEライセンスセクション・LICENSE ファイルが三者一致しているか
[ ] ⚠️ 一行概要がテンプレートの説明ではなくプロジェクト固有の説明になっているか
[ ] ⚠️ セットアップ手順でプロジェクトが実際に動作するか（人間による動作確認）
[ ] プレースホルダが全て置換されているか（§6 参照）: [YEAR]・[AUTHOR]（LICENSE）、[USERNAME]・[BMC_USERNAME]（FUNDING.yml・サポートバッジ）、{user}/{repo}/{workflow}（CI バッジ）
[ ] プロジェクト構造セクションを追加すべき条件（§5）に該当する場合、記載されているか
[ ] ドキュメント索引のリンクが実在するファイルを指しているか
[ ] 日本語版・英語版が同一コミットで更新されているか
[ ] bilingual 文書の末尾に編集ルールフッターがあるか
```
