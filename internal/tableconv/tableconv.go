// Package tableconv converts tables between Markdown and LaTeX array format.
// It has no Alfred awareness — callers pass in raw text and get raw text
// back.
package tableconv

import (
	"bufio"
	"regexp"
	"strings"
)

var (
	brSplitRe          = regexp.MustCompile(`(?i)\s*<br\s*/?>\s*`)
	mdSeparatorRe      = regexp.MustCompile(`^[\s|:-]+$`)
	hlineOnlyRe        = regexp.MustCompile(`^(\\hline[\s　]*)+$`)
	trailingRowBreakRe = regexp.MustCompile(`\s*\\\\+.*$`)
)

// DetectFormat reports whether text is a Markdown table, a LaTeX table, or
// neither ("unknown").
func DetectFormat(text string) string {
	stripped := strings.TrimSpace(text)
	if strings.HasPrefix(stripped, "$") && strings.Contains(stripped, `\begin{array}`) {
		return "latex"
	}
	lines := nonBlankLines(stripped)
	if len(lines) >= 2 && strings.Contains(lines[0], "|") && mdSeparatorRe.MatchString(lines[1]) {
		return "markdown"
	}
	return "unknown"
}

// MDToLatex converts a Markdown table to LaTeX array format.
//
// LaTeX format:
//   - Double hline at top, between header and data, and at bottom.
//   - Header cells wrapped in \textbf{}, data cells in \text{}.
//   - Cells containing <br> are split into continuation sub-rows.
//
// quadrupleBackslash uses \\\\ instead of \\ for row breaks.
func MDToLatex(text string, quadrupleBackslash bool) string {
	lines := trimmedNonBlankLines(text)

	header := parseMDRow(lines[0])
	var dataRows [][]string
	for _, ln := range lines[2:] {
		if ln != "" {
			dataRows = append(dataRows, parseMDRow(ln))
		}
	}

	ncols := len(header)
	colSpec := "|" + strings.Repeat("l|", ncols)
	rowBr := ` \\`
	if quadrupleBackslash {
		rowBr = ` \\\\`
	}

	out := []string{
		"$$",
		`\begin{array}{` + colSpec + `} \hline \hline`,
	}

	headerCells := make([]string, len(header))
	for i, cell := range header {
		headerCells[i] = `\textbf{` + cell + `}`
	}
	out = append(out, strings.Join(headerCells, " & ")+rowBr+` \hline \hline`)

	for i, row := range dataRows {
		isLast := i == len(dataRows)-1
		subRows := expandBR(row)
		for j, subRow := range subRows {
			isLastSub := j == len(subRows)-1
			cells := make([]string, len(subRow))
			for k, c := range subRow {
				if c != "" {
					cells[k] = `\text{` + c + `}`
				}
			}
			cellsLatex := strings.Join(cells, " & ")
			if isLastSub {
				hline := `\hline`
				if isLast {
					hline = `\hline \hline`
				}
				out = append(out, cellsLatex+rowBr+" "+hline)
			} else {
				out = append(out, cellsLatex+rowBr)
			}
		}
	}

	out = append(out, `\end{array}`, "$$")
	return strings.Join(out, "\n")
}

// LaTeXToMD converts a LaTeX array table to Markdown format.
//
// Continuation sub-rows (empty first cell) are merged back using <br>.
func LaTeXToMD(text string) string {
	content := strings.TrimSpace(text)
	switch {
	case strings.HasPrefix(content, "$$"):
		content = content[2:]
	case strings.HasPrefix(content, "$"):
		content = content[1:]
	}
	switch {
	case strings.HasSuffix(content, "$$"):
		content = content[:len(content)-2]
	case strings.HasSuffix(content, "$"):
		content = content[:len(content)-1]
	}
	content = strings.TrimSpace(content)

	var header []string
	var dataRows [][]string

	for _, raw := range splitLines(content) {
		line := strings.TrimSpace(raw)
		if line == "" {
			continue
		}
		if strings.HasPrefix(line, `\begin{array}`) || strings.HasPrefix(line, `\end{array}`) {
			continue
		}
		if hlineOnlyRe.MatchString(line) {
			continue
		}

		rowContent := strings.TrimSpace(trailingRowBreakRe.ReplaceAllString(line, ""))
		if rowContent == "" {
			continue
		}

		switch {
		case strings.Contains(rowContent, `\textbf{`):
			header = parseRowCells(rowContent, `\textbf`, -1)
		case strings.Contains(rowContent, `\text{`):
			ncols := -1
			if len(header) > 0 {
				ncols = len(header)
			}
			cells := parseRowCells(rowContent, `\text`, ncols)

			isContinuation := len(dataRows) > 0 && cells[0] == "" && anyNonEmpty(cells[1:])
			if isContinuation {
				dataRows[len(dataRows)-1] = mergeBR(dataRows[len(dataRows)-1], cells)
			} else {
				dataRows = append(dataRows, cells)
			}
		}
	}

	if len(header) == 0 {
		return ""
	}

	ncols := len(header)
	sep := "|" + strings.Repeat("---|", ncols)
	mdLines := []string{"| " + strings.Join(header, " | ") + " |", sep}
	for _, row := range dataRows {
		mdLines = append(mdLines, "| "+strings.Join(row, " | ")+" |")
	}
	return strings.Join(mdLines, "\n")
}

