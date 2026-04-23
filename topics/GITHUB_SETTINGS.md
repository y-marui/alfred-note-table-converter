# GitHub Repository Settings

GitHub リポジトリ設定の確認ガイド。テンプレートからプロジェクトを作成したとき、または新規リポジトリをセットアップする際に使用する。

## AI による設定適用

各セクションには `gh` コマンドまたは設定ファイルを記載している。AI がセットアップ・更新作業を行う場合は以下の方針で適用する。

- `gh` コマンドが使える場合（CLI 環境）：記載のコマンドを実行する
- `gh` が使えない場合（GitHub Copilot・ブラウザ操作など）：「確認場所」の UI パスから手動で設定する
- どちらの場合も、**設定を適用すること自体は必須**。コマンドが使えないことを理由にスキップしない

## Branch Protection (Ruleset)

[topics/CI_POLICY.md](CI_POLICY.md) で定義した Ruleset が正しく設定されているか確認する。

**確認場所:** GitHub リポジトリ → Settings → Rules → Rulesets

### Existing Ruleset Check

既存の設定状態に応じて対応が異なる：

| 状態 | 対応 |
|---|---|
| `main-protection` が存在する | 下記チェックリストで内容を確認する |
| 別名（`main`・`branch-protection` 等）の Ruleset が存在する | `main-protection` に改名し、内容を確認する |
| Classic branch protection が設定されている | 削除して `main-protection` Ruleset を新規作成する（Classic は機能が限定的） |
| 何も設定されていない | `main-protection` Ruleset を新規作成する |

> **Classic branch protection について:** GitHub の旧来の "Branch protection rules"（Settings → Branches）は機能が限定的で、Ruleset への移行が推奨される。Classic と Ruleset が両方設定されている場合は Classic を削除して Ruleset に一本化する。

### Content Checklist

設定値・ルール一覧は [CI_POLICY.md](CI_POLICY.md) の「Branch Protection Ruleset」セクションを参照。

確認ポイント：

- `Enforcement` が `Active` になっているか（`Evaluate` / `Disabled` は機能しない）
- Status check のソースが `GitHub Actions` に設定されているか（`Any source` にしない）

## Pull Request Merging

**確認場所:** GitHub リポジトリ → Settings → General → Pull Requests

### Automatically Delete Head Branches

**設定値: ON（必ず有効にする）**

PR マージ後にリモートブランチを自動削除する。マージ済みブランチが蓄積してリポジトリが汚れるのを防ぐ。

```bash
gh api -X PATCH repos/{owner}/{repo} -f delete_branch_on_merge=true
```

> 誤って削除した場合は、マージ直後に限り GitHub の "Restore branch" ボタンから復元できる。

