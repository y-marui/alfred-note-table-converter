// Package scriptfilter models Alfred's Script Filter JSON output format
// (https://www.alfredapp.com/help/workflows/inputs/script-filter/json/).
package scriptfilter

import (
	"encoding/json"
	"io"
)

// Icon is an item's icon, relative to the workflow bundle root.
type Icon struct {
	Path string `json:"path,omitempty"`
}

// Mod overrides an item's fields when a modifier key (e.g. "cmd", "alt") is
// held down.
type Mod struct {
	Valid     *bool             `json:"valid,omitempty"`
	Arg       string            `json:"arg,omitempty"`
	Subtitle  string            `json:"subtitle,omitempty"`
	Variables map[string]string `json:"variables,omitempty"`
}

// Item is one Alfred result row.
type Item struct {
	UID          string            `json:"uid,omitempty"`
	Title        string            `json:"title"`
	Subtitle     string            `json:"subtitle,omitempty"`
	Arg          string            `json:"arg,omitempty"`
	Valid        *bool             `json:"valid,omitempty"`
	Autocomplete string            `json:"autocomplete,omitempty"`
	Icon         *Icon             `json:"icon,omitempty"`
	Variables    map[string]string `json:"variables,omitempty"`
	Mods         map[string]Mod    `json:"mods,omitempty"`
}

// Response is the top-level Script Filter JSON document.
type Response struct {
	Items         []Item            `json:"items"`
	Variables     map[string]string `json:"variables,omitempty"`
	SkipKnowledge bool              `json:"skipknowledge,omitempty"`
}

// Write encodes r as JSON to w, Alfred's expected Script Filter output.
func (r Response) Write(w io.Writer) error {
	return json.NewEncoder(w).Encode(r)
}

// BoolPtr is a small helper for the Valid/*bool fields above, which must
// distinguish "absent" (Alfred defaults to valid) from an explicit false.
func BoolPtr(b bool) *bool {
	return &b
}
