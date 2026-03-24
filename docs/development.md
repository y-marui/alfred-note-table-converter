# Development Guide

## Prerequisites

- macOS (required for Alfred)
- Python 3.9+
- Alfred 5 with Powerpack
- `jq` (optional, for pretty-printed dev output): `brew install jq`
- `gh` CLI (required for releases): `brew install gh`

## Setup

```bash
git clone https://github.com/yourname/your-workflow
cd your-workflow
make install
```

## Daily workflow

### Simulate Alfred locally

```bash
make run Q="search foo"
make run Q="open repo"
make run Q="config"
make run Q=""
```

This calls `scripts/dev.sh` which:
1. Sets all `alfred_workflow_*` env vars to temp directories
2. Calls `workflow/scripts/entry.py` with your query
3. Pretty-prints the JSON output

### Run tests

```bash
make test          # fast
make test-cov      # with coverage
```

### Lint and format

```bash
make lint          # check
make format        # auto-fix
make typecheck     # mypy
```

## Adding a new command

1. Create `src/app/commands/my_cmd.py`:

```python
from alfred.response import item, output

def handle(args: str) -> None:
    output([item("My command", f"Args: {args}", arg=args)])
```

2. Register in `src/app/core.py`:

```python
from app.commands import my_cmd
router.register("my")(my_cmd.handle)
```

3. Add tests in `tests/test_commands.py`.

4. Update `docs/usage.md` and `workflow/info.plist` keyword help.

## Adding a third-party dependency

1. Add to `requirements.txt`
2. Run `make vendor`
3. Import in your code — the vendor path is added by `entry.py`

## Building the package

```bash
make build
```

Output: `dist/<name>-<version>.alfredworkflow`

Install during development: double-click the `.alfredworkflow` file,
or drag it into Alfred Preferences → Workflows.

## Testing in Alfred

1. Build: `make build`
2. Install: open `dist/*.alfredworkflow`
3. Open Alfred, type your keyword

To iterate quickly, you can also point Alfred's workflow directory directly
at the `workflow/` folder during development (see Alfred docs on workflow
symlinks), but the `make run` simulator is usually faster.

## Releasing

```bash
# 1. Update version in pyproject.toml
# 2. Update CHANGELOG.md
# 3. Commit
git add pyproject.toml CHANGELOG.md
git commit -m "chore: release v1.2.3"

# 4. Tag
git tag v1.2.3
git push origin main --tags

# GitHub Actions automatically builds and releases.
# To release manually:
make build
make release
```

## AI Development Workflow

This template is designed for AI-assisted development.

### Claude Code (major features, refactoring, tests)

Claude Code reads `CLAUDE.md` at the project root for context.
Use it for:
- Implementing new commands and services
- Refactoring existing code
- Writing test suites
- Reviewing architecture decisions

### GitHub Copilot (bug fixes, inline completions)

Copilot works best for:
- Fixing small bugs inline
- Completing repetitive boilerplate
- Suggesting type annotations

### Gemini CLI (documentation)

Use Gemini CLI for:
- Generating/updating `README.md`
- Writing `CHANGELOG.md` entries from git log
- Creating usage examples in `docs/usage.md`

Example:
```bash
gemini "Update README.md based on the current source code in src/"
gemini "Generate CHANGELOG entry for commits since v1.2.3"
```
