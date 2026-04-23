# Dev Charter (開発憲章)

> **このファイルは正本（日本語版）です。**
> 英語版（参照）は [README.md](README.md) を参照してください。

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](LICENSE)
[![check-charter CI](https://github.com/y-marui/dev-charter/actions/workflows/check-charter.yml/badge.svg)](https://github.com/y-marui/dev-charter/actions/workflows/check-charter.yml)

AI支援ソフトウェアプロジェクトのための共有開発憲章。

このリポジトリは、プロジェクト横断的に使用される共通の哲学、アーキテクチャ原則、
および開発ルールを定義します。

## Documents

| ファイル | 内容 |
|---|---|
| [CHARTER_INDEX.md](CHARTER_INDEX.md) | 憲章ドキュメントのインデックス（トピック → ファイル対応表） |
| [PRINCIPLES.md](PRINCIPLES.md) | 開発哲学・デザイン・アーキテクチャ原則 |
| [CODE_STYLE.md](CODE_STYLE.md) | コードスタイル |
| [AI_COLLABORATION_RULES.md](AI_COLLABORATION_RULES.md) | AI 協働ルールと役割分担 |
| [AI_CONTEXT_HIERARCHY.md](AI_CONTEXT_HIERARCHY.md) | AI コンテキスト優先階層 |
| [AI_TOOL_SETUP.md](AI_TOOL_SETUP.md) | AI コンテキストファイルの構成仕様（AI_CONTEXT.md・各ツール設定ファイル） |
| [DOCS_STRUCTURE.md](DOCS_STRUCTURE.md) | プロジェクトのドキュメント構成（root ファイル・DEVELOPING.md/CONTRIBUTING.md の責務分離・docs/ 標準構成・AI_CONTEXT.md 参照順） |
| [LANGUAGE_POLICY.md](LANGUAGE_POLICY.md) | 言語ポリシー（正本＝日本語） |
| [LOCALIZATION_POLICY.md](LOCALIZATION_POLICY.md) | ローカライゼーションポリシー |
| [PROJECT_LIFECYCLE.md](PROJECT_LIFECYCLE.md) | プロジェクトライフサイクルと体制 |
| [UI_GUIDELINES.md](UI_GUIDELINES.md) | UI ガイドライン・カラー・アイコン |
| [MONETIZATION_POLICY.md](MONETIZATION_POLICY.md) | マネタイズポリシーとプラットフォーム別方針 |
| [SECURITY_POLICY.md](SECURITY_POLICY.md) | セキュリティポリシーとフック設定リファレンス |
| [LEGAL_POLICY.md](LEGAL_POLICY.md) | ライセンス選択基準・テンプレート（Closed / MIT / AGPL・GPL・LGPL） |
| [topics/CI_POLICY.md](topics/CI_POLICY.md) | CI job設計方針・Branch Protection Ruleset |
| [topics/GITHUB_SETTINGS.md](topics/GITHUB_SETTINGS.md) | GitHub リポジトリ設定確認（Ruleset・Sponsors） |
| [topics/GITHUB_CONTRIBUTING.md](topics/GITHUB_CONTRIBUTING.md) | Issue・PR・CONTRIBUTING.md・PRテンプレート・準CLA（OSS向け） |
| [topics/TEMPLATE_README_GUIDELINES.md](topics/TEMPLATE_README_GUIDELINES.md) | GitHub テンプレートリポジトリの README 設計規約（開発環境・言語・LICENSE・必須セクション） |
| [topics/PROJECT_README_GUIDELINES.md](topics/PROJECT_README_GUIDELINES.md) | テンプレートから作成したプロジェクトの README 整備手順 |
| [topics/PYTHON_DEV_ENV.md](topics/PYTHON_DEV_ENV.md) | Python 開発環境構成（pyenv・uv・ruff・mypy・pytest） |
| [topics/PYTHON_CLI.md](topics/PYTHON_CLI.md) | Python CLI 実装方針（typer・pydantic-settings・XDG設定） |

## How to Use

1. `git subtree` で `docs/dev-charter/` に取り込む
2. AI に dev-charter を読ませ、プロジェクトルートに `AI_CONTEXT.md` と AI ツール設定ファイルを生成させる
3. 憲章が更新されたら `git subtree pull` 後、AI にコンテキストファイルを追従させる

構成仕様は [AI_TOOL_SETUP.md](AI_TOOL_SETUP.md) を参照。

## Quick Install

プロジェクトのルートで実行してください：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

スクリプトが git subtree のセットアップを自動化し、Claude Code が利用可能であれば
初回セットアップ（INSTALL_CHECKLIST）の起動まで案内します。

> **Note:** インストール先やブランチを変更する場合は環境変数で指定できます：
> `CHARTER_PREFIX=path/to/charter bash <(curl -fsSL .../install.sh)`

## Install (git subtree)

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter main --squash
```

インストール後、以下のプロンプトを AI ツールに貼り付けてください：

```
docs/dev-charter/INSTALL_CHECKLIST.md を実行して
```

## Update

`dev-charter` リモートが未設定の場合（プロジェクトを clone した直後など）は先に追加する：

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```

> **Note（テンプレートリポジトリから作成したプロジェクト）:**
> GitHub テンプレートはファイルのみコピーし git 履歴を引き継がないため、`git subtree pull` は失敗します。
> `check-charter.yml` ワークフローがこのケースを自動検出して対処します。
> 手動で更新する場合は `git subtree pull` の代わりに以下を実行してください：
> ```bash
> git remote add dev-charter https://github.com/y-marui/dev-charter || true
> git fetch dev-charter
> SPLIT=$(git rev-parse dev-charter/main)
> rm -rf docs/dev-charter/
> mkdir -p docs/dev-charter/
> git archive dev-charter/main | tar -x -C docs/dev-charter/
> git add docs/dev-charter/
> git commit -m "Squashed 'docs/dev-charter/' content from commit ${SPLIT}
>
> git-subtree-dir: docs/dev-charter
> git-subtree-split: ${SPLIT}"
> ```

更新後、以下のプロンプトを AI ツールに貼り付けてください：

```
docs/dev-charter/UPDATE_CHECKLIST.md を実行して
```

## Makefile Helper

```
update-charter:
	git remote | grep -q '^dev-charter$$' || \
	  git remote add dev-charter https://github.com/y-marui/dev-charter
	git fetch dev-charter
	git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```

## Version Check (CI)

`.github/workflows/dev-charter-check.yml` をプロジェクトに追加すると、
毎週自動で最新バージョンを確認し、古い場合は update PR を作成します。

```yaml
name: Dev Charter
on:
  schedule:
    - cron: "23 3 * * 1"  # 毎週月曜 3:23 UTC — minute/hour/day-of-week はランダムな値に変更してください
  workflow_dispatch:

jobs:
  check:
    name: Check
    uses: y-marui/dev-charter/.github/workflows/check-charter.yml@main
    permissions:
      contents: write
      pull-requests: write
```

> **Note:** Branch Protection で direct push が禁止されている場合は、
> GitHub Actions bot の bypass rule を追加してください
> （Settings > Rules > Rulesets > Bypass list > GitHub Actions）。

## Badge for Adopting Projects

プロジェクトの README にこのバッジを追加すると、dev-charter の更新状態を可視化できます。

### Workflow Status Badge

dev-charter が最新かどうかを表示します。

```markdown
[![Charter Check](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml)
```

`{owner}` と `{repo}` を自分のリポジトリのオーナー名・リポジトリ名に置き換えてください。

| 状態 | Status Badge |
|---|---|
| 未導入 / CI 未設定 | 赤（VERSION not found） |
| 導入済み・最新 | 緑 |
| 導入済み・更新必要 | 赤 |

---

*この文書には英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
