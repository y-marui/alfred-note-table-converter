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

# 3. dev-charter 固有のフックを除いた設定を生成する
awk '
  /BEGIN DEV-CHARTER ONLY/ { skip = 1; next }
  /END DEV-CHARTER ONLY/ { skip = 0; next }
  !skip { print }
' docs/dev-charter/.pre-commit-config.yaml > .pre-commit-config.yaml

# 4. pre-commit フックをインストール
#    core.hooksPath を使用している場合（グローバルフックが pre-commit を呼ぶ場合）は
#    pre-commit install は不要。手順 5 で pre-commit が正しく動作することを確認する。
git config core.hooksPath 2>/dev/null \
  && echo "core.hooksPath が設定されています。手順 5 に進んでください。" \
  || pre-commit install

# 5. 動作確認（core.hooksPath の有無にかかわらず必須）
pre-commit run --all-files
```

既存の `.pre-commit-config.yaml` がある場合は上書きせず、dev-charter の設定から `BEGIN DEV-CHARTER ONLY`〜`END DEV-CHARTER ONLY` を除いたフックを既存設定へ統合する。リポジトリ固有の言語・フレームワーク用フックは維持すること。

CI での実行例（GitHub Actions）：

```yaml
- name: Run pre-commit
  uses: pre-commit/action@v3.0.1
```

---

## Configuration Files

| ファイル | 用途 |
|---|---|
| `.pre-commit-config.yaml` | pre-commit フック定義（セキュリティ＋品質） |
| `.gitleaks.toml` | gitleaks カスタムルール設定 |
| `scripts/check-markdown-heading-language.sh` | Markdown セクションヘッダの言語検証 |
| `scripts/check-local-charter-version.sh` | ローカルの `../dev-charter` チェックアウトとの VERSION 差分をチェック（sibling が新しい場合はブロック、古い場合は警告） |
| `SECURITY_POLICY.md` | このドキュメント |

---

*[dev-charter](README-jp.md) の一部。関連: [PRINCIPLES.md](PRINCIPLES.md)、[AI_COLLABORATION_RULES.md](AI_COLLABORATION_RULES.md)*
