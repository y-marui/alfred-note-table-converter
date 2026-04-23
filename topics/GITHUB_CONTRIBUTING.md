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

チェックリストはプロジェクトに合わせて取捨選択すること。
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

- [ ] No secrets or credentials included
- [ ] Lint passes
- [ ] Type checks pass (if applicable)
- [ ] Tests pass (if applicable)
- [ ] Build succeeds (if applicable)
- [ ] New features include tests
- [ ] User-facing changes are documented
- [ ] Added entry to CHANGELOG.md [Unreleased] section (if applicable)
- [ ] Manually verified (if applicable)

## Contribution Terms

By contributing, you agree that your contributions are licensed under
[AGPL v3 / GPL v3 / LGPL v3] and that you grant the project maintainer
a non-exclusive, perpetual, worldwide, royalty-free right to use, reproduce,
modify, distribute, sublicense, and relicense your contributions under any license.
```

`[AGPL v3 / GPL v3 / LGPL v3]` はプロジェクトのライセンスに合わせて置き換えること。

## .github/PULL_REQUEST_TEMPLATE.md

PR テンプレートは CONTRIBUTING.md のチェックリストと対応させる。
**CONTRIBUTING.md を編集した場合は PR テンプレートも合わせて見直すこと。**

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

## Quasi-CLA（コピーレフトプロジェクト向け）

AGPL/GPL/LGPL を採用し、将来の再ライセンスの余地を確保したい場合、外部コントリビューターから必要な許諾を事前に取得しておく。本格的な CLA サービスは導入せず、`CONTRIBUTING.md` と PR テンプレートによる **準 CLA 方式**で運用する（上記テンプレートの "Contribution Terms" セクションおよび CLA 同意チェックボックスがこれに該当する）。

### Phased Approach

| フェーズ | 移行トリガー | 運用 |
|---|---|---|
| 初期 | — | 準 CLA（CONTRIBUTING + PR 同意）で運用 |
| 移行 | コントリビュータ 3〜5 人以上 / 継続的な外部 PR / コア機能への影響が増大 | 以降の新規コントリビューションに CLA Assistant 等の正式な CLA サービスを適用。準 CLA 設置後のコントリビュータは再同意不要（許諾は永続的かつ取消不能なため） |

コピーレフトライセンス採用後かつ準 CLA 設置前に行われたコントリビューションがある場合に限り、該当コントリビュータへの個別対応（再同意取得または未同意コードの排除・置換）が必要になる場合がある。

> **注意**: 準 CLA で取得する再ライセンス権は法的に有効だが、同意の証明力は正式 CLA より弱い。プロジェクトが成長し、訴訟リスクが現実的になった段階で正式な CLA サービスへの移行を検討すること。
