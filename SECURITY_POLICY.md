# Security Policy

## Two-Layer Security Architecture

このプロジェクトのセキュリティは以下の二層で構成される。

### Layer 1: Personal Global Git Hooks (dotfiles, personal only)

`~/.gitconfig` に `core.hooksPath = ~/.config/git/hooks` を設定することで、
開発者個人のマシン上の**全リポジトリに自動適用**される安全網。
チームメンバー全員が持つ前提ではない。

`~/.config/git/hooks/pre-commit` が行うチェック：

| # | チェック内容 | 失敗時の動作 |
|---|---|---|
| 1 | 他人管理リポジトリはスキップ（`hooks.skip-policy-check = true`） | 全チェックをスキップ |
| 2 | `user.name` / `user.email` が `anonymous` のまま | コミットをブロック |
| 3 | `.env` ファイルがステージされている（`.env.example` 等は許可） | コミットをブロック |
| 4 | SSH 秘密鍵ヘッダー（PEM 形式の秘密鍵ブロック）を検知 | コミットをブロック |
| 5 | `.pre-commit-config.yaml` が存在しない | コミットをブロック |
| 6 | `.pre-commit-config.yaml` に必須セキュリティフックが揃っていない | コミットをブロック |
| 7 | `pre-commit install` が未実行（`.git/hooks/pre-commit` に pre-commit が含まれない）かつ `core.hooksPath` が未設定 | コミットをブロック |

他人管理リポジトリでスキップする場合：

```sh
git config hooks.skip-policy-check true
```

### Layer 2: Per-Repo Pre-commit Hooks (team-enforced, runs in CI)

`.pre-commit-config.yaml` をリポジトリにコミットし `pre-commit install` することで有効になる。
**チームとしての実際の強制手段**であり、CI でも必ず動作させる。

---

## Automated Enforcement Policy

以下はフックによって**自動的にブロック**される。

| 違反 | 強制層 | 理由 |
|---|---|---|
| `anonymous` のままコミット | 層1 | コミット帰属の担保 |
| `.env` ファイルのコミット | 層1 + 層2 | リポジトリ履歴への漏洩防止 |
| SSH 秘密鍵・クラウドトークンのコミット | 層1 + 層2（gitleaks） | 認証情報の漏洩防止 |
| ローカル絶対パスのハードコード | 層2 | 環境依存コードの防止 |
| 500 KB を超えるファイル | 層2 | リポジトリの肥大化防止 |
| Markdown の H2〜H6 に日本語を使用 | 層2 | セクションヘッダ言語の統一 |
| ローカル `../dev-charter` チェックアウトより古い dev-charter のままコミット | 層2 | dev-charter 追従漏れの防止 |
| `.github/workflows/dev-charter-check.yml` が README の CI テンプレートと不一致のままコミット | 層2 | 採用先 CI 設定の追従漏れの防止 |
| `docs/dev-charter/` 配下の直接編集（`git subtree pull` 以外の変更） | 層2（ローカルのみ。CI の `pre-commit run --all-files` はステージ済み差分が空になるため未対応） | INSTALL_CHECKLIST.md の遵守 |
| `<name>-jp.<ext>` / `<name>.<ext>` ペアの片側のみ更新 | 層2（ローカルのみ。理由は上記と同様） | LANGUAGE_POLICY.md の日英同時更新ルールの遵守 |
| `LICENSE` ファイルの欠如 | 層2 | LEGAL_POLICY.md の遵守（ライセンスなし公開の防止） |
| `.env.example`/`.env.sample`/`.env.template` があるのに `.gitignore` が `.env` を無視していない | 層2 | `.env` 誤コミットの一次防御 |
| コミットメッセージが Conventional Commits 形式でない | 層2（commit-msg ステージ。`core.hooksPath` 使用時は個人の dotfiles 側の追加対応が無い限り機能しない） | PROJECT_LIFECYCLE.md の遵守 |
| 日英ペアドキュメントの冒頭宣言・末尾フッターの欠如 | 層2 | LANGUAGE_POLICY.md の遵守 |
| `AI_CONTEXT.md` があるのに `CLAUDE.md`/`GEMINI.md`/`AGENTS.md`/`.github/copilot-instructions.md` がそれを参照していない | 層2 | AI_TOOL_SETUP.md の遵守 |
| `pyproject.toml` があるのに `requirements.txt` が存在する、または `uv.lock` が無い | 層2 | topics/python/PYTHON_DEV_ENV.md の遵守 |
| `LICENSE`/`.github/FUNDING.yml`/`README` にプレースホルダ（`[YEAR]` 等）が残っている | 層2（テンプレートリポジトリ自体は対象外） | topics/PROJECT_README_GUIDELINES.md の遵守 |
| デフォルトブランチ（`main`/`master`）へ直接コミット | 層2（CI 上ではスキップ。detached HEAD/PR ref でブランチ名を持たないため） | サーバ側 Ruleset は push のみ止めるため、コミット時点で検知する（topics/CI_POLICY.md「Branch Protection (Ruleset)」参照） |

`.env` の正しい扱い方：`.env` は絶対にコミットしない。ダミー値のみを含む `.env.example` をコミットする。

