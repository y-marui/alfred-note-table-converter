// Package tableconvcmd dispatches an Alfred tbl query to the matching
// command handler and builds the Script Filter response.
//
// Commands:
//
//	tbl [convert]      — convert the clipboard table (default)
//	tbl open <name>    — open a named shortcut
//	tbl help           — show available commands
package tableconvcmd

import (
	"strings"

	"github.com/y-marui/alfred-note-table-converter/internal/scriptfilter"
	"github.com/y-marui/alfred-note-table-converter/internal/tableconv"
)

// Dispatch parses the raw Alfred query and routes it to the matching
// command, falling back to convert (which ignores its args entirely and
// converts clipboardText) for "convert" and any unmatched query.
func Dispatch(query, clipboardText string) scriptfilter.Response {
	command, args := splitFirst(query)
	switch strings.ToLower(command) {
	case "open":
		return handleOpen(args)
	case "help":
		return handleHelp(args)
	default:
		return handleConvert(clipboardText)
	}
}

func splitFirst(query string) (first, rest string) {
	fields := strings.Fields(query)
	if len(fields) == 0 {
		return "", ""
	}
	return fields[0], strings.Join(fields[1:], " ")
}

// handleConvert detects the clipboard table format and offers conversion.
// Enter copies the converted table (\\ row breaks) to the clipboard and
// pastes it; Cmd+Enter does the same with \\\\ (4 backslashes).
func handleConvert(clipboardText string) scriptfilter.Response {
	switch tableconv.DetectFormat(clipboardText) {
	case "markdown":
		converted := tableconv.MDToLatex(clipboardText, false)
		converted4bs := tableconv.MDToLatex(clipboardText, true)
		return scriptfilter.Response{
			Items: []scriptfilter.Item{
				{
					UID:      "convert-md-to-latex",
					Title:    "Markdown -> LaTeX",
					Subtitle: "Enter: copy+paste  |  Cmd: copy+paste (4 backslashes)",
					Arg:      converted,
					Valid:    scriptfilter.BoolPtr(true),
					Mods: map[string]scriptfilter.Mod{
						"cmd": {
							Subtitle: "Markdown -> LaTeX (4 backslashes)",
							Arg:      converted4bs,
						},
					},
				},
			},
		}
	case "latex":
		return scriptfilter.Response{
			Items: []scriptfilter.Item{
				{
					UID:      "convert-latex-to-md",
					Title:    "LaTeX -> Markdown",
					Subtitle: "Convert, copy and paste Markdown",
					Arg:      tableconv.LaTeXToMD(clipboardText),
					Valid:    scriptfilter.BoolPtr(true),
				},
			},
		}
	default:
		return scriptfilter.Response{
			Items: []scriptfilter.Item{
				errorItem("No table found in clipboard", "Copy a Markdown or LaTeX table first"),
			},
		}
	}
}

// shortcut is one named URL offered by "tbl open <name>".
type shortcut struct {
	name, url string
}

var shortcuts = []shortcut{
	{"repo", "https://github.com/y-marui/alfred-note-table-converter"},
	{"docs", "https://github.com/y-marui/alfred-note-table-converter/tree/main/docs"},
	{"issues", "https://github.com/y-marui/alfred-note-table-converter/issues"},
}

// handleOpen shows shortcuts matching name (or all, if name is empty).
func handleOpen(args string) scriptfilter.Response {
	query := strings.ToLower(strings.TrimSpace(args))

	var items []scriptfilter.Item
	for _, sc := range shortcuts {
		if query == "" || strings.Contains(sc.name, query) {
			items = append(items, scriptfilter.Item{
				UID:          "open-" + sc.name,
				Title:        sc.name,
				Subtitle:     sc.url,
				Arg:          sc.url,
				Autocomplete: "open " + sc.name,
				Valid:        scriptfilter.BoolPtr(true),
			})
		}
	}
	if len(items) == 0 {
		names := make([]string, len(shortcuts))
		for i, sc := range shortcuts {
			names[i] = sc.name
		}
		return scriptfilter.Response{
			Items: []scriptfilter.Item{
				{
					Title:    `No shortcut "` + args + `"`,
					Subtitle: "Available: " + strings.Join(names, ", "),
					Valid:    scriptfilter.BoolPtr(false),
				},
			},
		}
	}
	return scriptfilter.Response{Items: items}
}

type helpCommand struct {
	cmd, desc, autocomplete string
}

var helpCommands = []helpCommand{
	{"convert", "Convert clipboard table: Markdown <-> LaTeX (default)", "tbl convert"},
	{"open <name>", "Open a named shortcut", "tbl open "},
	{"help", "Show this help", "tbl help"},
}

// handleHelp lists all available commands.
func handleHelp(_ string) scriptfilter.Response {
	items := make([]scriptfilter.Item, len(helpCommands))
	for i, c := range helpCommands {
		items[i] = scriptfilter.Item{
			UID:          "help-" + strings.Fields(c.cmd)[0],
			Title:        "tbl " + c.cmd,
			Subtitle:     c.desc,
			Autocomplete: c.autocomplete,
			Valid:        scriptfilter.BoolPtr(false),
		}
	}
	return scriptfilter.Response{Items: items}
}

func errorItem(title, subtitle string) scriptfilter.Item {
	return scriptfilter.Item{
		Title:    "Error: " + title,
		Subtitle: subtitle,
		Valid:    scriptfilter.BoolPtr(false),
	}
}