> **注意:** Classic branch protection（Settings → Branches）が残っている場合は削除すること。Classic BP はデフォルトでブランチ削除を禁止するため、自動削除が機能しない。Ruleset への移行手順は上記「[Branch Protection (Ruleset)](#branch-protection-ruleset)」セクションを参照。

### Allow Auto-merge

**設定値: ON（推奨）**

PR がすべてのステータスチェックを通過したとき自動マージできる機能を有効にする。Dependabot PR などの bot が作成する PR を自動処理する際に有用。

```bash
gh api -X PATCH repos/{owner}/{repo} -F allow_auto_merge=true
```

> この設定を ON にしても各 PR が自動でマージされるわけではない。PR ごとに "Enable auto-merge" を選択した場合のみ自動マージが走る。

## Actions: Workflow permissions

**確認場所:** GitHub リポジトリ → Settings → Actions → General → Workflow permissions

### Workflow permissions（デフォルト権限）

**設定値:** `Read repository contents and packages permissions`（デフォルト）のまま使う。

リポジトリレベルの権限は Read only のままにしておき、書き込みが必要なワークフローでは workflow ファイル内で `permissions` を個別に指定する。

```yaml
# 例: update-version.yml でコミット・プッシュする場合
permissions:
  contents: write
```

個別指定はリポジトリのデフォルト設定より優先されるため、グローバルを変更する必要はない。

### Allow GitHub Actions to create and approve pull requests

**設定値:** dev-charter を導入するリポジトリでは **ON にする**。

`check-charter.yml` は `gh pr create` でプルリクエストを作成するため、このチェックボックスが OFF のままだとワークフローが失敗する。

```bash
gh api -X PUT repos/{owner}/{repo}/actions/permissions/workflow \
  -F can_approve_pull_request_reviews=true
```

> このチェックボックスはリポジトリ作成時にデフォルトで OFF。`check-charter.yml` を導入する際は必ず ON になっているか確認すること。

## PR Review Assignment (CODEOWNERS)

GitHub Dashboard の "Needs your review" を機能させるために CODEOWNERS を設定する。

**ファイルパス:** `.github/CODEOWNERS`

```
* @your-github-username
```

`*` はリポジトリ全体を対象にする。Bot PR（Dependabot など）・他者の PR・自分の PR のすべてで、オーナーがコードレビュアーとして自動追加される。

### Require a review from Code Owners との違い

**レビュアー自動追加**（Dashboard 表示）は CODEOWNERS ファイルがあれば Ruleset 設定に関係なく動作する。

Ruleset の "Require a review from Code Owners"（`require_code_owner_review`）は別機能で、**マージ時に code owner の承認を必須にするか**を制御する。

| 設定 | 効果 |
|---|---|
| OFF（推奨：個人開発） | PR 作成時にレビュアー自動追加のみ。マージは承認なしでも可 |
| ON | code owner の承認がないとマージ不可。自分が唯一の code owner の場合、自分の PR は自己承認できないため詰まる |

個人開発リポジトリでは **OFF のまま**使う。

## Issue Auto-assign

リポジトリオーナーが Issue を作成したときに自動で自分にアサインする。
GitHub Dashboard の "Assigned to me" に即座に表示されるようになる。

**ファイルパス:** `.github/workflows/auto-assign-self.yml`

```yaml
name: Assign self when I create an issue

on:
  issues:
    types: [opened, reopened]

jobs:
  assign:
    if: github.actor == github.repository_owner || endsWith(github.actor, '[bot]')
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.addAssignees({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              assignees: [context.repo.owner],
            })
```

`github.repository_owner` を使うことでユーザー名のハードコードが不要。
他者が Issue を作成した場合は `if` 条件が false になりスキップされる。

## Security & Analysis

**確認場所:** GitHub リポジトリ → Settings → Security & analysis

### Dependabot Alerts

**設定値: ON**

脆弱性のある依存パッケージを検出して通知する。パブリック・プライベートリポジトリ問わず無料。

```bash
gh api -X PUT repos/{owner}/{repo}/vulnerability-alerts
```

### Dependabot Security Updates

**設定値: ON**

Dependabot が脆弱性を検出したとき、修正 PR を自動作成する。

```bash
gh api -X PUT repos/{owner}/{repo}/automated-security-fixes
```

### Secret Scanning & Push Protection

**設定値: ON**

コミット・コードにシークレット（API キー等）が含まれていないか検出する。Push protection は push 時点でブロックする。

```bash
gh api -X PATCH repos/{owner}/{repo} \
  -f 'security_and_analysis[secret_scanning][status]=enabled' \
  -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'
```

> **注意:** プライベートリポジトリでの secret scanning は GitHub Advanced Security が必要（有料）。パブリックリポジトリは無料で使用できる。

## Sponsors (FUNDING.yml)

GitHub Sponsors の設定状態はリポジトリの種別（テンプレート / プロジェクト）によって異なる。

| リポジトリ種別 | Features: Sponsorships | `.github/FUNDING.yml` の状態 | Sponsor ボタン |
|---|---|---|---|
| テンプレートリポジトリ | OFF | `[USERNAME]` プレースホルダーのまま | 非表示（意図的） |
| プロジェクトリポジトリ | ON | 実際のユーザー名に置換済み | 表示される |

### Template Repository

- `.github/FUNDING.yml` に `[USERNAME]` が残っている状態でよい
- Settings → Features → Sponsorships は OFF のまま（プロジェクト側で設定する）

### Project Repository

テンプレートからプロジェクトを作成した段階で、以下を両方実施する：

**1. GitHub リポジトリ設定で Sponsorships を有効化**

Settings → Features → Sponsorships にチェックを入れる。

**2. FUNDING.yml のプレースホルダーを置換**

- [ ] `.github/FUNDING.yml` の `[USERNAME]` を実際の GitHub ユーザー名（および Buy Me a Coffee のユーザー名）に置き換えた
- [ ] リポジトリページの右カラムに「Sponsor」ボタンが表示されている

```yaml
# Before（テンプレート）
github: [USERNAME]
buy_me_a_coffee: [USERNAME]

# After（プロジェクト）
github: your-github-username
buy_me_a_coffee: your-buymeacoffee-username
```

**Settings の Sponsorships と FUNDING.yml の両方が必要。** どちらか片方だけでは Sponsor ボタンが表示されない。

FUNDING.yml の詳細は [MONETIZATION_POLICY.md](../MONETIZATION_POLICY.md) を参照。