```sh
# .env.example  — コミットしてよい（実際の値は含めない）
DATABASE_URL=postgres://user:password@localhost:5432/mydb
API_KEY=your-api-key-here
```

---

## Manual Compliance Policy

自動化できないため、開発者が自ら守ること。

### Secret Management

- API キー・パスワード・トークンを絶対にコードに書かない。環境変数または Secret Manager（AWS Secrets Manager、HashiCorp Vault 等）を使う。
- 誤ってコミットしたシークレットは、履歴から削除した上で即座にローテーションする。

### AI Collaboration

- **シークレットを含むファイルやコードを AI に渡さない**（プロンプト・コンテキストファイル・スクリーンショット含む）。
- **AI が生成したコードは必ずレビューしてからコミットする**。SQLインジェクション・ハードコードされた認証情報・安全でない逆シリアライズ等を含む可能性がある。
- **AI との会話ログをリポジトリにコミットしない**。

### Code Review

- `main` に到達するコミットは [AI_COLLABORATION_RULES.md](AI_COLLABORATION_RULES.md) のレビュー経路に従って独立した確認を受ける。複数人開発では別の開発者の承認を必須とし、個人開発では実装担当と異なる AI によるレビューとオーナーの最終確認で代替できる。
- 認証・認可・暗号化・データアクセスに関わる変更はセキュリティレビューを必須とする。

---

## Setup Steps

> **lite 版を導入している場合**：以下の手順が取り込む `.gitleaks.toml` /
> `scripts/*.sh` / `.pre-commit-config.yaml` は `lite` ブランチには含まれない
> （`scripts/publish-branch.sh` は full ブランチにのみこれらを同梱する）。
> Layer 2 の自動化（pre-commit フックによるチーム強制）が必要な場合は `full`
> 版を導入すること。lite のみを導入している場合は、本セクションの
> 手順は実行できないため、Layer 1 の個人フックと「Manual Compliance Policy」
> 節の手動遵守で代替する。

新規リポジトリに本憲章を適用し、`.pre-commit-config.yaml` がまだ存在しない場合：

```bash
set -euo pipefail

# 1. 既存設定を誤って上書きしないことを確認する
if [ -e .pre-commit-config.yaml ]; then
  echo ".pre-commit-config.yaml は既に存在します。既存設定へ必要フックを統合してください。" >&2
  exit 1
fi

# 2. セキュリティ設定ファイルと共通検証スクリプトを取り込む
cp docs/dev-charter/.gitleaks.toml .
mkdir -p scripts
cp docs/dev-charter/scripts/check-markdown-heading-language.sh scripts/
chmod +x scripts/check-markdown-heading-language.sh
cp docs/dev-charter/scripts/check-local-charter-version.sh scripts/
chmod +x scripts/check-local-charter-version.sh
cp docs/dev-charter/scripts/check-charter-ci-template.sh scripts/
chmod +x scripts/check-charter-ci-template.sh
cp docs/dev-charter/scripts/check-charter-subtree-edit.sh scripts/
chmod +x scripts/check-charter-subtree-edit.sh
cp docs/dev-charter/scripts/check-language-pair-sync.sh scripts/
chmod +x scripts/check-language-pair-sync.sh
cp docs/dev-charter/scripts/check-license-exists.sh scripts/
chmod +x scripts/check-license-exists.sh
cp docs/dev-charter/scripts/check-dotenv-gitignore.sh scripts/
chmod +x scripts/check-dotenv-gitignore.sh
cp docs/dev-charter/scripts/check-conventional-commit.sh scripts/
chmod +x scripts/check-conventional-commit.sh
cp docs/dev-charter/scripts/check-language-pair-footer.sh scripts/
chmod +x scripts/check-language-pair-footer.sh
cp docs/dev-charter/scripts/check-ai-context-reference.sh scripts/
chmod +x scripts/check-ai-context-reference.sh
cp docs/dev-charter/scripts/check-python-package-management.sh scripts/
chmod +x scripts/check-python-package-management.sh
cp docs/dev-charter/scripts/check-readme-placeholders.sh scripts/
chmod +x scripts/check-readme-placeholders.sh
cp docs/dev-charter/scripts/check-not-on-default-branch.sh scripts/
chmod +x scripts/check-not-on-default-branch.sh
cp docs/dev-charter/scripts/new-branch.sh scripts/
chmod +x scripts/new-branch.sh

# 3. dev-charter 固有のフックを除いた設定を生成する
awk '
  /BEGIN DEV-CHARTER ONLY/ { skip = 1; next }
  /END DEV-CHARTER ONLY/ { skip = 0; next }
  !skip { print }
' docs/dev-charter/.pre-commit-config.yaml > .pre-commit-config.yaml

# 4. pre-commit フックをインストール
#    pre-commit ステージ（大半のフック）は core.hooksPath 使用時
#    （グローバルフックが pre-commit を呼ぶ場合）は個別インストール不要。
#    commit-msg ステージ（check-conventional-commit）は別途
#    `pre-commit install --hook-type commit-msg` が要る。ただし
#    core.hooksPath 設定時は pre-commit がこのインストールを拒否する
#    （"Cowardly refusing to install hooks with core.hooksPath set"）。
#    その場合、commit-msg ステージのフックはグローバルフック側
#    （例: ~/.config/git/hooks/commit-msg）で
#    `pre-commit run --hook-stage commit-msg --commit-msg-filename "$1"`
#    を呼ぶよう個人の dotfiles 側に別途実装しない限り機能しない
#    （本リポジトリのスコープ外）。
git config core.hooksPath 2>/dev/null \
  && echo "core.hooksPath が設定されています。pre-commit ステージは手順 5 で確認します。commit-msg ステージは上記コメント参照。" \
  || { pre-commit install; pre-commit install --hook-type commit-msg; }

# 5. 動作確認（core.hooksPath の有無にかかわらず必須）
pre-commit run --all-files
```

