# Alfred note.com Table Converter

> **This is the reference (English) version.**
> The canonical (Japanese) version is [README-jp.md](README-jp.md).

An Alfred 5 workflow that converts tables between Markdown and LaTeX — directly from your clipboard.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![CI](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/ci.yml/badge.svg)](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/ci.yml)
[![Charter Check](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/y-marui/alfred-note-table-converter/actions/workflows/dev-charter-check.yml)
[![GitHub Sponsors](https://img.shields.io/github/sponsors/y-marui?style=social)](https://github.com/sponsors/y-marui)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-donate-yellow.svg)](https://www.buymeacoffee.com/y.marui)

## Requirements

- Alfred 5 (Powerpack required)
- Go (see `go.mod` for the version)
- [pre-commit](https://pre-commit.com/) (for development security hooks)

## Setup

```bash
git clone https://github.com/y-marui/alfred-note-table-converter
cd alfred-note-table-converter
make build-workflow
```

Double-click `dist/*.alfredworkflow` to install in Alfred.

## Project Structure

```
alfred-note-table-converter/
├── cmd/note-table-converter-alfred/  # Entry point for the binary Alfred invokes
├── internal/
│   ├── tableconv/      # Markdown ⇄ LaTeX conversion logic (no Alfred awareness)
│   ├── tableconvcmd/   # Command dispatch + Script Filter response building
│   └── scriptfilter/   # Alfred Script Filter JSON types
├── workflow/           # Alfred package (info.plist, icon.png)
├── scripts/            # build-workflow.sh, extract-changelog.sh
└── docs/               # Architecture and specification documentation
```

## Usage

Copy a Markdown or LaTeX table to the clipboard, then trigger `tbl` in Alfred.
Press **Enter** to copy and paste the converted table.

| Command | Description |
|---|---|
| `tbl` | Detect clipboard format and convert (default) |
| `tbl convert` | Same as above (explicit) |
| `tbl open <name>` | Open a named shortcut |
| `tbl help` | Show all commands |

## Documentation

| Document | Description |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Full architecture and layer design |
| [docs/specification.md](docs/specification.md) | Functional specification and data flow |
| [docs/file-map.md](docs/file-map.md) | File-level dependency map |
| [docs/ui-design.md](docs/ui-design.md) | Alfred result item UI conventions |
| [docs/configuration-builder.md](docs/configuration-builder.md) | This project's Configuration Builder settings |
| [DEVELOPING.md](DEVELOPING.md) | Adding commands, release process |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT — see [LICENSE](LICENSE)

---
*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
