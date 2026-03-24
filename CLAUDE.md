# CLAUDE.md — Alfred Workflow Template

> **For full project context and dev-charter policies, read `AI_CONTEXT.md` first.**

This file provides Claude Code with quick-access context for developing this Alfred Workflow.

## Project overview

An Alfred 5 Script Filter workflow template.
Python 3.9+, layered architecture, OSS-ready.

## Quick orientation

```
src/alfred/     ← Alfred SDK (response, router, cache, config, logger, safe_run)
src/app/        ← Application logic (commands, services, clients)
workflow/       ← Alfred package (info.plist, scripts/entry.py, vendor/)
tests/          ← pytest test suite
scripts/        ← build.sh, dev.sh, release.sh, vendor.sh
```

Full architecture: `docs/architecture.md`

## Development commands

```bash
make install       # install dev deps
make run Q="search foo"  # simulate Alfred locally
make test          # run tests
make lint          # ruff + black check
make typecheck     # mypy
make build         # produce dist/*.alfredworkflow
```

## Adding a new command

1. Create `src/app/commands/my_cmd.py` with `handle(args: str) -> None`
2. Register in `src/app/core.py`: `router.register("my")(my_cmd.handle)`
3. Add tests in `tests/test_commands.py`

## Architecture rules

- `workflow/scripts/entry.py` is the **only** file Alfred executes. No business logic here.
- `src/alfred/` contains **only** Alfred SDK helpers — no application logic.
- Commands call services. Services call clients. Never skip layers.
- All `output()` calls go through `alfred.response.output()`.
- Always wrap `main()` in `safe_run()` — unhandled exceptions = blank Alfred.

## Testing rules

- Test `src/app/` (commands, services, clients) — these are pure Python.
- Mock external API calls in `ApiClient`. Never make real HTTP calls in tests.
- `conftest.py` sets Alfred env vars to tmp dirs automatically.
- `alfred/` SDK helpers are tested in `tests/test_alfred.py`.

## Code style

- ruff + black, line length 100
- Type hints required on all public functions
- `from __future__ import annotations` at the top of every module

## Performance target

Script Filter response < 100ms.
Use `alfred.cache.Cache` for any network calls.
Cache TTL default: 300s (5 min).

## Dependency management

Runtime dependencies → `requirements.txt` → vendored into `workflow/vendor/`
Dev dependencies → `pyproject.toml [project.optional-dependencies.dev]`

Keep runtime deps minimal. Every package adds to workflow size.

## Release process

```bash
# bump version in pyproject.toml
git tag v1.2.3
git push --tags
# GitHub Actions handles the rest
```

## AI tool roles

| Tool | Use for |
|---|---|
| Claude Code | Project setup, large-scale changes, architecture, refactoring |
| GitHub Copilot | Bug fixes, small implementation, unit test authoring |
| Gemini CLI | Docs (README, CHANGELOG, usage.md, store descriptions) |

When using multiple AI tools simultaneously, treat Copilot suggestions as
reference only during Claude Code sessions — do not accept blindly.

## Pre-coding checklist

Before starting work, confirm if any of these are unclear:

- Goal / completion criteria
- Language / framework / version constraints
- New code vs existing code modification
- Whether tests are required
- Scope of impact

Do **not** ask about code style, file placement, or minor implementation
details — follow existing patterns in the codebase.

## Error handling stance

When an error occurs: **diagnose root cause → explain fix plan → implement**.
Never retry the same failing command. Never skip hooks (`--no-verify`).
