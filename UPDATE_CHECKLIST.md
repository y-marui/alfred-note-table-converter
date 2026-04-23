# dev-charter Update Checklist

After running `git subtree pull` to update dev-charter in your project, paste the following prompt into your AI tool.

## Step 1 — Update changed areas only

```
Run the following command to see which dev-charter files changed in this update
(run it right after `git subtree pull`, before any other commits):

  git diff HEAD~1 HEAD --name-only -- docs/dev-charter/

Read each changed file and update the project to reflect the changes.

Common areas affected by file:
- AI_TOOL_SETUP.md                          → update AI context files (AI_CONTEXT.md and agent config files)
- topics/PROJECT_README_GUIDELINES.md       → update the project README
- topics/TEMPLATE_README_GUIDELINES.md      → update README.md and README_TEMPLATE.md (template repos only)
- topics/GITHUB_SETTINGS.md                 → apply repository settings (gh commands if available, otherwise GitHub UI)
- topics/CI_POLICY.md                       → review and update .github/workflows/
- SECURITY_POLICY.md                        → review security hook and scan configuration
- LEGAL_POLICY.md                           → verify license files
- Other policy files                        → update AI context if the policy changed meaningfully

- If AI_CONTEXT.md does not exist, use the install checklist instead
- If a charter change conflicts with a project-specific rule, list the conflicts and confirm priority with the user
- Do not commit after completing (let the user review first)
```

> For a full review of all charter files (not just changed ones), use the [Install Checklist](INSTALL_CHECKLIST.md).

---

*この文書には日本語版があります。編集時は同一コミットで更新してください。*

# dev-charter 更新チェックリスト

`git subtree pull` で dev-charter を更新した後、以下のプロンプトを AI に貼り付けて実行してください。

## Step 1 — 変更のあった箇所のみ更新

```
以下のコマンドで今回の更新で変更された dev-charter のファイルを確認してください
（`git subtree pull` 直後、他のコミットの前に実行してください）：

  git diff HEAD~1 HEAD --name-only -- docs/dev-charter/

変更された各ファイルを読み、プロジェクトへの影響を確認して対応してください。

ファイル別の主な影響箇所：
- AI_TOOL_SETUP.md                         → AI コンテキストファイルを更新（AI_CONTEXT.md・各ツール設定ファイル）
- topics/PROJECT_README_GUIDELINES.md      → プロジェクトの README を更新
- topics/TEMPLATE_README_GUIDELINES.md     → README.md と README_TEMPLATE.md を更新（テンプレートリポジトリのみ）
- topics/GITHUB_SETTINGS.md                → リポジトリ設定を適用（gh コマンドが使える場合はコマンドで、使えない場合は GitHub UI から）
- topics/CI_POLICY.md                      → .github/workflows/ を確認・更新
- SECURITY_POLICY.md                       → セキュリティフック・スキャン設定を確認
- LEGAL_POLICY.md                          → ライセンスファイルを確認
- その他のポリシーファイル                  → 内容に変更があれば AI コンテキストを更新

- AI_CONTEXT.md が存在しない場合はインストールチェックリストを使うこと
- 憲章の変更がプロジェクト固有ルールと矛盾する場合は矛盾点を列挙してユーザーに確認する
- 完了後はコミットしない（ユーザーが確認してから行う）
```

> 変更ファイルに限らず全ファイルを精査したい場合は [インストールチェックリスト](INSTALL_CHECKLIST.md) を使用してください。

---

*This document has a Japanese version above. Update both in the same commit when editing.*
