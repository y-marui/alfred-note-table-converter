# Specification

> Functional specification, behavior definition, and data flow for alfred-note-table-converter.

## Overview

This workflow triggers on the `tbl` keyword and returns a JSON result offering the converted
clipboard table. Selecting the result copies the converted table to the clipboard and pastes it
via Alfred's native Clipboard Output node — its `autopaste` option handles the paste itself, so no
Go code or separate Run Script/AppleScript step is involved.

## Alfred Object Graph

`workflow/info.plist` wires four nodes, all native Alfred objects except the Script Filter:

1. **Keyword input** (`tbl`) — the actual trigger; not a Script Filter, so it runs no script.
2. **Arguments and Variables** — passes the query through unchanged and sets the `clipboard_text`
   variable from Alfred's `{clipboard}` dynamic placeholder. Alfred passes workflow variables to
   downstream Script/Script Filter nodes as OS environment variables, so this is not a shell-text
   substitution and needs no escaping.
3. **Script Filter** (keyword-less, driven by the incoming connection) — runs
   `cmd/note-table-converter-alfred`, which reads the query from `$1` and the clipboard contents
   from `os.Getenv("clipboard_text")`.
4. **Clipboard Output** (`autopaste: true`) — copies the selected item's `arg` to the clipboard and
   pastes it into the frontmost application.

This intentionally keeps clipboard reading and pasting out of Go entirely; only the actual
Markdown ⇄ LaTeX conversion and command dispatch run as code.

## Commands

### `tbl` / `tbl convert` (default)

**Trigger:** `tbl`, `tbl convert` — any query args after `convert` are ignored; behavior is
driven entirely by clipboard contents, not the query.

**Behavior:**
1. Read the clipboard contents from the `clipboard_text` environment variable (see Alfred Object
   Graph above).
2. `internal/tableconv.DetectFormat` classifies it as `"markdown"`, `"latex"`, or `"unknown"`.
3. `"markdown"` → convert to LaTeX via `internal/tableconv.MDToLatex`. One result item, with a
   `cmd` modifier offering the same conversion using `\\\\` (four backslashes) instead of `\\`
   for row breaks.
4. `"latex"` → convert to Markdown via `internal/tableconv.LaTeXToMD`. One result item.
5. `"unknown"` → an invalid error item ("No table found in clipboard").

**Result item fields (markdown → latex):**

| Field | Value |
|---|---|
| `title` | `Markdown -> LaTeX` |
| `subtitle` | `Enter: copy+paste  \|  Cmd: copy+paste (4 backslashes)` |
| `arg` | Converted LaTeX (`\\` row breaks; copied to clipboard and pasted on Enter) |
| `mods.cmd.arg` | Same conversion with `\\\\` row breaks |

**Result item fields (latex → markdown):**

| Field | Value |
|---|---|
| `title` | `LaTeX -> Markdown` |
| `subtitle` | `Convert, copy and paste Markdown` |
| `arg` | Converted Markdown table |

---

### `tbl open <name>`

**Trigger:** `tbl open [name]`

**Behavior:** Filters a fixed set of named shortcuts (`repo`, `docs`, `issues`, each pointing at
this repository) by substring match on `name` (case-insensitive); shows all of them when `name`
is empty. Selecting a result copies its URL as `arg`. Shows an invalid "No shortcut" item, listing
all available names, when nothing matches.

---

### `tbl help`

**Trigger:** `tbl help`

**Behavior:** Display all three commands above with descriptions and autocomplete strings
(`valid: false`).

## Conversion Rules (`internal/tableconv`)

- **Markdown → LaTeX**: emits a `\begin{array}{|l|...|}` block. Every column is left-aligned
  (`l`) regardless of the Markdown separator row's alignment markers (`:---`, `---:`, `:---:` are
  not interpreted). Header cells are wrapped in `\textbf{}`, data cells in `\text{}`. A double
  `\hline \hline` appears at the very top, between header and data, and at the very bottom; a
  single `\hline` separates ordinary data rows. A cell containing `<br>` (or `<br/>`, `<br />`,
  case-insensitive) is split into continuation sub-rows sharing the same row break, where only the
  last sub-row gets a trailing `\hline`.
- **LaTeX → Markdown**: the inverse. A data row whose first cell is empty but a later cell has
  content is treated as a `<br>` continuation of the previous row and merged back into it
  (`" <br> "` joining the previous and new cell values); otherwise it becomes a new row. The
  Markdown separator row is always emitted as `---` per column.
- Both directions are round-trip safe for well-formed tables produced by the other direction (see
  `internal/tableconv/tableconv_test.go`'s `TestRoundtrip_*` cases).
