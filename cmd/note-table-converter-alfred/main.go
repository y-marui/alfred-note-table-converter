// Command note-table-converter-alfred is the binary the packaged Alfred
// Workflow invokes (see workflow/info.plist). An Arguments and Variables
// node upstream of this binary's Script Filter node sets the clipboard_text
// variable from Alfred's {clipboard} placeholder, so Alfred hands us the
// clipboard contents as an environment variable rather than this binary
// reading the clipboard itself. The query following the "tbl" keyword
// arrives as $1, e.g. "tbl open repo".
package main

import (
	"fmt"
	"os"

	"github.com/y-marui/alfred-note-table-converter/internal/scriptfilter"
	"github.com/y-marui/alfred-note-table-converter/internal/tableconvcmd"
)

func main() {
	query := ""
	if len(os.Args) > 1 {
		query = os.Args[1]
	}
	clipboardText := os.Getenv("clipboard_text")
	writeResponse(dispatch(query, clipboardText))
}

// dispatch recovers from any panic in tableconvcmd, mirroring the Python
// workflow's safe_run: an unhandled failure must still produce a visible
// Script Filter error item rather than empty/invalid output.
func dispatch(query, clipboardText string) (resp scriptfilter.Response) {
	defer func() {
		if r := recover(); r != nil {
			resp = errorResponse(fmt.Sprintf("%v", r))
		}
	}()
	return tableconvcmd.Dispatch(query, clipboardText)
}

func writeResponse(resp scriptfilter.Response) {
	if err := resp.Write(os.Stdout); err != nil {
		fmt.Fprintln(os.Stderr, "note-table-converter-alfred: writing response:", err)
		os.Exit(1)
	}
}

func errorResponse(message string) scriptfilter.Response {
	return scriptfilter.Response{
		Items: []scriptfilter.Item{
			{
				Title:    "Workflow Error",
				Subtitle: message,
				Arg:      message,
				Valid:    scriptfilter.BoolPtr(false),
			},
		},
	}
}
