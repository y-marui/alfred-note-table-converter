package tableconv

import (
	"regexp"
	"strings"
	"testing"
)

var separatorRowFmt = regexp.MustCompile(`^\|[-| ]+\|$`)

const mdTable = `| Col1 | Col2 | Col3 |
|------|------|------|
| a    | b    | c    |
| d    | e    | f    |`

const latexTable = `$$
\begin{array}{|l|l|l|} \hline \hline
\textbf{Col1} & \textbf{Col2} & \textbf{Col3} \\ \hline \hline
\text{a} & \text{b} & \text{c} \\ \hline
\text{d} & \text{e} & \text{f} \\ \hline \hline
\end{array}
$$`

const mdMultibyte = `|  | 2等 | 1等 |
|---|---|---|
| 3日 | 244 | 389 |
| 15日 | 459 | 723 |`

const mdBRTable = `| Day | Detail |
|-----|--------|
| Day1 | Aa <br> Ab <br> Ac |
| Day2 | Ba |`

const latexBRTable = `$$
\begin{array}{|l|l|} \hline \hline
\textbf{Day} & \textbf{Detail} \\ \hline \hline
\text{Day1} & \text{Aa} \\ \hline
 & \text{Ab} \\ \hline
 & \text{Ac} \\ \hline
\text{Day2} & \text{Ba} \\ \hline \hline
\end{array}
$$`

func TestDetectFormat_Markdown(t *testing.T) {
	if got := DetectFormat(mdTable); got != "markdown" {
		t.Errorf("DetectFormat() = %q, want markdown", got)
	}
}

func TestDetectFormat_Latex(t *testing.T) {
	if got := DetectFormat(latexTable); got != "latex" {
		t.Errorf("DetectFormat() = %q, want latex", got)
	}
}

func TestDetectFormat_LatexSingleDollar(t *testing.T) {
	latex := strings.ReplaceAll(latexTable, "$$", "$")
	if got := DetectFormat(latex); got != "latex" {
		t.Errorf("DetectFormat() = %q, want latex", got)
	}
}

func TestDetectFormat_UnknownPlainText(t *testing.T) {
	if got := DetectFormat("just some plain text"); got != "unknown" {
		t.Errorf("DetectFormat() = %q, want unknown", got)
	}
}

func TestDetectFormat_EmptyString(t *testing.T) {
	if got := DetectFormat(""); got != "unknown" {
		t.Errorf("DetectFormat() = %q, want unknown", got)
	}
}

func TestMDToLatex_BasicConversion(t *testing.T) {
	result := MDToLatex(mdTable, false)
	if !strings.HasPrefix(result, "$$") {
		t.Errorf("result does not start with $$: %q", result)
	}
	if !strings.HasSuffix(result, "$$") {
		t.Errorf("result does not end with $$: %q", result)
	}
	for _, want := range []string{`\begin{array}{|l|l|l|}`, `\textbf{Col1}`, `\textbf{Col2}`, `\text{a}`} {
		if !strings.Contains(result, want) {
			t.Errorf("result missing %q: %q", want, result)
		}
	}
}

func TestMDToLatex_DoubleHlineAfterHeader(t *testing.T) {
	result := MDToLatex(mdTable, false)
	if !strings.Contains(result, `\textbf{Col3} \\ \hline \hline`) {
		t.Errorf("result missing double hline after header: %q", result)
	}
}

func TestMDToLatex_DoubleHlineAtTop(t *testing.T) {
	lines := strings.Split(MDToLatex(mdTable, false), "\n")
	if !strings.Contains(lines[1], `\hline \hline`) {
		t.Errorf("line[1] = %q, want double hline", lines[1])
	}
}

func TestMDToLatex_DoubleHlineAtBottom(t *testing.T) {
	lines := strings.Split(MDToLatex(mdTable, false), "\n")
	if got := lines[len(lines)-3]; !strings.Contains(got, `\hline \hline`) {
		t.Errorf("lines[-3] = %q, want double hline", got)
	}
}

func TestMDToLatex_MultibyteCells(t *testing.T) {
	result := MDToLatex(mdMultibyte, false)
	for _, want := range []string{`\textbf{2等}`, `\text{3日}`, `\text{459}`} {
		if !strings.Contains(result, want) {
			t.Errorf("result missing %q: %q", want, result)
		}
	}
}

func TestMDToLatex_ColumnCountMatches(t *testing.T) {
	if result := MDToLatex(mdTable, false); !strings.Contains(result, "|l|l|l|") {
		t.Errorf("result missing column spec |l|l|l|: %q", result)
	}
}

func TestMDToLatex_QuadrupleBackslash(t *testing.T) {
	result := MDToLatex(mdTable, true)
	if !strings.Contains(result, `\textbf{Col3} \\\\ \hline \hline`) {
		t.Errorf("result missing quadruple-backslash header row break: %q", result)
	}
	if !strings.Contains(result, `\text{a} & \text{b} & \text{c} \\\\ \hline`) {
		t.Errorf("result missing quadruple-backslash data row break: %q", result)
	}
}

func TestMDToLatex_QuadrupleBackslashLastRow(t *testing.T) {
	result := MDToLatex(mdTable, true)
	if !strings.Contains(result, `\text{d} & \text{e} & \text{f} \\\\ \hline \hline`) {
		t.Errorf("result missing quadruple-backslash last row break: %q", result)
	}
}

