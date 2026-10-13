# GitHub Contributing

OSS で外部コントリビューターを受け付ける場合に必要なファイルと設定を定める。

## Issues

GitHub Issue でバグ・機能要望を管理する。

### .github/ISSUE_TEMPLATE/bug_report.md

```markdown
---
name: Bug Report
about: Something isn't working
labels: bug
---

## Description

<!-- Describe the bug clearly and concisely -->

## Steps to Reproduce

1.
2.
3.

## Expected Behavior

<!-- What you expected to happen -->

## Actual Behavior

<!-- What actually happened -->

## Environment

- OS:
- Language/Framework version:
- Other relevant versions:
```

### .github/ISSUE_TEMPLATE/feature_request.md

```markdown
---
name: Feature Request
about: Propose a new feature or improvement
labels: enhancement
---

## Problem / Use Case

<!-- What problem are you trying to solve? -->

## Proposed Solution

<!-- How would you like it to work? -->

## Alternatives Considered

<!-- Any other solutions you've considered? -->
```

## Pull Requests

- コードの変更はすべてPR経由でマージする（`main` への直接pushは禁止）
- PRタイトルはConventional Commits形式（`feat:` / `fix:` / `docs:` 等）
- 関連Issueはdescriptionで参照する（`closes #123`）
- マージ条件：全会話解決済み・CI通過
- レビュー承認数はプロジェクト規模に応じて設定する（個人開発：0、複数人：1以上）

## CONTRIBUTING.md

PR チェックリストの正本は `.github/PULL_REQUEST_TEMPLATE.md` とし、プロジェクトに合わせた項目の取捨選択も同ファイルで行う。`CONTRIBUTING.md` にはチェックリストを重複させず、PR テンプレートへの参照だけを記載する。
AGPL/GPL/LGPL 以外のプロジェクト（MIT 等）では「Contribution Terms」セクションを省略する。

```markdown
## How to Contribute

For large changes (new features, design changes), please open an issue before submitting a PR.
Small bug fixes and typos can be submitted directly as a PR.

## Development Setup

See [README.md](README.md) for setup instructions.

## Code Style

Follow [CODE_STYLE.md](docs/dev-charter/CODE_STYLE.md).

## Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) format (e.g. `fix: ...`, `feat: ...`).

## Pull Request Checklist

See `.github/PULL_REQUEST_TEMPLATE.md` for the current checklist.

## Contribution Terms

By contributing, you agree that your contributions are licensed under
[AGPL v3 / GPL v3 / LGPL v3] and that you grant the project maintainer
a non-exclusive, perpetual, worldwide, royalty-free right to use, reproduce,
modify, distribute, sublicense, and relicense your contributions under any license.
```

`[AGPL v3 / GPL v3 / LGPL v3]` はプロジェクトのライセンスに合わせて置き換えること。

## SECURITY.md

脆弱性の報告先を示すファイル。他の節と異なり、外部コントリビューターの有無や公開・private を問わず、**すべてのリポジトリのルートに置く**。同じ定型文を全リポジトリに置くことで、テンプレートから生成したリポジトリが公開か private かを気にせず済み、後から公開に切り替えてもそのまま使える。