既存の `.pre-commit-config.yaml` がある場合は上書きせず、dev-charter の設定から `BEGIN DEV-CHARTER ONLY`〜`END DEV-CHARTER ONLY` を除いたフックを既存設定へ統合する。リポジトリ固有の言語・フレームワーク用フックは維持すること。

CI での実行例（GitHub Actions）：

```yaml
- name: Run pre-commit
  uses: pre-commit/action@v3.0.1
  env:
    # powershell-lint はローカル専用の補助チェック（.pre-commit-config.yaml 参照）で
    # マージ条件には含めない。GitHub-hosted ubuntu-latest には pwsh が同梱されて
    # おり、ローカル用の command -v pwsh ガードが効かないため、CI では明示的に
    # スキップする。
    SKIP: powershell-lint
```

上記の `ci.yml` テンプレートを使わず独自に CI を構築する場合も、`pre-commit/action` を
呼ぶステップには必ず `SKIP: powershell-lint` を設定すること。省略すると、`.ps1` が
1つも無いプロジェクトでも `docs/dev-charter/scripts/*.ps1`（本憲章の subtree が
持ち込むファイル）に対して GitHub-hosted ランナー上でのみ lint が走り、ローカルでは
再現しない CI 専用の失敗になる。

---

## Configuration Files

| ファイル | 用途 |
|---|---|
| `.pre-commit-config.yaml` | pre-commit フック定義（セキュリティ＋品質） |
| `.gitleaks.toml` | gitleaks カスタムルール設定 |
| `scripts/check-markdown-heading-language.sh` | Markdown セクションヘッダの言語検証 |
| `scripts/check-local-charter-version.sh` | ローカルの `../dev-charter` チェックアウトとの VERSION 差分をチェック（sibling が新しい場合はブロック、古い場合は警告） |
| `scripts/check-charter-ci-template.sh` | `.github/workflows/dev-charter-check.yml` を README-jp.md の CI テンプレートと比較（不一致ならブロック） |
| `scripts/check-charter-subtree-edit.sh` | `docs/dev-charter/` 配下がステージされていればブロック。ただし `MERGE_HEAD` が `git-subtree-dir` トレーラーを持つ場合（`git subtree add`/`pull`/`merge` が競合し手動コミットで完了させる場合）は誤検知しないよう除外する |
| `scripts/check-language-pair-sync.sh` | `<name>-jp.<ext>` / `<name>.<ext>` ペアが片側のみステージされていればブロック |
| `scripts/check-license-exists.sh` | リポジトリルートに `LICENSE*` が無ければブロック |
| `scripts/check-dotenv-gitignore.sh` | `.env.example` 等があるのに `.gitignore` が `.env` を無視していなければブロック |
| `scripts/check-conventional-commit.sh` | コミットメッセージが Conventional Commits 形式でなければブロック（commit-msg ステージ、merge/squash コミットは対象外） |
| `scripts/check-language-pair-footer.sh` | 日英ペアドキュメントの冒頭宣言・末尾フッターの有無をキーワードベースで検証（ペアが両方存在する場合のみ） |
| `scripts/check-ai-context-reference.sh` | `AI_CONTEXT.md` があるのに CLAUDE.md 等がそれを参照していなければブロック |
| `scripts/check-python-package-management.sh` | `pyproject.toml` があるのに `requirements.txt` が存在する、または `uv.lock` が無ければブロック |
| `scripts/check-readme-placeholders.sh` | `LICENSE`/`.github/FUNDING.yml`/`README` のプレースホルダ残留を検知（テンプレートリポジトリは対象外） |
| `scripts/check-not-on-default-branch.sh` | デフォルトブランチ（`main`/`master`、または `origin/HEAD` が指す既定ブランチ）への直接コミットをブロック（CI ではスキップ） |
| `scripts/new-branch.sh` | `check-not-on-default-branch.sh` にブロックされた際に使う補助スクリプト。ブランチを作成してそちらに移動する（ステージ済み・未ステージの変更は引き継がれる） |
| `SECURITY_POLICY.md` | このドキュメント |

---

*[dev-charter](README-jp.md) の一部。関連: [PRINCIPLES.md](PRINCIPLES.md)、[AI_COLLABORATION_RULES.md](AI_COLLABORATION_RULES.md)*
