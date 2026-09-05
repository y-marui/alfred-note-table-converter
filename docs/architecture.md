# Architecture

## Overview

An Alfred Workflow (Go): `cmd/note-table-converter-alfred` is the single
universal (amd64+arm64) binary `workflow/info.plist` invokes. The `tbl`
keyword is a plain Keyword input node, not a Script Filter — it feeds an
Arguments and Variables node that sets the `clipboard_text` variable from
Alfred's `{clipboard}` placeholder, which reaches this binary as an OS
environment variable (Alfred passes workflow variables to Script/Script
Filter nodes as env vars); the binary never reads the clipboard itself. That
variable, together with the query (`$1`), is detected as a Markdown or LaTeX
table, converted via `internal/tableconv`, and printed as Alfred Script
Filter JSON via `internal/scriptfilter`. Selecting a result copies the
converted table to the clipboard and pastes it via Alfred's own native
Clipboard Output node (its `autopaste` option) — no Go code or separate Run
Script/AppleScript step is involved in that step either; see
[docs/specification.md](specification.md) for the full data flow.
`scripts/build-workflow.sh` packages the binary with `workflow/info.plist`
and `workflow/icon.png` into a `.alfredworkflow`.

This structure — a thin `cmd/` entry point over independently testable
`internal/` packages, no generic command-router abstraction, Script Filter
JSON via a small `scriptfilter` package — deliberately matches
[y-marui/alfred-clean-invisible-text](https://github.com/y-marui/alfred-clean-invisible-text),
[y-marui/alfred-markdown-ref](https://github.com/y-marui/alfred-markdown-ref),
and [y-marui/alfred-password-generator](https://github.com/y-marui/alfred-password-generator),
this author's other Alfred Workflows already implemented in Go. This workflow
itself was originally a Python implementation
([`src/alfred`/`src/app`](https://github.com/y-marui/alfred-note-table-converter/tree/v0.1.0/src));
see `CHANGELOG.md`'s `[Unreleased]` entry for what changed and why in that
rewrite.

## Entry Points

- `cmd/note-table-converter-alfred` — a single command, no subcommands. The
  query following the `tbl` keyword (e.g. `""`, `"open repo"`, `"config
  reset"`, `"help"`) determines behavior; see
  [docs/specification.md](specification.md#commands).

One Alfred trigger reaches it: the `tbl` keyword, wired in
`workflow/info.plist` as a Keyword input → Arguments and Variables →
(keyword-less) Script Filter chain — see
[docs/specification.md](specification.md#alfred-object-graph).

## Directory Structure

| Directory | Role |
|---|---|
| `cmd/note-table-converter-alfred/` | The binary Alfred invokes; recovers panics into a Script Filter error item and writes the response |
| `internal/tableconvcmd/` | Query dispatch and the four command handlers (`convert`, `open`, `config`, `help`) — builds the Alfred result rows |
| `internal/tableconv/` | Markdown ⇄ LaTeX table conversion, unit tested independently of Alfred |
| `internal/scriptfilter/` | Alfred Script Filter JSON response types |
| `workflow/` | `info.plist` (the Alfred object graph), `icon.png` |
| `scripts/build-workflow.sh` | Builds the universal binary and packages `workflow/` into `dist/*.alfredworkflow` |
| `scripts/extract-changelog.sh` | Extracts one version's notes from `CHANGELOG.md` for GitHub Releases |
| `docs/` | Specification, file map |
| `docs/dev-charter/` | Shared dev-charter (`git subtree`) |

## Key Dependencies

None. Every `internal/` package uses only the Go standard library
(`regexp`, `strings`, `encoding/json`). Clipboard I/O is delegated entirely
to Alfred's native nodes (see Overview) — no package shells out to
`pbpaste`/`pbcopy`.
