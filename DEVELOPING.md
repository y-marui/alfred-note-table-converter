# Developing

## Prerequisites

- macOS (required for Alfred)
- Go (see `go.mod` for the toolchain version)
- Alfred 5 with Powerpack
- `jq` (optional, for pretty-printed dev output): `brew install jq`
- `gh` CLI (required for releases): `brew install gh`

## Setup

```bash
git clone https://github.com/y-marui/alfred-note-table-converter
cd alfred-note-table-converter
go build ./...
```

## Daily Workflow

### Simulate Alfred locally

```bash
go run ./cmd/note-table-converter-alfred ""
go run ./cmd/note-table-converter-alfred "open repo"
go run ./cmd/note-table-converter-alfred "config"
go run ./cmd/note-table-converter-alfred "help"
```

The default `convert` command reads the real clipboard (`pbpaste`), so copy a Markdown or LaTeX
table before running it. Pipe through `jq` for pretty-printed JSON:

```bash
go run ./cmd/note-table-converter-alfred "" | jq .
```

### Run tests

```bash
make test
```

### Lint and format

```bash
make lint          # gofmt -l + go vet
make fmt           # gofmt -w (auto-fix)
```

## Adding a New Command

1. Add a `handleFoo(args string) scriptfilter.Response` function to
   `internal/tableconvcmd/tableconvcmd.go`:

```go
func handleFoo(args string) scriptfilter.Response {
	return scriptfilter.Response{
		Items: []scriptfilter.Item{
			{Title: "My command", Subtitle: "Args: " + args, Arg: args, Valid: scriptfilter.BoolPtr(true)},
		},
	}
}
```

2. Register it in `Dispatch`'s switch statement.
3. Add tests in `internal/tableconvcmd/tableconvcmd_test.go`.
4. Update `README.md`/`README-jp.md`'s usage table, `docs/specification.md`, and
   `workflow/info.plist`'s Script Filter `subtext`.

## Building the Package

```bash
make build-workflow
```

Output: `dist/<name>-<version>.alfredworkflow`

Install during development: double-click the `.alfredworkflow` file,
or drag it into Alfred Preferences → Workflows.

## Testing in Alfred

1. Build: `make build-workflow`
2. Install: `open dist/*.alfredworkflow`
3. Open Alfred, type `tbl`

During rapid iteration you can symlink `workflow/` to Alfred's workflow directory and rebuild the
binary in place, but `go run ./cmd/note-table-converter-alfred "query"` is usually faster for
logic changes.

## Releasing

```bash
# 1. Update version in workflow/info.plist
# 2. Update CHANGELOG.md
# 3. Commit
git add workflow/info.plist CHANGELOG.md
git commit -m "chore: release v1.2.3"

# 4. Tag
git tag v1.2.3
git push origin main --tags

# GitHub Actions automatically builds and releases.
```

## AI Development Workflow

This project is designed for AI-assisted development.

### Claude Code (major features, refactoring, tests)

Claude Code reads `CLAUDE.md` at the project root for context.
Use it for:
- Implementing new commands and conversion logic
- Refactoring existing code
- Writing test suites
- Reviewing architecture decisions

### GitHub Copilot (bug fixes, inline completions)

Copilot works best for:
- Fixing small bugs inline
- Completing repetitive boilerplate
- Suggesting struct/function signatures

### Gemini CLI (documentation)

Use Gemini CLI for:
- Generating/updating `README.md`
- Writing `CHANGELOG.md` entries from git log
- Creating usage examples in `docs/specification.md`

Example:
```bash
gemini "Update README.md based on the current source code in internal/"
gemini "Generate CHANGELOG entry for commits since v1.0.0"
```
