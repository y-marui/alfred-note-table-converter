# UI Design

Alfred Script Filter workflows present results as a list of items in the Alfred
launcher. This document defines the UI conventions for result items in this
workflow.

## Result Item Structure

Alfred result items are JSON objects with the following fields used in this workflow:

| Field | Type | Required | Description |
|---|---|---|---|
| `title` | string | yes | Primary text (large, always visible) |
| `subtitle` | string | no | Secondary text (small, below title) |
| `arg` | string | no | Value copied to the clipboard and pasted on Enter (via the native Copy to Clipboard node) |
| `valid` | bool | yes | If false, Enter does not trigger an action |
| `autocomplete` | string | no | Text inserted into Alfred's input on Tab |
| `mods` | object | no | Modifier-key overrides — used by the `convert` command's `cmd` variant (see below) |

## Text Guidelines

### No Unicode Emoji in `title` / `subtitle`

- **Prohibited:** `🔍 Search`, `✅ Done`, `📄 Document`
- **Allowed:** ASCII symbols — `>`, `*`, `[x]`, `(!)`, `--`
- **Reason:** Emoji rendering is inconsistent across Alfred versions and macOS
  updates. ASCII symbols are universally stable.

### Empty / Error States

- No table detected in the clipboard → an informative item (`"No table found in
  clipboard"`) with `valid: false`.
- No matching shortcut (`open`) → an informative item listing the available
  names, with `valid: false`.
- Error → `cmd/note-table-converter-alfred`'s panic recovery automatically shows
  a `"Workflow Error"` item; do not hide errors silently.

## Icon

- Workflow icon: `workflow/icon.png` (PNG, any size — Alfred scales it).
- Alfred controls light/dark mode; do not ship separate light/dark icons.
- No per-item icons are used in this workflow.

## Keyboard Shortcuts

These are standard Alfred behaviors — do not override them in the workflow:

| Key | Action |
|---|---|
| ↩ Enter | Copy `arg` to clipboard and paste (native Copy to Clipboard, `autopaste`) |
| ⌘↩ | Same, using the item's `mods.cmd` override (the `convert` command's four-backslash LaTeX variant) |
| ⌘C | Copy `arg` to clipboard without pasting |
| ⌘L | Show `title` in Large Type |

## Layout Conventions by Command

### `tbl` / `tbl convert` (default)

```
title:    "Markdown -> LaTeX" | "LaTeX -> Markdown"
subtitle: "Enter: copy+paste  |  Cmd: copy+paste (4 backslashes)" | "Convert, copy and paste Markdown"
arg:      <converted table>
mods.cmd.arg: <same conversion with \\\\ row breaks>   (Markdown -> LaTeX only)
valid:    true
```

### `tbl open <name>`

```
title:    <shortcut name>
subtitle: <URL>
arg:      <URL>
valid:    true
```

### `tbl help`

```
title:    tbl <command> <args>
subtitle: <command description>
valid:    false
autocomplete: <command trigger string>
```
