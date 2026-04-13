# Python CLI

PythonでCLIを実装する場合の標準構成を定義する。

## Library Stack

| 役割 | ライブラリ |
|---|---|
| CLI引数 | `typer` |
| 設定管理 | `pydantic-settings` |

## Configuration Priority

```
CLI引数 > 環境変数・.env > グローバル設定ファイル > デフォルト値
```

## Config File Location

```
$XDG_CONFIG_HOME/appname   # グローバル設定（fallback）
.env                        # プロジェクトローカル（優先）
```

`XDG_CONFIG_HOME` 未設定時は `~/.config` にフォールバック。XDG Base Directory 仕様に従い、他ツールと一貫性を保つ。

## Settings Skeleton

```python
import os
from pathlib import Path
from pydantic_settings import BaseSettings, SettingsConfigDict

XDG_CONFIG_HOME = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
CONFIG_FILE = XDG_CONFIG_HOME / "appname"

class Settings(BaseSettings):
    api_key: str = ""
    debug: bool = False
    timeout: int = 30

    model_config = SettingsConfigDict(
        env_file=[CONFIG_FILE, ".env"],
        env_prefix="APP_",
    )
```

## Missing Config Handling

設定ファイルが存在しない場合は、単純にエラー終了せず作成を促す。

### For development (リポジトリ内で使う場合)

README に以下を記載し、手動コピーを案内する：

```markdown
## Setup

cp .env.example .env
# .env を編集して必要な値を設定してください
```

### For installed package (pip/uv install した場合)

設定ファイルのコピーは `init` コマンドとして独立させる。
`ensure_config()` はその `init` コマンドの実行を促すだけにとどめる。

**`init` コマンド（設定ファイルのセットアップ）：**

```python
import shutil
import typer
from pathlib import Path

EXAMPLE_FILE = Path(__file__).parent / ".env.example"

@app.command()
def init(yes: bool = typer.Option(False, "--yes", "-y", help="確認をスキップする")) -> None:
    """グローバル設定ファイルを初期化する。"""
    if CONFIG_FILE.exists():
        typer.echo(f"設定ファイルはすでに存在します: {CONFIG_FILE}")
        raise typer.Exit()

    if not EXAMPLE_FILE.exists():
        typer.echo("テンプレートファイルが見つかりません。", err=True)
        raise typer.Exit(1)

    if not yes and not typer.confirm(f"{CONFIG_FILE} を作成しますか？"):
        raise typer.Exit()

    CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(EXAMPLE_FILE, CONFIG_FILE)
    typer.echo(f"設定ファイルを作成しました: {CONFIG_FILE}")
    typer.echo("必要な値を設定してから再度実行してください。")
```

**`ensure_config()`（設定が必須のコマンド専用）：**

設定がなければエラーを出し、`init` コマンドの実行を促す。
設定がオプションのコマンドでは呼び出さない。

```python
def ensure_config() -> None:
    if CONFIG_FILE.exists() or Path(".env").exists():
        return
    typer.echo("設定ファイルが見つかりません。", err=True)
    typer.echo("まず次のコマンドを実行してください: appname init", err=True)
    raise typer.Exit(1)
```

設定が必須のコマンドでのみ呼び出す：

```python
@app.command()
def run() -> None:
    """設定が必須なコマンド。"""
    ensure_config()
    ...
```

## Non-Interactive Execution

**全てのコマンドで、引数を適切に指定すれば対話プロンプトなしに実行できることを保証する。**
これにより CI・スクリプトからの非対話実行を保証する。

対話プロンプトは利便性のために使ってよい。ただし、**そのプロンプトに対応する引数を必ず用意し、引数が指定された場合はプロンプトをスキップする**。

| プロンプトの種類 | 対応する引数パターン |
|---|---|
| 確認（yes/no） | `--yes` / `-y` フラグ（上記 `init` コマンドが例） |
| 値の入力 | 対応するオプション引数 |

値の入力プロンプトの例：

```python
@app.command()
def login(token: str = typer.Option(None, "--token", help="APIトークン")) -> None:
    if token is None:
        token = typer.prompt("APIトークンを入力してください", hide_input=True)
    _save_token(token)
```

CI での実行例：

```bash
appname init --yes
appname login --token "$API_TOKEN"
```

## Key Points

- 設定ファイル形式は `.env` に統一する（global/local で同じ書き方）
- `env_file` は後ろに指定したファイルが優先される。存在しないファイルは無視される
- デフォルト値はフィールドに直接書く（TOML設定ファイルは不要）
- `.env.example` はリポジトリに含め、実際の `.env` は `.gitignore` に追加する
