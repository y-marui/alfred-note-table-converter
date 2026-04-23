# Alfred note.com Table Converter

> **This is the reference (English) version.**
> The canonical (Japanese) version is [README-jp.md](README-jp.md).

An Alfred 5 workflow that converts tables between Markdown and LaTeX — directly from your clipboard.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/ci.yml/badge.svg)](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/ci.yml)
[![Charter Check](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/dev-charter-check.yml)

## Requirements

- Alfred 5 (Powerpack required)
- Python 3.11+
- [pre-commit](https://pre-commit.com/) (for development security hooks)

## Setup

```bash
git clone https://github.com/y-marui/alfred-note-table-converter
cd alfred-note-table-converter
make install
make build
```

Double-click `dist/*.alfredworkflow` to install in Alfred.

## Project Structure

```
alfred-note-table-converter/
├── src/
│   ├── alfred/         # Alfred SDK (response, router, cache, config, logger, safe_run)
│   └── app/            # Application layer (commands, services, clients)
├── workflow/           # Alfred package (info.plist, scripts/entry.py, vendor/)
├── tests/              # pytest test suite
├── scripts/            # build.sh, dev.sh, release.sh, vendor.sh
└── docs/               # Architecture and development documentation
```

## Usage

Copy a Markdown or LaTeX table to the clipboard, then trigger `tbl` in Alfred.
Press **Enter** to copy and paste the converted table.

| Command | Description |
|---|---|
| `tbl` | Detect clipboard format and convert (default) |
| `tbl convert` | Same as above (explicit) |
| `tbl open <name>` | Open a named shortcut |
| `tbl config` | View or reset configuration |
| `tbl help` | Show all commands |

## Documentation

| Document | Description |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Full architecture and layer design |
| [docs/development.md](docs/development.md) | Adding commands, managing dependencies, release |
| [docs/usage.md](docs/usage.md) | End-user usage guide |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Support

If this workflow saves you time, support is appreciated.

- [Buy Me a Coffee](https://www.buymeacoffee.com/y.marui)
- [GitHub Sponsors](https://github.com/sponsors/y-marui)

## License

MIT — see [LICENSE](LICENSE)

---
*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
