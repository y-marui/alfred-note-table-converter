# GitHub Issue/PR Templates (lite)

外部コントリビューターを受け付けない個人開発〜小規模プロジェクトでも、自分用のチェックリスト・書式統一として issue/PR テンプレートを用意する。準CLA・外部コントリビューションルールなど、OSSで外部コントリビューターを受け入れる場合に必要な内容は full 版の [topics/GITHUB_CONTRIBUTING.md](https://github.com/y-marui/dev-charter/blob/full/topics/GITHUB_CONTRIBUTING.md) を参照する。

以下の各節はそのまま採用先リポジトリの同名パスにファイルとして作成する雛形であり、dev-charter リポジトリ自身にこれらのファイルを含むものではない。

## .github/ISSUE_TEMPLATE/bug_report.md

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

## .github/ISSUE_TEMPLATE/feature_request.md

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

## .github/PULL_REQUEST_TEMPLATE.md

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
```

外部コントリビューターを想定しないため、full 版にある CLA 同意チェックボックス（`I have read and agree to the terms in CONTRIBUTING.md`）は含めない。
