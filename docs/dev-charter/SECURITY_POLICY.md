# セキュリティポリシー

## セキュリティの二層構造

このプロジェクトのセキュリティは以下の二層で構成される。

### 層1: 個人のグローバル git フック（dotfiles 管理・個人のみ）

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

### 層2: per-repo の pre-commit フック（チーム強制・CI でも動作）

`.pre-commit-config.yaml` をリポジトリにコミットし `pre-commit install` することで有効になる。
**チームとしての実際の強制手段**であり、CI でも必ず動作させる。

---

## 自動強制ポリシー

以下はフックによって**自動的にブロック**される。

| 違反 | 強制層 | 理由 |
|---|---|---|
| `anonymous` のままコミット | 層1 | コミット帰属の担保 |
| `.env` ファイルのコミット | 層1 + 層2 | リポジトリ履歴への漏洩防止 |
| SSH 秘密鍵・クラウドトークンのコミット | 層1 + 層2（gitleaks） | 認証情報の漏洩防止 |
| ローカル絶対パスのハードコード | 層2 | 環境依存コードの防止 |
| 500 KB を超えるファイル | 層2 | リポジトリの肥大化防止 |

`.env` の正しい扱い方：`.env` は絶対にコミットしない。ダミー値のみを含む `.env.example` をコミットする。

```sh
# .env.example  — コミットしてよい（実際の値は含めない）
DATABASE_URL=postgres://user:password@localhost:5432/mydb
API_KEY=your-api-key-here
```

---

## 手動遵守ポリシー

自動化できないため、開発者が自ら守ること。

### シークレット管理

- API キー・パスワード・トークンを絶対にコードに書かない。環境変数または Secret Manager（AWS Secrets Manager、HashiCorp Vault 等）を使う。
- 誤ってコミットしたシークレットは、履歴から削除した上で即座にローテーションする。

### AI との協働

- **シークレットを含むファイルやコードを AI に渡さない**（プロンプト・コンテキストファイル・スクリーンショット含む）。
- **AI が生成したコードは必ずレビューしてからコミットする**。SQLインジェクション・ハードコードされた認証情報・安全でない逆シリアライズ等を含む可能性がある。
- **AI との会話ログをリポジトリにコミットしない**。

### コードレビュー

- `main` に到達するコミットは必ず他の開発者がレビューする。
- 認証・認可・暗号化・データアクセスに関わる変更はセキュリティレビューを必須とする。

---

## セットアップ手順

新規リポジトリに本憲章を適用する場合：

```sh
# 1. セキュリティ設定ファイルを dev-charter からコピー
cp docs/dev-charter/.pre-commit-config.yaml .
cp docs/dev-charter/.gitleaks.toml .

# 2. pre-commit フックをインストール
#    core.hooksPath を使用している場合（グローバルフックが pre-commit を呼ぶ場合）は
#    pre-commit install は不要。手順 3 で pre-commit が正しく動作することを確認する。
git config core.hooksPath 2>/dev/null \
  && echo "core.hooksPath が設定されています。手順 3 に進んでください。" \
  || pre-commit install

# 3. 動作確認（core.hooksPath の有無にかかわらず必須）
pre-commit run --all-files
```

CI での実行例（GitHub Actions）：

```yaml
- name: Run pre-commit
  uses: pre-commit/action@v3.0.1
```

---

## 設定ファイル一覧

| ファイル | 用途 |
|---|---|
| `.pre-commit-config.yaml` | pre-commit フック定義（セキュリティ＋品質） |
| `.gitleaks.toml` | gitleaks カスタムルール設定 |
| `SECURITY_POLICY.md` | このドキュメント |

---

*[dev-charter](README-jp.md) の一部。関連: [PRINCIPLES.md](PRINCIPLES.md)、[AI_COLLABORATION_RULES.md](AI_COLLABORATION_RULES.md)*
