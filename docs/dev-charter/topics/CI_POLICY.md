# CI Policy

> **TODO（暫定メモ、2026-08-19）:** `swift-closed-template` の `ci.yml` の `on:` に
> `develop` ブランチへの参照が残っているが、`develop` ブランチ運用は既にやめており
> （現存せず、`DEVELOPING.md` 等にも記載なし）、設定だけが取り残されている。
> `swift-closed-template` とそこから派生した各 swift-* リポジトリの `ci.yml` から
> 削除する。この CI ポリシー更新とは別作業として扱う。

## Naming Convention

| 対象 | 規則 | 例 |
|---|---|---|
| ワークフローファイル名 | 機能を表す小文字 + ハイフン | `ci.yml`, `charter-check.yml` |
| ワークフロー `name` | タイトルケース、短く端的に | `CI`, `Dev Charter` |
| job ID | 小文字スネークケース | `lint`, `test`, `build` |
| job `name` | タイトルケース。追加説明が必要な場合は括弧付きで補足 | `Lint`, `Test`, `Test (pytest)`, `Build`, `Security scan (pre-commit)` |

### Standard Job Names

| job ID | `name` | 用途 |
|---|---|---|
| `security` | `Security scan (pre-commit)` | pre-commit によるシークレット検知・静的解析 |
| `lint` | `Lint` | コードスタイル・フォーマット検査 |
| `test` | `Test` / `Test (pytest)` など | ユニットテスト・インテグレーションテスト |
| `build`（任意） | `Build` | ビルド成果物の生成、またはインストール可能性の検証 |
| `gate` | ワークフロー自身の `name`（例：`CI`、`Dev Charter`） | 全 job の集約ゲート（後述）。必ず存在する |

`gate` は全 job の集約点として必ず最後に配置し、その `name` はワークフロー自身の `name`
（トップレベルの `name:`）と同じ文字列にする。Branch Protection（Ruleset）の必須ステータス
チェックには常にこの値（例：`ci.yml` なら `CI`）を登録する（`Build` ではない）。job 名に
`build` を使うのは、実際にビルド成果物を作る job（任意・実体のあるビルドがない場合は省略）だけ。

1リポジトリに複数のワークフローファイルがある場合（`ci.yml` と `dev-charter-check.yml` の
併用など）、各ワークフローの `name:` は互いに異なる値にする。`gate` の `name` をワークフロー
自身の `name` と一致させる規則により、複数の `gate` が同じチェック名を報告して Ruleset 上で
衝突する事態を自然に避けられる。

## Job Design

**CIのjob構成とRuleset設定を分離し、Ruleset管理を最小化する。**

- 集約ゲート `gate` job を必ず最後に配置し、`needs` で全依存を定義する
- 実体のあるビルド作業がある場合は `build` job を用意し、`gate` の `needs` に含める
- 単一job（lint/test 相当すら分けない極小プロジェクト）でも `gate` は省略しない。
  ビルド・検証の実処理をそのまま `gate` の中で行ってよい
  - **`*-template` リポジトリ（`git subtree pull` の取り込み元ではなく、GitHub の
    テンプレート機能や単純コピーで他プロジェクトの出発点として使われるリポジトリ）には
    この単一job省略を適用しない。** 単一jobが許されるのは、それ自体が完結した
    純粋に極小な**スタンドアロン**プロジェクトの場合のみ。`*-template`
    リポジトリはそこから実プロジェクトが構築される前提のため、最初から
    `security`/`lint`/`test`/`build`/`gate` の完全な構成にしておく方が良い出発点になる
    （単一jobのまま複製されると、後から分割する手間を新プロジェクト側に残してしまう）
- Ruleset設定：ワークフロー自身の `name`（`gate` job の `name` と一致）のみ指定（全リポジトリ共通）

この方針により、job を増減しても Ruleset の変更が不要になる（`gate` の `name` はワークフロー
自身の `name` に固定されており、job 構成の変更とは独立しているため）。

