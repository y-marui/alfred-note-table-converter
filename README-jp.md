# Alfred note.com Table Converter

> **このファイルは正本（日本語版）です。**
> 英語版（参照）は [README.md](README.md) を参照してください。

Alfred 5 ワークフロー — クリップボードにある表を Markdown と LaTeX 形式で相互変換します。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/ci.yml/badge.svg)](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/ci.yml)
[![Charter Check](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/dev-charter-check.yml)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/y-marui?style=social)](https://github.com/sponsors/y-marui)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-donate-yellow.svg)](https://www.buymeacoffee.com/y.marui)

## Requirements

- Alfred 5（Powerpack が必要）
- Python 3.11+
- [pre-commit](https://pre-commit.com/)（開発用セキュリティフック）

## Setup

```bash
git clone https://github.com/y-marui/alfred-note-table-converter
cd alfred-note-table-converter
make install
make build
```

`dist/*.alfredworkflow` をダブルクリックして Alfred にインストールします。

## Project Structure

```
alfred-note-table-converter/
├── src/
│   ├── alfred/         # Alfred SDK (response, router, cache, config, logger, safe_run)
│   └── app/            # アプリケーション層 (commands, services, clients)
├── workflow/           # Alfred パッケージ (info.plist, scripts/entry.py, vendor/)
├── tests/              # pytest テストスイート
├── scripts/            # build.sh, dev.sh, release.sh, vendor.sh
└── docs/               # アーキテクチャ・開発ドキュメント
```

## Usage

クリップボードに Markdown または LaTeX の表をコピーし、Alfred で `tbl` を起動します。
**Enter** を押すと、変換した表をコピー＆ペーストします。

| コマンド | 説明 |
|---|---|
| `tbl` | クリップボードの形式を検出して変換（デフォルト） |
| `tbl convert` | 同上（明示的） |
| `tbl open <name>` | ショートカットを開く |
| `tbl config` | 設定の確認 / リセット |
| `tbl help` | コマンド一覧を表示 |

## Documentation

| ドキュメント | 内容 |
|---|---|
| [docs/architecture.md](docs/architecture.md) | アーキテクチャ全体設計 |
| [docs/development.md](docs/development.md) | コマンド追加・依存関係管理・リリース手順 |
| [docs/usage.md](docs/usage.md) | エンドユーザー向け利用ガイド |

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## Changelog

[CHANGELOG.md](CHANGELOG.md) を参照してください。

## License

MIT — [LICENSE](LICENSE) を参照

---
*この文書には英語版 [README.md](README.md) があります。編集時は同一コミットで更新してください。*
