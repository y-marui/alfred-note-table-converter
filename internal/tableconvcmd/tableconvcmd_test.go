package tableconvcmd

import (
	"strings"
	"testing"
)

const mdTable = `| Col1 | Col2 |
|------|------|
| a    | b    |`

const latexTable = `$$
\begin{array}{|l|l|} \hline \hline
\textbf{Col1} & \textbf{Col2} \\ \hline \hline
\text{a} & \text{b} \\ \hline \hline
\end{array}
$$`

func TestDispatch_ConvertMarkdownClipboardShowsMDToLatex(t *testing.T) {
	resp := Dispatch("", mdTable)
	if len(resp.Items) != 1 {
		t.Fatalf("len(Items) = %d, want 1", len(resp.Items))
	}
	if !strings.Contains(resp.Items[0].Title, "LaTeX") {
		t.Errorf("Title = %q, want to contain LaTeX", resp.Items[0].Title)
	}
}

func TestDispatch_ConvertLatexClipboardShowsLatexToMD(t *testing.T) {
	resp := Dispatch("", latexTable)
	if len(resp.Items) != 1 {
		t.Fatalf("len(Items) = %d, want 1", len(resp.Items))
	}
	if !strings.Contains(resp.Items[0].Title, "Markdown") {
		t.Errorf("Title = %q, want to contain Markdown", resp.Items[0].Title)
	}
}

func TestDispatch_ConvertMDArgContainsLatex(t *testing.T) {
	resp := Dispatch("", mdTable)
	arg := resp.Items[0].Arg
	if !strings.Contains(arg, `\begin{array}`) {
		t.Errorf("Arg missing \\begin{array}: %q", arg)
	}
	if !strings.Contains(arg, `\textbf{Col1}`) {
		t.Errorf("Arg missing \\textbf{Col1}: %q", arg)
	}
}

func TestDispatch_ConvertMDCmdModHasQuadrupleBackslash(t *testing.T) {
	resp := Dispatch("", mdTable)
	cmdArg := resp.Items[0].Mods["cmd"].Arg
	if !strings.Contains(cmdArg, `\\\\`) {
		t.Errorf("cmd mod Arg missing four backslashes: %q", cmdArg)
	}
}

func TestDispatch_ConvertLatexArgContainsMarkdown(t *testing.T) {
	resp := Dispatch("", latexTable)
	arg := resp.Items[0].Arg
	if !strings.Contains(arg, "| Col1 |") {
		t.Errorf("Arg missing | Col1 |: %q", arg)
	}
	if !strings.Contains(arg, "|---|") {
		t.Errorf("Arg missing |---|: %q", arg)
	}
}

func TestDispatch_ConvertUnknownClipboardShowsError(t *testing.T) {
	resp := Dispatch("", "no table here")
	title := resp.Items[0].Title
	if !strings.Contains(title, "Error") && !strings.Contains(title, "No table") {
		t.Errorf("Title = %q, want to contain Error or No table", title)
	}
}

func TestDispatch_ConvertEmptyClipboardShowsError(t *testing.T) {
	resp := Dispatch("", "")
	if resp.Items[0].Valid == nil || *resp.Items[0].Valid {
		t.Errorf("Valid = %v, want false", resp.Items[0].Valid)
	}
}

func TestDispatch_ConvertArgsAreIgnored(t *testing.T) {
	resp := Dispatch("some random query", mdTable)
	if !strings.Contains(resp.Items[0].Title, "LaTeX") {
		t.Errorf("Title = %q, want to contain LaTeX", resp.Items[0].Title)
	}
}

func TestDispatch_OpenNoArgsShowsAllShortcuts(t *testing.T) {
	resp := Dispatch("open", "")
	if len(resp.Items) != len(shortcuts) {
		t.Errorf("len(Items) = %d, want %d", len(resp.Items), len(shortcuts))
	}
}

func TestDispatch_OpenFilterByName(t *testing.T) {
	resp := Dispatch("open repo", "")
	for _, it := range resp.Items {
		if !strings.Contains(it.Title, "repo") {
			t.Errorf("Title = %q, want to contain repo", it.Title)
		}
	}
	for _, it := range resp.Items {
		if !strings.HasPrefix(it.Arg, "https://github.com/y-marui/alfred-note-table-converter") {
			t.Errorf("Arg = %q, want real repo URL", it.Arg)
		}
	}
}

func TestDispatch_OpenUnknownShortcutShowsError(t *testing.T) {
	resp := Dispatch("open nonexistent", "")
	if !strings.Contains(resp.Items[0].Title, "No shortcut") {
		t.Errorf("Title = %q, want to contain No shortcut", resp.Items[0].Title)
	}
}

func TestDispatch_ConfigShowsResetItem(t *testing.T) {
	resp := Dispatch("config", "")
	found := false
	for _, it := range resp.Items {
		if strings.Contains(it.Title, "Reset") {
			found = true
		}
	}
	if !found {
		t.Errorf("no item with Reset in title: %+v", resp.Items)
	}
}

func TestDispatch_ConfigEmptySchemaShowsOnlyReset(t *testing.T) {
	resp := Dispatch("config", "")
	if len(resp.Items) != 1 {
		t.Fatalf("len(Items) = %d, want 1", len(resp.Items))
	}
	if !strings.Contains(resp.Items[0].Title, "Reset") {
		t.Errorf("Title = %q, want to contain Reset", resp.Items[0].Title)
	}
}

func TestDispatch_ConfigResetShowsConfirmation(t *testing.T) {
	resp := Dispatch("config reset", "")
	if !strings.Contains(strings.ToLower(resp.Items[0].Title), "reset") {
		t.Errorf("Title = %q, want to contain reset", resp.Items[0].Title)
	}
}

func TestDispatch_ConfigUnknownSubcommandShowsCurrentConfig(t *testing.T) {
	resp := Dispatch("config unknown-subcommand", "")
	if len(resp.Items) == 0 {
		t.Errorf("len(Items) = 0, want > 0")
	}
}

func TestDispatch_HelpShowsAllCommands(t *testing.T) {
	resp := Dispatch("help", "")
	if len(resp.Items) != len(helpCommands) {
		t.Errorf("len(Items) = %d, want %d", len(resp.Items), len(helpCommands))
	}
}

func TestDispatch_HelpAllItemsInvalid(t *testing.T) {
	resp := Dispatch("help", "")
	for _, it := range resp.Items {
		if it.Valid == nil || *it.Valid {
			t.Errorf("item %q Valid = %v, want false", it.Title, it.Valid)
		}
	}
}