// mergeBR merges cells into prev column-wise, joining with " <br> " for
// columns where the new row has content and keeping prev's value otherwise.
func mergeBR(prev, cells []string) []string {
	n := len(prev)
	if len(cells) > n {
		n = len(cells)
	}
	merged := make([]string, n)
	for k := range n {
		prevVal := ""
		if k < len(prev) {
			prevVal = prev[k]
		}
		newVal := ""
		if k < len(cells) {
			newVal = cells[k]
		}
		if newVal != "" {
			merged[k] = prevVal + " <br> " + newVal
		} else {
			merged[k] = prevVal
		}
	}
	return merged
}

// expandBR expands cells containing <br> into multiple sub-rows.
//
// Cells without <br> appear only in the first sub-row; subsequent sub-rows
// use an empty string for those columns.
func expandBR(cells []string) [][]string {
	split := make([][]string, len(cells))
	maxRows := 0
	for i, cell := range cells {
		parts := brSplitRe.Split(cell, -1)
		split[i] = parts
		if len(parts) > maxRows {
			maxRows = len(parts)
		}
	}
	if maxRows == 1 {
		return [][]string{cells}
	}
	subRows := make([][]string, maxRows)
	for i := range maxRows {
		row := make([]string, len(split))
		for j, parts := range split {
			if i < len(parts) {
				row[j] = strings.TrimSpace(parts[i])
			}
		}
		subRows[i] = row
	}
	return subRows
}

// parseMDRow parses a Markdown table row into a list of cell values.
func parseMDRow(line string) []string {
	cells := strings.Split(line, "|")
	if len(cells) > 0 && strings.TrimSpace(cells[0]) == "" {
		cells = cells[1:]
	}
	if len(cells) > 0 && strings.TrimSpace(cells[len(cells)-1]) == "" {
		cells = cells[:len(cells)-1]
	}
	result := make([]string, len(cells))
	for i, c := range cells {
		result[i] = strings.TrimSpace(c)
	}
	return result
}

// parseRowCells parses LaTeX row cells by splitting on &, extracting
// \cmd{} values. Cells with no matching \cmd{} content become "". ncols < 0
// means no padding.
func parseRowCells(line, cmd string, ncols int) []string {
	pattern := regexp.MustCompile(regexp.QuoteMeta(cmd) + `\{([^}]*)\}`)
	segments := strings.Split(line, "&")
	cells := make([]string, len(segments), max(len(segments), ncols))
	for i, seg := range segments {
		if m := pattern.FindStringSubmatch(strings.TrimSpace(seg)); m != nil {
			cells[i] = m[1]
		}
	}
	for len(cells) < ncols {
		cells = append(cells, "")
	}
	return cells
}

func anyNonEmpty(cells []string) bool {
	for _, c := range cells {
		if c != "" {
			return true
		}
	}
	return false
}

// splitLines splits text into lines on \n or \r\n, without a final empty
// element for a trailing newline (matching Python's str.splitlines()).
func splitLines(text string) []string {
	var lines []string
	scanner := bufio.NewScanner(strings.NewReader(text))
	scanner.Buffer(make([]byte, 0, 64*1024), 1024*1024)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines
}

func nonBlankLines(text string) []string {
	var lines []string
	for _, ln := range splitLines(text) {
		if strings.TrimSpace(ln) != "" {
			lines = append(lines, ln)
		}
	}
	return lines
}

func trimmedNonBlankLines(text string) []string {
	var lines []string
	for _, ln := range splitLines(text) {
		trimmed := strings.TrimSpace(ln)
		if trimmed != "" {
			lines = append(lines, trimmed)
		}
	}
	return lines
}