- 置き場所はリポジトリ直下の `SECURITY.md`。アカウント共通の `.github` リポジトリによる既定値には頼らない（憲章を取り込む他の採用先やローカルの clone でも成り立たせるため）
- 文面は次の定型文をそのまま使う。プロジェクトごとに書き換えない（文面を変えるときは、この節を直してから各リポジトリに反映する）
- プロジェクト固有のセキュリティ設計・保証・脅威モデル（例: 「テレメトリやネットワーク送信を行わない」「信頼境界と許可リスト」）や、開発側のセキュリティチェックの一覧は、`docs/` の既存の文書（設計・仕様の文書、`DEVELOPING.md` 等）に置き、`SECURITY.md` には書かない。`SECURITY.md` は報告方法の定型文だけにする
- 数値の SLA は書かない。守れない約束を載せないため
- メールアドレスなどの個人の連絡先は載せない。報告経路は GitHub の Private vulnerability reporting（以下 PVR）にする
- PVR は公開リポジトリでのみ使える。有効化の手順は [GITHUB_SETTINGS-full.md](GITHUB_SETTINGS-full.md) / [GITHUB_SETTINGS-lite.md](GITHUB_SETTINGS-lite.md) の「Private Vulnerability Reporting」を参照する。PVR が使えない private リポジトリや、有効化し忘れたリポジトリでは、文面の後半（脆弱性の詳細を含めずに連絡手段を尋ねる Issue）が代わりの経路になる
- リポジトリ自身の脆弱性報告の受付を定めるもので、シークレット管理（[SECURITY_POLICY.md](../SECURITY_POLICY.md)）とは別の話

```markdown
# Security Policy

## Supported Versions

Only the latest release (or the default branch, if there are no releases)
receives security fixes.

## Reporting a Vulnerability

Please do not report security vulnerabilities in public issues, pull
requests, or discussions.

If private vulnerability reporting is enabled for this repository, use
"Report a vulnerability" on the Security tab. Otherwise, open an issue
asking for a private contact channel, without including any details of
the vulnerability.

## What to Expect

Reports are handled on a best-effort basis. No response time is guaranteed.
```

`CODE_OF_CONDUCT.md` は憲章では定めない。個人開発・小規模 OSS には通報を受ける運用主体がいないため。外部コントリビューターを積極的に募る段階になったら、別途検討する。

## .github/PULL_REQUEST_TEMPLATE.md

PR チェックリストはこのファイルを正本とする。
**コントリビューション要件を変更した場合は、PR テンプレートのチェックリストも合わせて見直すこと。**

```markdown
## Description

<!-- Briefly describe the changes -->

## Checklist

- [ ] No secrets or credentials included
- [ ] Lint passes
- [ ] Type checks pass (if applicable)
- [ ] Tests pass (if applicable)
- [ ] Build succeeds (if applicable)
- [ ] New features include tests
- [ ] User-facing changes are documented
- [ ] Added entry to CHANGELOG.md [Unreleased] section (if applicable)
- [ ] Manually verified (if applicable)
- [ ] I have read and agree to the terms in CONTRIBUTING.md.
```

> **運用上の注意**: GitHub はチェックボックスの完了を強制しない。チェックなしの PR はマージしないこと。これが準 CLA の唯一の強制機構である。

AGPL/GPL/LGPL 以外のプロジェクトでは最後の CLA 同意チェックボックスを省略する。

## Quasi-CLA

AGPL/GPL/LGPL を採用し、将来の再ライセンスの余地を確保したい場合、外部コントリビューターから必要な許諾を事前に取得しておく。本格的な CLA サービスは導入せず、`CONTRIBUTING.md` と PR テンプレートによる **準 CLA 方式**で運用する（上記テンプレートの "Contribution Terms" セクションおよび CLA 同意チェックボックスがこれに該当する）。

### Phased Approach

| フェーズ | 移行トリガー | 運用 |
|---|---|---|
| 初期 | — | 準 CLA（CONTRIBUTING + PR 同意）で運用 |
| 移行 | コントリビュータ 3〜5 人以上 / 継続的な外部 PR / コア機能への影響が増大 | 以降の新規コントリビューションに CLA Assistant 等の正式な CLA サービスを適用。準 CLA 設置後のコントリビュータは再同意不要（許諾は永続的かつ取消不能なため） |

コピーレフトライセンス採用後かつ準 CLA 設置前に行われたコントリビューションがある場合に限り、該当コントリビュータへの個別対応（再同意取得または未同意コードの排除・置換）が必要になる場合がある。

> **注意**: 準 CLA で取得する再ライセンス権は法的に有効だが、同意の証明力は正式 CLA より弱い。プロジェクトが成長し、訴訟リスクが現実的になった段階で正式な CLA サービスへの移行を検討すること。