### `gate` Is a Gate, Not Just a `needs` Aggregation

> **注意（過去の誤り）:** 以前このドキュメントは、集約 job（当時は `build` という名前
> だった）について「いずれかの job が失敗すると skip され、マージ不可になる」と説明して
> いたが、これは誤り。GitHub の Ruleset / Branch Protection の `required_status_checks` は、
> 必須チェックが **`skipped` で完了した場合はブロックしない**（`failure` の場合のみ
> ブロックする）。集約 job が `needs: [security, lint, test]` のみで暗黙の `if: success()`
> に依存していると、依存 job が失敗したときに集約 job 自体は `skipped` として完了し、
> Ruleset 上は「必須チェックを満たした」と扱われて **失敗したままマージできてしまう**。
> 2026-08 に実際の運用で発覚した。

正しい実装は、`gate` を **常に実行するゲート job**（`if: always()`）にし、`needs.*.result`
を明示的に検査して `failure`/`cancelled` があれば自身を `failure` として終了させる。

```yaml
gate:
  name: CI   # ワークフロー自身の name: と同じ値にする
  needs: [security, lint, test]   # build 等があれば追加
  if: always()
  runs-on: ubuntu-latest   # ゲートは判定のみなので常に最安ランナーでよい
  steps:
    - name: Verify required jobs succeeded
      run: |
        for result in "${{ needs.security.result }}" "${{ needs.lint.result }}" "${{ needs.test.result }}"; do
          if [ "$result" != "success" ]; then
            echo "::error::a required job did not succeed (got: $result)"
            exit 1
          fi
        done
```