func TestMDToLatex_BRExpansionCreatesSubRows(t *testing.T) {
	result := MDToLatex(mdBRTable, false)
	for _, want := range []string{`\text{Day1} & \text{Aa}`, ` & \text{Ab}`, ` & \text{Ac}`} {
		if !strings.Contains(result, want) {
			t.Errorf("result missing %q: %q", want, result)
		}
	}
}

func TestMDToLatex_BRFirstCellEmptyInContinuation(t *testing.T) {
	result := MDToLatex(mdBRTable, false)
	for _, want := range []string{` & \text{Ab}`, ` & \text{Ac}`} {
		if !strings.Contains(result, want) {
			t.Errorf("result missing %q: %q", want, result)
		}
	}
}

func TestMDToLatex_BRHlineOnlyAfterLastSubRow(t *testing.T) {
	lines := strings.Split(MDToLatex(mdBRTable, false), "\n")

	var abLine, acLine string
	for _, ln := range lines {
		if strings.Contains(ln, `\text{Ab}`) {
			abLine = ln
		}
		if strings.Contains(ln, `\text{Ac}`) {
			acLine = ln
		}
	}
	if strings.Contains(abLine, `\hline`) {
		t.Errorf("Ab sub-row must not end with \\hline: %q", abLine)
	}
	if !strings.Contains(acLine, `\hline`) {
		t.Errorf("Ac sub-row (last of Day1 group) must end with \\hline: %q", acLine)
	}
}

func TestLaTeXToMD_BasicConversion(t *testing.T) {
	result := LaTeXToMD(latexTable)
	if !strings.Contains(result, "| Col1 |") {
		t.Errorf("result missing header cell Col1: %q", result)
	}
	if !strings.Contains(result, "| Col2 |") {
		t.Errorf("result missing header cell Col2: %q", result)
	}
	if !strings.Contains(result, "| a |") && !strings.Contains(result, "| a    |") {
		t.Errorf("result missing data cell a: %q", result)
	}
}

func TestLaTeXToMD_SeparatorRowPresent(t *testing.T) {
	lines := strings.Split(LaTeXToMD(latexTable), "\n")
	found := false
	for _, ln := range lines {
		if separatorRowFmt.MatchString(ln) {
			found = true
			break
		}
	}
	if !found {
		t.Errorf("no separator row found in %v", lines)
	}
}

func TestLaTeXToMD_HeaderRowIsFirst(t *testing.T) {
	lines := strings.Split(LaTeXToMD(latexTable), "\n")
	if !strings.Contains(lines[0], "Col1") {
		t.Errorf("first line = %q, want to contain Col1", lines[0])
	}
}

func TestLaTeXToMD_DataRowsCount(t *testing.T) {
	lines := strings.Split(LaTeXToMD(latexTable), "\n")
	if len(lines) != 4 {
		t.Errorf("len(lines) = %d, want 4 (header+separator+2 data rows): %v", len(lines), lines)
	}
}

func TestLaTeXToMD_MultibyteRoundtrip(t *testing.T) {
	latex := MDToLatex(mdMultibyte, false)
	result := LaTeXToMD(latex)
	for _, want := range []string{"2等", "3日", "723"} {
		if !strings.Contains(result, want) {
			t.Errorf("result missing %q: %q", want, result)
		}
	}
}

func TestLaTeXToMD_ContinuationRowsMergedWithBR(t *testing.T) {
	result := LaTeXToMD(latexBRTable)
	if !strings.Contains(result, "<br>") {
		t.Errorf("result missing <br>: %q", result)
	}
	if !strings.Contains(result, "Day1") {
		t.Errorf("result missing Day1: %q", result)
	}
	var day2Line string
	for _, ln := range strings.Split(result, "\n") {
		if strings.Contains(ln, "Day2") {
			day2Line = ln
		}
	}
	if strings.Contains(day2Line, "<br>") {
		t.Errorf("Day2 row must not contain <br>: %q", day2Line)
	}
}

func TestLaTeXToMD_ContinuationBRContentPreserved(t *testing.T) {
	result := LaTeXToMD(latexBRTable)
	var day1Line string
	for _, ln := range strings.Split(result, "\n") {
		if strings.Contains(ln, "Day1") {
			day1Line = ln
		}
	}
	for _, want := range []string{"Aa", "Ab", "Ac"} {
		if !strings.Contains(day1Line, want) {
			t.Errorf("Day1 row missing %q: %q", want, day1Line)
		}
	}
}

func TestRoundtrip_MDToLaTeXToMD(t *testing.T) {
	recovered := LaTeXToMD(MDToLatex(mdTable, false))
	for _, want := range []string{"Col1", "Col2", "a", "f"} {
		if !strings.Contains(recovered, want) {
			t.Errorf("recovered missing %q: %q", want, recovered)
		}
	}
}

func TestRoundtrip_LaTeXToMDToLaTeX(t *testing.T) {
	recovered := MDToLatex(LaTeXToMD(latexTable), false)
	if !strings.Contains(recovered, `\textbf{Col1}`) {
		t.Errorf("recovered missing \\textbf{Col1}: %q", recovered)
	}
	if !strings.Contains(recovered, `\text{a}`) {
		t.Errorf("recovered missing \\text{a}: %q", recovered)
	}
}

func TestRoundtrip_BRRoundtrip(t *testing.T) {
	recovered := LaTeXToMD(MDToLatex(mdBRTable, false))
	for _, want := range []string{"Day1", "Aa", "Ab", "Ac", "<br>"} {
		if !strings.Contains(recovered, want) {
			t.Errorf("recovered missing %q: %q", want, recovered)
		}
	}
}
