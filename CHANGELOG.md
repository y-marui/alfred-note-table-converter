# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed

- `tbl config` / `tbl config reset` — this workflow has no persisted
  settings, so the command never read or wrote any stored state; it always
  showed a static "Reset all settings"/"Configuration reset" pair of items
  that did nothing. Same dead-config-command pattern already removed from
  `alfred-paste-formatted-date`. `tbl help` no longer lists it.

### Changed

- **Breaking (implementation):** Reimplemented the workflow in Go
  (`cmd/note-table-converter-alfred` + `internal/tableconv`, `internal/tableconvcmd`,
  `internal/scriptfilter`), replacing the Python `src/alfred`/`src/app` implementation. The `tbl`
  keyword, bundle ID, and the behavior of `convert`/`open`/`help` are unchanged.
- Clipboard reading no longer shells out to `pbpaste` (previously `internal/clipboard`, now
  removed). `tbl`'s keyword is now a plain Keyword input node feeding an Arguments and Variables
  node that sets a `clipboard_text` variable from Alfred's `{clipboard}` placeholder; a
  (keyword-less) Script Filter downstream reads it as an `os.Getenv("clipboard_text")` environment
  variable. This is Alfred's documented mechanism for passing variables to scripts — not shell-text
  substitution — chosen specifically because splicing arbitrary clipboard content (this workflow's
  own LaTeX output is full of `\`, `$`, `{`, `}`) directly into a script's command-line text would
  need exact escaping-flag semantics that aren't confirmed anywhere in this project's docs.
- Alfred now invokes a compiled universal (amd64+arm64) binary directly instead of
  `python3`/`uv run python`; the `Use uv` Config Builder toggle is removed.
- Build/test tooling moved from `uv`/`ruff`/`mypy`/`pytest` to `go build`/`gofmt`/`go vet`/`go test`.
- `tbl open <name>`'s shortcuts (`repo`/`docs`/`issues`) now point at this repository instead of
  the unfixed `yourname/your-workflow` placeholder URLs left over from the template.
- The paste step no longer runs a separate `osascript`/System Events keystroke simulation after
  a fixed 0.3s delay; the Clipboard Output node's native `autopaste` option now handles it
  directly, removing that node, its race-condition-prone delay, and the macOS Automation
  permission grant for System Events it required.

### Removed

- The Python Alfred SDK (`src/alfred`: `cache`, `config`, `logger`, generic `router`) — unused
  beyond the always-empty `config` schema; `internal/tableconvcmd` now dispatches with a plain
  `switch` instead of a generic router.

## [0.1.0] - 2024-01-01

### Added

- Initial release of the Alfred Workflow Template
- Alfred SDK: `response`, `cache`, `config`, `logger`, `router`, `safe_run`
- Command-based UX: `search`, `open`, `config`, `help`
- Vendor packaging via `scripts/vendor.sh`
- Build pipeline via `scripts/build.sh`
- GitHub Actions CI (lint, test, build)
- GitHub Actions Release (tag → `.alfredworkflow` → GitHub Release)
- Full pytest test suite

[Unreleased]: https://github.com/yourname/alfred-workflow-template/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourname/alfred-workflow-template/releases/tag/v0.1.0
