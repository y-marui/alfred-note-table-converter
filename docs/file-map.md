# File Map

> File-level dependency map for alfred-note-table-converter.
> Update this as the codebase evolves.

## Entry Points

| File | Role |
|---|---|
| `cmd/note-table-converter-alfred/main.go` | Alfred executes this binary — the sole entry point |

## Call Flow

```
cmd/note-table-converter-alfred/main.go
  ├─ os.Getenv("clipboard_text")                      [set by the Arguments and Variables node from {clipboard}]
  └─ dispatch(query, clipboardText)                   [recovers panics into an error item]
       └─ internal/tableconvcmd.Dispatch(query, clipboardText)
            ├─ handleConvert(clipboardText)            [default]
            │    ├─ internal/tableconv.DetectFormat(clipboardText)
            │    ├─ internal/tableconv.MDToLatex(clipboardText, quadrupleBackslash)
            │    └─ internal/tableconv.LaTeXToMD(clipboardText)
            ├─ handleOpen(args)
            └─ handleHelp(args)
```

## Package Dependency Table

| Package | Imports from | Notes |
|---|---|---|
| `internal/scriptfilter` | stdlib only | Alfred Script Filter JSON types (`Item`, `Response`) and `Write` |
| `internal/tableconv` | stdlib only (`regexp`, `strings`, `bufio`) | Core Markdown ⇄ LaTeX conversion logic — `DetectFormat`, `MDToLatex`, `LaTeXToMD` |
| `internal/tableconvcmd` | `internal/tableconv`, `internal/scriptfilter` | Query dispatch, the three command handlers |
| `cmd/note-table-converter-alfred` | `internal/tableconvcmd`, `internal/scriptfilter` | Reads `os.Args[1]` and the `clipboard_text` env var, recovers panics, writes JSON to stdout |

## Tests

| File | Tests |
|---|---|
| `internal/tableconv/tableconv_test.go` | `DetectFormat`, `MDToLatex` (double hline placement, multibyte cells, quadruple-backslash mode, `<br>` expansion), `LaTeXToMD` (separator row, `<br>` continuation merge), and md↔latex roundtrips |
| `internal/tableconvcmd/tableconvcmd_test.go` | Command dispatch (convert, open, help), clipboard-format branching, error items |
