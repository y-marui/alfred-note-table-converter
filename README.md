# Alfred Workflow Template

> **This is the English (reference) version.**
> For the Japanese canonical version, see [README-jp.md](README-jp.md).

> Production-ready template for building Alfred 5 Script Filter workflows.
> Start shipping in 10 minutes.

[![CI](https://github.com/y-marui/alfred-workflow-template/actions/workflows/ci.yml/badge.svg)](https://github.com/y-marui/alfred-workflow-template/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

| Field | Value |
|---|---|
| Target | Alfred 5 Script Filter workflow |
| Team size | Individual to small team (1–3 people) |
| Language | English (OSS) |
| Runtime | Python 3.9+, Alfred 5 |
| AI tools | Claude Code / GitHub Copilot / Gemini CLI |

## Features

- ✅ **Layered architecture** — Alfred boundary isolated from business logic
- ✅ **Lightweight Alfred SDK** — response builder, router, cache, config, logger
- ✅ **Command-based UX** — `wf search`, `wf open`, `wf config`, `wf help`
- ✅ **Full test suite** — pytest, no Alfred required to run tests
- ✅ **CI/CD** — lint, test, build, and release via GitHub Actions
- ✅ **Vendor packaging** — third-party deps bundled in `vendor/`
- ✅ **AI-ready** — `AI_CONTEXT.md` + `CLAUDE.md` for AI assistant context

## Requirements

- Alfred 5 (Powerpack required for Script Filter)
- Python 3.9+
- [pre-commit](https://pre-commit.com/) (for security hooks)

## Quick Start (developers)

```bash
git clone https://github.com/yourname/alfred-workflow-template
cd alfred-workflow-template

# Install dev dependencies
make install

# Simulate Alfred locally
make run Q="search foo"
make run Q="help"

# Run tests
make test

# Build workflow package
make build
# → dist/workflow-template-0.1.0.alfredworkflow
```

Double-click `dist/*.alfredworkflow` to install in Alfred.

## Usage

```
wf <query>           search (default)
wf search <query>    search
wf open <name>       open a named shortcut
wf config            view / reset settings
wf help              show all commands
```

## Project Structure

```
alfred-workflow-template/
├── src/
│   ├── alfred/         # Alfred SDK (response, router, cache, config, logger, safe_run)
│   └── app/            # Application layer (commands, services, clients)
├── workflow/           # Alfred package (info.plist, scripts/entry.py, vendor/)
├── tests/              # pytest test suite
├── scripts/            # build.sh, dev.sh, release.sh, vendor.sh
└── docs/               # Architecture, development, and usage documentation
```

## Documentation

| Document | Description |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Full architecture and layer design |
| [docs/development.md](docs/development.md) | Adding commands, managing dependencies, release |
| [docs/usage.md](docs/usage.md) | End-user usage guide |

## AI-Assisted Development

This template is configured for AI-assisted development.

| Tool | Role |
|---|---|
| Claude Code | Architecture, large-scale changes, refactoring |
| GitHub Copilot | Bug fixes, small implementation, unit tests |
| Gemini CLI | Documentation management |

See [`AI_CONTEXT.md`](AI_CONTEXT.md) and [`CLAUDE.md`](CLAUDE.md) for session context.

## Customizing this template

1. Edit `workflow/info.plist`:
   - Replace `bundleid` with your bundle ID (`com.yourname.workflowname`)
   - Replace the `keyword` (`wf`) with your trigger keyword
   - Run `uuidgen` and replace the placeholder UIDs
2. Replace `src/app/clients/api_client.py` with your API
3. Update the workflow name in `pyproject.toml`
4. Update shortcuts in `src/app/commands/open_cmd.py`
5. Add your `workflow/icon.png`

## Release

```bash
# 1. Bump version in pyproject.toml
# 2. Tag and push
git tag v1.2.3
git push --tags
# GitHub Actions builds .alfredworkflow and creates a GitHub Release
```

## Support

If this template saves you time, support is appreciated.

- [Buy Me a Coffee](https://www.buymeacoffee.com/y.marui)
- [GitHub Sponsors](https://github.com/sponsors/y-marui)

## License

MIT — see [LICENSE](LICENSE)