ビルド成果物の生成やインストール可能性の検証など、実体のあるビルド作業がある場合は、
それを `build` job に書き、`gate` の `needs` に追加する。`gate` 自体は判定専用に保ち、
`build`・`lint`・`test` と同じ高コストなランナー（`macos-latest` 等）で起動させない
（[Cost Optimization](#cost-optimization-path-filtering) 参照）。

```yaml
build:
  name: Build
  needs: [security, lint, test]
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - run: pip install -e .
    - run: python -c "import mypackage"

gate:
  name: CI
  needs: [security, lint, test, build]
  if: always()
  runs-on: ubuntu-latest
  steps:
    - name: Verify required jobs succeeded
      run: |
        for result in "${{ needs.security.result }}" "${{ needs.lint.result }}" "${{ needs.test.result }}" "${{ needs.build.result }}"; do
          if [ "$result" != "success" ]; then
            echo "::error::a required job did not succeed (got: $result)"
            exit 1
          fi
        done
```

**単一job（極小プロジェクト）：** ビルド・検証の実処理を `gate`（`name` はワークフロー自身の
`name` と同じ値、例：`CI`）の中に直接書く。job を分ける必要がないだけで、Ruleset に登録する
名前はワークフローの `name` のまま変わらない。**`*-template` リポジトリには適用しない**
（[Job Design](#job-design)参照）。

### Cost Optimization (Path Filtering)

`docs/**` や `*.md` のみの変更（例：`git subtree pull` による dev-charter 更新、README
の修正）では、`lint`/`test`/`build` のような高コストな job（特に `macos-latest`
等の高額ランナー）を実行する必要がない。

**ワークフロー単位の `paths-ignore` は使わない。** ワークフロー自体がトリガーされないと
必須ステータスチェックが一切報告されず、PR が `Expected — Waiting for status to be
reported` のまま永久にブロックされる（`gate` の `name`（ワークフロー自身の `name`）が
Ruleset の必須チェックである場合）。

代わりに [dorny/paths-filter](https://github.com/dorny/paths-filter) で変更内容を判定し、
**job-level の `if:`** で `lint`/`test`/`build` をスキップする。`security`
（pre-commit）は ubuntu-latest で安価な上、pre-commit 自身の `files:`/`types:` で
変更ファイルに応じて各フックが自動的にスキップされるため、job 単位でのフィルタは不要。

```yaml
on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

jobs:
  changes:
    name: Detect changes
    if: github.event_name != 'pull_request' || github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    outputs:
      code: ${{ steps.filter.outputs.code }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v4
        id: filter
        with:
          predicate-quantifier: 'some-with-excludes'
          filters: |
            code:
              - '**'
              - '!**/*.md'
              - '!docs/**'
              - '!LICENSE'
              - '!.gitignore'
              - '!.github/FUNDING.yml'
              - '!.github/CODEOWNERS'
              - '!.github/ISSUE_TEMPLATE/**'
              - '!.github/*_TEMPLATE.md'
              - '!.github/pull_request_template.md'
              - '!.github/copilot-instructions.md'
              - '!.github/workflows/dev-charter-check.yml'
              - '!.github/workflows/auto-assign-self.yml'

  security:
    name: Security scan (pre-commit)
    if: github.event_name != 'pull_request' || github.event.pull_request.draft == false
    runs-on: ubuntu-latest
    # パスでのフィルタなし。pre-commit 自身が変更ファイルに応じて自動スキップする
    # ...

  lint:
    name: Lint
    needs: changes
    if: needs.changes.outputs.code == 'true'
    # ...

  test:
    name: Test
    needs: changes
    if: needs.changes.outputs.code == 'true'
    # ...

  build:
    name: Build
    needs: [changes, security, lint, test]
    if: needs.changes.outputs.code == 'true'
    # ...

  gate:
    name: CI
    needs: [changes, security, lint, test, build]
    # draft は always() でも実行しない: draft はそもそもマージ不可なので、
    # チェックが未報告のままでも「詰まる」リスクがない（docs-only スキップとは
    # 違い、gate 自体を丸ごとスキップしてよい）
    if: always() && (github.event_name != 'pull_request' || github.event.pull_request.draft == false)
    runs-on: ubuntu-latest
    steps:
      - name: Verify required jobs succeeded
        run: |
          if [ "${{ needs.security.result }}" != "success" ]; then
            echo "::error::security did not succeed (got: ${{ needs.security.result }})"
            exit 1
          fi
          if [ "${{ needs.changes.outputs.code }}" != "true" ]; then
            echo "docs/config-only change; nothing further to verify"
            exit 0
          fi
          for result in "${{ needs.lint.result }}" "${{ needs.test.result }}" "${{ needs.build.result }}"; do
            if [ "$result" != "success" ]; then
              echo "::error::a required job did not succeed (got: $result)"
              exit 1
            fi
          done
```

### Draft PRs

`ready_for_review` を `on.pull_request.types` に加えた上で、`changes`・`security`・`gate`
に draft スキップの `if:` を付ける（`lint`/`test`/`build` は `changes` 経由で連鎖的に
スキップされる）。デフォルトの `pull_request` トリガーは `opened`/`synchronize`/`reopened`
のみで `ready_for_review` を含まないため、これを忘れると draft 解除時に再実行されず、
古い（未評価の）ステータスのまま残ってしまう。

`gate` を `if: always()` のままにせず draft でスキップしてよい理由：docs-only スキップは
「コードが変わっていないので中身の検証は不要だが、必須チェックとしての合否報告は必要」
（`gate` 自体は動いて `exit 0` する）。draft は「そもそも GitHub がマージを許可しない」ため、
必須チェックが一切報告されなくてもブロック待ちにならない。よって `gate` ごとスキップできる。

`.github/workflows/dev-charter-check.yml` も同様に draft をスキップする（[Version Check
(CI)](../README.md#version-check-ci) 参照）。

**依存ロックファイル（`uv.lock` / `package-lock.json` / `Package.resolved` 等）は
skip 対象に含めない。** ロックファイルの更新は依存パッケージのバージョン変更そのものであり、
実際に lint/test/build を回して初めて壊れていないか確認できる。Dependabot の PR を含め、
これらの変更は常にフル CI を実行する。

`Makefile` はほとんどのプロジェクトで CI から直接呼ばれない（`ci.yml` は各コマンドを直接
実行する）ため skip 対象に含めてよいが、CI が `make` 経由でビルド・テストを呼んでいる
プロジェクトでは対象から除外すること。

### Artifact Retention

| 対象 | 保持期間（目安） |
|---|---|
| PR | 短期（例：7日） |
| main | 長期（例：30日） |

## Dependabot

`.github/dependabot.yml` の導入を検討する。依存パッケージがあるプロジェクトでは自動でアップデートPRを作成し、脆弱性対応を省力化できる。ドキュメントのみのリポジトリや依存パッケージが存在しないプロジェクトでは不要。

## Branch Protection (Ruleset)

`main` ブランチに以下のRulesetを適用する（全リポジトリ共通）：

```
Name: main-protection
Target: main
Enforcement: Active

Rules:
☑ Require a pull request before merging
  └ Required approvals: 0（個人開発）/ 1以上（複数人）
☑ Require status checks to pass before merging
  └ Status checks: CI (GitHub Actions)
  └ Status checks: Dev Charter (GitHub Actions)
☑ Require conversation resolution before merging
☑ Block force pushes
☑ Restrict deletions
```

`Dev Charter` は `.github/workflows/dev-charter-check.yml`（[Version Check
(CI)](../README.md#version-check-ci) 参照）の `gate` job の `name`（ワークフロー自身の
`name: Dev Charter` と一致させたもの。[§ Naming Convention](#naming-convention)参照）。
同ワークフローの `check` job は `.github/workflows/dev-charter-check.yml` が呼び出す
再利用ワークフロー（`check-charter.yml`）で、Dependabot PR・draft PR では job-level の
`if:` でスキップされる。`ci.yml` とは別ワークフローファイルのため `gate` の `needs` には
含められない（`needs` は同一ワークフローファイル内でしか機能しない）ので、Ruleset には
別エントリとして登録する。`ci.yml` 側の `gate`（`name: CI`）と名前が異なるため、複数
ワークフローの `gate` を同一 Ruleset に登録しても衝突しない。

**`Check / check` を直接 Ruleset に登録してはいけない。** `check` は `uses:` で再利用
ワークフローを呼ぶ job のため、GitHub は再利用ワークフロー側の job が実際に開始されて
初めて `Check / check` という複合チェック名を生成する。job-level の `if:` が false（全
Dependabot PR）になると再利用ワークフローが一度も呼ばれず、`Check / check` というコンテ
キスト自体が `skipped` としてすら報告されない。Ruleset は `Check / check` が報告される
のを待ち続け、該当 PR は `Expected — Waiting for status to be reported` のまま永久に
ブロックされる（`gate` の `needs` を欠いた集約 job が `skipped` を `success` 扱いされる
[§ `gate` Is a Gate, Not Just a `needs` Aggregation](#gate-is-a-gate-not-just-a-needs-aggregation)
とは逆に、こちらは「単独 job をそのまま Ruleset に登録すると `skipped` が一切報告されない」
という別種の罠）。`gate` job（普通の job のため `check` の実行有無に関わらず必ず自身の
チェック名を報告する）を挟み、`needs.check.result` を検査して `skipped` は成功扱い、
`failure`/`cancelled` のみ失敗させることで回避する（実装は [Version Check
(CI)](../README.md#version-check-ci) のテンプレート参照。2026-08 に実際に発覚・修正、
詳細は [Issue #81](https://github.com/y-marui/dev-charter/issues/81)）。

`check` job（`check-charter.yml`）自体は「dev-charter が最新でない」場合も **意図的に
失敗する**（`update-charter` の draft PR を自動作成した上で `exit 1`）。schedule トリガー
が無くなり `pull_request`/`push` イベント駆動のみになったため、成功で終わらせてしまうと
更新 PR が誰にも気づかれないまま放置され、無関係な PR がどんどんマージされてしまう。失敗
させることで「今動いている PR/push」の場で必ず対応を迫る。`gate` はこの `failure` を
そのまま自身の失敗として伝播するため、Ruleset 上のブロック効果は維持される。

それ以外の失敗条件（リモート `VERSION` の取得失敗・ローカル `VERSION` の欠落・push や
PR 作成時のエラー・GitHub Actions の課金ブロックなど）ももちろん失敗する。

### Epic Branch Ruleset

複数ステップ・sub-issue を持つ大規模な改修用の `epic/<name>` ブランチ（[PROJECT_LIFECYCLE.md](../PROJECT_LIFECYCLE.md) の Branch Strategy 参照）にも、パターンマッチで `main-protection` と同じRulesetを適用する：

```
Name: epic-protection
Target: epic/*
Enforcement: Active

Rules:
☑ Require a pull request before merging
  └ Required approvals: 0（個人開発）/ 1以上（複数人）
☑ Require status checks to pass before merging
  └ Status checks: CI (GitHub Actions)
☑ Require conversation resolution before merging
☑ Block force pushes
☑ Restrict deletions
```

`epic/<name>` から `main` へのPRには、通常どおり `main-protection` のRulesetがそのまま適用される。

### Bypass for Billing-Blocked CI (Private Repos, Provisional)

Private リポジトリは GitHub Actions の課金対象（Public リポジトリは無料）。開発リソースが
限られる個人開発では、支払い方法・spending limit の問題で CI が丸ごと失敗し、必須チェック
がブロックされたままになることがある（`~/.ai/AI_CONTEXT.md` の GitHub セクションに同様の
運用メモあり：課金エラーによる CI 失敗はコード側の問題ではないため無視してよい）。

暫定処置として、Private リポジトリの `main-protection` Ruleset に **Repository admin の
bypass（PR 経由のみ）** を追加してよい（Ruleset の `bypass_actors` に以下を追加）：

```json
{
  "actor_id": 5,
  "actor_type": "RepositoryRole",
  "bypass_mode": "pull_request"
}
```

- `actor_id: 5` は Repository admin ロール（個人リポジトリでは実質オーナー本人）
- `bypass_mode: "pull_request"` — 直接 push は引き続き禁止。PR 経由でのマージ時のみ
  必須チェックをバイパスできる（`"always"` にはしない）
- Public リポジトリには適用しない（CI が無料で課金ブロックが起きないため不要）
- ローカルで `pre-commit run` 等により変更内容を確認済みの場合のみ使う。CI が本当に
  コードの問題で落ちているときの緊急回避には使わない
- 設定は GitHub の Settings → Rules → Rulesets（または `gh api` で既存 Ruleset 全体を
  取得し、`bypass_actors` だけを差し替えて `PUT` する）から行う。既存フィールドを
  壊さないよう、必ず現在の Ruleset 定義を取得してから更新すること

### Status Check Configuration

Rulesetの「Require status checks to pass before merging」でチェックを追加する際は、**名前とソースの両方を正しく指定**する。

**チェック名：**
GitHub Actions のステータスチェック名は、job の **`name` フィールドの値**（`gate` の場合、
ワークフロー自身の `name:` と同じ値。例：`CI`）で決まる。job ID（`gate`）ではないため注意。

```yaml
name: CI   # ワークフロー自身の name:

jobs:
  gate:
    name: CI   # ← Rulesetに登録する名前はこの値。ワークフローの name: と一致させる
```

job `name` を省略した場合は job ID がチェック名になる（例：`gate`）。

**ソース（Source）：**
チェック名を入力後、**ソースを `GitHub Actions` に指定する**（"Any source" のままにしない）。
"Any source" にすると、他の外部 CI サービスや手動操作でも条件を満たせてしまう。

Rulesetの設定画面では以下のように表示される：

```
Check name:  CI
Source:      GitHub Actions
```

集約ゲート job の `name` は説明を追加せず、常にそのワークフロー自身の `name:` と同じ値にする。個別 job の表示名は必要に応じて説明を追加してよい。
