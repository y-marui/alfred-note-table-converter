# dev-charter Install Checklist

After running `git subtree add` to install dev-charter in your project, paste the following prompts into your AI tool in order.

## Step 1 — Bulk setup

```
Read all files in docs/dev-charter/, explore this project, then do the following:

1. Set up AI context files following the spec in docs/dev-charter/AI_TOOL_SETUP.md
2. Compare the project against charter requirements and fix all gaps
   (cover the entire project: file structure, CI, security, docs, license, coding conventions, etc.)
3. Read docs/dev-charter/topics/PROJECT_README_GUIDELINES.md and validate the project README against it
   (if the README is template-style, reformat to project format; if it doesn't exist, create it)
4. Read docs/dev-charter/topics/GITHUB_SETTINGS.md and apply all repository settings
   (use gh commands if available; otherwise apply via the GitHub UI)

- If you have questions or ambiguities, ask all of them at once before starting
- If the charter conflicts with existing conventions, list the conflicts and confirm priority with the user before proceeding
- For large-scope changes, confirm with the user before proceeding
- Do not commit after completing (let the user review first)
```

## Step 2 — File-by-file review

```
Re-read each file in docs/dev-charter/ one at a time and verify that the project fully reflects it.

For each file in order:
1. Read the file
2. Check the corresponding project files and settings
3. Fix anything that is missing or incomplete

- Re-check items already addressed in Step 1
- Do not commit after completing (let the user review first)
```

---

*この文書には日本語版があります。編集時は同一コミットで更新してください。*

# dev-charter インストールチェックリスト

`git subtree add` で dev-charter をインストールした後、以下のプロンプトを順に AI に貼り付けて実行してください。

## Step 1 — 一括セットアップ

```
docs/dev-charter/ 内の全ファイルを読み、このプロジェクトを調査した上で、以下を実施してください。

1. docs/dev-charter/AI_TOOL_SETUP.md の仕様に従い AI コンテキストファイルをセットアップする
2. 憲章の要件とプロジェクトの現状を照合し、未対応箇所をすべて特定・修正する
   （ファイル構成・CI・セキュリティ・ドキュメント・ライセンス・コーディング規約など、プロジェクト全体を対象とする）
3. docs/dev-charter/topics/PROJECT_README_GUIDELINES.md を読み、プロジェクトの README を検証・更新する
   （テンプレート形式の README はプロジェクト形式に再フォーマットし、存在しない場合は新規作成する）
4. docs/dev-charter/topics/GITHUB_SETTINGS.md を読み、すべてのリポジトリ設定を適用する
   （gh コマンドが使える場合はコマンドで、使えない場合は GitHub UI から設定する）

- 不明点・確認事項は作業前に 1 回まとめて質問する
- 憲章と既存規約が矛盾する場合は矛盾点を列挙し、優先順位をユーザーに確認してから進める
- 大きなスコープになる場合は修正前にユーザーに確認する
- 完了後はコミットしない（ユーザーが確認してから行う）
```

## Step 2 — ファイル単位の精査

```
docs/dev-charter/ 内の各ファイルを1つずつ読み直し、プロジェクトへの反映を確認・補完してください。

各ファイルについて順に:
1. ファイルを読む
2. 対応するプロジェクトファイル・設定を確認する
3. 未反映・不十分な箇所があれば修正する

- Step 1 で対応済みの箇所も再確認する
- 完了後はコミットしない（ユーザーが確認してから行う）
```

---

*This document has a Japanese version above. Update both in the same commit when editing.*
