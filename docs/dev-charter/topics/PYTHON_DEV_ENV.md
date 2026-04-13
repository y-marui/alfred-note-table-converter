# Python Development Environment

Pythonプロジェクト共通の開発環境構成を定義する。

## Runtime Management

- **pyenv** でPythonバージョンを管理する
- `.python-version` をリポジトリに含め、使用するバージョンを固定する

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
requires-python = ">=3.12"
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
  steps:
    - uses: actions/checkout@v4
    - uses: astral-sh/setup-uv@v5
    - run: uv sync --frozen
    - run: uv run pytest
```
