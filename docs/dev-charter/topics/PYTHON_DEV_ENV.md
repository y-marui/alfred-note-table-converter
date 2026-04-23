# Python Development Environment

Pythonプロジェクト共通の開発環境構成を定義する。

## Version Policy

| 項目 | 基準 | 2026-04-23時点の例 |
|---|---|---|
| **開発バージョン**（`.python-version`） | 最新安定版 | 3.13 |
| **サポート範囲**（`requires-python`） | EOLまで6ヶ月以上あるバージョン | >=3.11 |
| **CIマトリクス** | サポート対象の全バージョン | 3.11, 3.12, 3.13 |

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

## Type Checking

- **mypy** で静的型チェックを行う
- すべての公開関数・メソッドに型アノテーションを付与する
- `pyproject.toml` の `[tool.mypy]` で設定を管理する
- CIで `mypy src/` を実行する

```toml
[tool.mypy]
strict = true
```

## Testing

- **pytest** でユニットテスト・統合テストを実行する
- `pyproject.toml` の `[tool.pytest.ini_options]` で設定を管理する
- CIで `pytest` を実行する

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
```

## CI Integration

`CI_POLICY.md` の job 構成に従い、以下を配置する：

```yaml
lint:
  name: Lint
  steps:
    - uses: actions/checkout@v4
    - uses: astral-sh/setup-uv@v5
    - run: uv sync --frozen
    - run: uv run ruff check .
    - run: uv run ruff format --check .
    - run: uv run mypy src/

test:
  name: Test (pytest)
  strategy:
    matrix:
      python-version: ["3.11", "3.12", "3.13"]  # EOLまで6ヶ月以上あるバージョン
  steps:
    - uses: actions/checkout@v4
    - uses: astral-sh/setup-uv@v5
    - run: uv sync --frozen
    - run: uv run pytest
```
