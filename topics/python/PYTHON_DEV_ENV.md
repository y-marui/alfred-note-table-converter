# Python Development Environment

Pythonプロジェクト共通の開発環境構成を定義する。

## Version Policy

| 項目 | 基準 | 2026-08-31時点の例 |
|---|---|---|
| **開発バージョン**（`.python-version`） | 最新安定版 | 3.14 |
| **サポート範囲**（`requires-python`） | EOLまで6ヶ月以上あるバージョン | >=3.11 |
| **CIマトリクス** | サポート対象の全バージョン | 3.11, 3.12, 3.13, 3.14 |

サポート範囲とCIマトリクスは定期的に見直し、EOLが6ヶ月を切ったバージョンを外す。

## Runtime Management

- **pyenv** でPythonバージョンを管理する
- `.python-version` をリポジトリに含め、最新安定版に固定する

## Package Management

- **uv** でパッケージ・仮想環境・プロジェクト管理を行う
- `pyproject.toml` で依存関係を管理する（`requirements.txt` は使用しない）
- `uv.lock` をリポジトリに含め、再現性を担保する

```toml
# pyproject.toml（抜粋）
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "mypackage"
requires-python = ">=3.11"  # EOLまで6ヶ月以上あるバージョンを下限とする
dependencies = [...]

[dependency-groups]
dev = ["ruff", "mypy", "pytest"]
```

よく使うコマンド：

```bash
uv sync               # 依存インストール（.venv 自動作成）
uv run pytest         # 仮想環境内でコマンド実行
uv add <pkg>          # 依存追加
uv add --dev <pkg>    # 開発依存追加
```

## Linting & Formatting

- **ruff** でlintとformatを統一する（flake8・isort・black の代替）
- `pyproject.toml` の `[tool.ruff]` で設定を管理する
- CIで `ruff check` と `ruff format --check` を実行する

```toml
[tool.ruff]
line-length = 88

[tool.ruff.lint]
select = ["E", "F", "I", "UP"]
```

`docs/dev-charter/` 配下（`git subtree` で取り込んだ vendored コピー）はlint対象から除外する。
ruffのデフォルト除外リストを保持するため、`exclude`（置換）ではなく`extend-exclude`（追加）を使う：

```toml
[tool.ruff]
extend-exclude = ["docs/dev-charter"]
```

**pre-commitでの重複実行（任意）:** `astral-sh/ruff-pre-commit` をローカルフックとして追加する
運用も可。追加する場合、`rev:` は `pyproject.toml` の `[dependency-groups]` にある
`ruff` のバージョン制約と大きく乖離させない（pre-commit実行時のruffと `make lint`/CI
実行時のruffでバージョンが異なると、lint結果が一致しなくなるため）。

## Type Checking

- **mypy** で静的型チェックを行う
- すべての公開関数・メソッドに型アノテーションを付与する
- `pyproject.toml` の `[tool.mypy]` で設定を管理する
- CIで `mypy src/` を実行する

```toml
[tool.mypy]
strict = true
python_version = "3.11"  # requires-python の下限と揃える
```

依存ライブラリの型スタブが新しい構文（例: numpyのPEP 695 `type`文）を使っている場合、
mypyの`python_version`をそのスタブが要求するバージョンまで引き上げてよい
（`requires-python`のランタイム対応範囲自体は変えない。型チェック専用の設定であるため）。
この場合はコメントで理由を明記する。

```toml
[tool.mypy]
strict = true
python_version = "3.12"  # numpyの型スタブがPEP 695構文を使用、mypyが3.12以降を要求するため
```

## Package Distribution (py.typed)

自作パッケージを `git+https://` などで他プロジェクトから依存指定する場合、パッケージに型情報を公開するため以下を必須とする（[PEP 561](https://peps.python.org/pep-0561/)）。

- パッケージのルートに `py.typed`（空ファイル）を配置する
- すべての公開関数・メソッド・クラスに型アノテーションを付ける
- 型スタブ（`.pyi`）は PyPI 公開パッケージでなければ不要

```toml
# pyproject.toml（py.typed をホイールに含める）
[tool.hatch.build.targets.wheel]
include = ["src/mypackage/py.typed"]
```

これにより、利用側が mypy strict モードを有効にした場合でも `import-untyped` エラーが発生せず、`mypy.overrides` に `ignore_missing_imports` の例外を追加する必要がなくなる。

## Testing

- **pytest** でユニットテスト・統合テストを実行する
- `pyproject.toml` の `[tool.pytest.ini_options]` で設定を管理する
- CIで `pytest` を実行する

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
```

## CI Integration

`CI_POLICY.md` の job 構成に従い、以下を配置する。`test` job の
`strategy.matrix.python-version` 以外では、Pythonバージョンをリテラルで pin しない
（`.python-version` を単一の情報源とする）。`actions/setup-python` を使う job
（`security` 等）では、`python-version: "X.Y"` ではなく
`python-version-file: ".python-version"` を指定する。

```yaml
lint:
  name: Lint
  steps:
    - uses: actions/checkout@v7
    - uses: astral-sh/setup-uv@v10.0.1
      with:
        enable-cache: true
    - run: uv sync --frozen
    - run: uv run ruff check .
    - run: uv run ruff format --check .
    - run: uv run mypy src/

test:
  name: Test (pytest)
  strategy:
    matrix:
      python-version: ["3.11", "3.12", "3.13", "3.14"]  # EOLまで6ヶ月以上あるバージョン
  steps:
    - uses: actions/checkout@v7
    - uses: astral-sh/setup-uv@v10.0.1
      with:
        enable-cache: true
        python-version: ${{ matrix.python-version }}
    - run: uv sync --frozen
    - run: uv run pytest
```

### `build` Job

`CI_POLICY.md` の `build` job（任意）は「実体のあるビルド作業」がある場合に配置する。Pythonでは
パッケージが**他プロジェクトから依存指定される・PyPI等で配布される**場合、`uv build` で
wheel/sdistが実際に組み立てられることを検証する（`import` チェックだけでは
`[build-system]`・`[tool.hatch.build]` の設定ミスや配布ファイル不足を検出できない）。
単体のアプリケーション（配布を想定しないCLIツール・サービス等）では、`uv run python -c
"import <pkg>"` によるインストール可能性の確認で十分とする。

```yaml
build:
  name: Build
  steps:
    - uses: actions/checkout@v7
    - uses: astral-sh/setup-uv@v10.0.1
      with:
        enable-cache: true
    - run: uv sync --frozen
    - run: uv build   # 配布パッケージの場合。非配布アプリでは import チェックでも可
```
