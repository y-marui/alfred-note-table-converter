"""Tests for the table converter service."""

from __future__ import annotations

import re

from app.services.table_converter import detect_format, latex_to_md, md_to_latex

_MD_TABLE = """\
| Col1 | Col2 | Col3 |
|------|------|------|
| a    | b    | c    |
| d    | e    | f    |"""

_LATEX_TABLE = r"""$$
\begin{array}{|l|l|l|} \hline \hline
\textbf{Col1} & \textbf{Col2} & \textbf{Col3} \\ \hline \hline
\text{a} & \text{b} & \text{c} \\ \hline
\text{d} & \text{e} & \text{f} \\ \hline \hline
\end{array}
$$"""

_MD_MULTIBYTE = """\
|  | 2等 | 1等 |
|---|---|---|
| 3日 | 244 | 389 |
| 15日 | 459 | 723 |"""

_MD_BR_TABLE = """\
| Day | Detail |
|-----|--------|
| Day1 | Aa <br> Ab <br> Ac |
| Day2 | Ba |"""

_LATEX_BR_TABLE = r"""$$
\begin{array}{|l|l|} \hline \hline
\textbf{Day} & \textbf{Detail} \\ \hline \hline
\text{Day1} & \text{Aa} \\ \hline
 & \text{Ab} \\ \hline
 & \text{Ac} \\ \hline
\text{Day2} & \text{Ba} \\ \hline \hline
\end{array}
$$"""


class TestDetectFormat:
    def test_detects_markdown(self):
        assert detect_format(_MD_TABLE) == "markdown"

    def test_detects_latex(self):
        assert detect_format(_LATEX_TABLE) == "latex"

    def test_detects_latex_with_single_dollar(self):
        latex = _LATEX_TABLE.replace("$$", "$")
        assert detect_format(latex) == "latex"

    def test_unknown_returns_unknown(self):
        assert detect_format("just some plain text") == "unknown"

    def test_empty_string_returns_unknown(self):
        assert detect_format("") == "unknown"


class TestMdToLatex:
    def test_basic_conversion(self):
        result = md_to_latex(_MD_TABLE)
        assert result.startswith("$$")
        assert result.endswith("$$")
        assert r"\begin{array}{|l|l|l|}" in result
        assert r"\textbf{Col1}" in result
        assert r"\textbf{Col2}" in result
        assert r"\text{a}" in result

    def test_double_hline_after_header(self):
        result = md_to_latex(_MD_TABLE)
        assert r"\textbf{Col3} \\ \hline \hline" in result

    def test_double_hline_at_top(self):
        result = md_to_latex(_MD_TABLE)
        assert r"\hline \hline" in result.splitlines()[1]

    def test_double_hline_at_bottom(self):
        result = md_to_latex(_MD_TABLE)
        lines = result.splitlines()
        assert r"\hline \hline" in lines[-3]

    def test_multibyte_cells(self):
        result = md_to_latex(_MD_MULTIBYTE)
        assert r"\textbf{2等}" in result
        assert r"\text{3日}" in result
        assert r"\text{459}" in result

    def test_column_count_matches(self):
        result = md_to_latex(_MD_TABLE)
        assert "|l|l|l|" in result

    def test_quadruple_backslash(self):
        result = md_to_latex(_MD_TABLE, quadruple_backslash=True)
        assert r"\textbf{Col3} \\\\ \hline \hline" in result
        assert r"\text{a} & \text{b} & \text{c} \\\\ \hline" in result

    def test_quadruple_backslash_last_row(self):
        result = md_to_latex(_MD_TABLE, quadruple_backslash=True)
        assert r"\text{d} & \text{e} & \text{f} \\\\ \hline \hline" in result

    def test_br_expansion_creates_sub_rows(self):
        result = md_to_latex(_MD_BR_TABLE)
        # Day1 row should expand to 3 sub-rows
        assert r"\text{Day1} & \text{Aa}" in result
        assert r" & \text{Ab}" in result
        assert r" & \text{Ac}" in result

    def test_br_first_cell_empty_in_continuation(self):
        result = md_to_latex(_MD_BR_TABLE)
        # Continuation rows must have empty first cell
        assert " & \\text{Ab}" in result
        assert " & \\text{Ac}" in result

    def test_br_hline_only_after_last_sub_row(self):
        result = md_to_latex(_MD_BR_TABLE)
        lines = result.splitlines()
        # The Ab and Aa sub-rows should NOT end with \hline
        ab_line = next(ln for ln in lines if "\\text{Ab}" in ln)
        assert r"\hline" not in ab_line
        # Ac sub-row (last of Day1 group) should end with \hline
        ac_line = next(ln for ln in lines if "\\text{Ac}" in ln)
        assert r"\hline" in ac_line


class TestLatexToMd:
    def test_basic_conversion(self):
        result = latex_to_md(_LATEX_TABLE)
        assert "| Col1 |" in result
        assert "| Col2 |" in result
        assert "| a |" in result or "| a    |" in result

    def test_separator_row_present(self):
        result = latex_to_md(_LATEX_TABLE)
        lines = result.splitlines()
        assert any(re.match(r"^\|[-| ]+\|$", ln) for ln in lines)

    def test_header_row_is_first(self):
        result = latex_to_md(_LATEX_TABLE)
        first_line = result.splitlines()[0]
        assert "Col1" in first_line

    def test_data_rows_count(self):
        result = latex_to_md(_LATEX_TABLE)
        lines = result.splitlines()
        # header + separator + 2 data rows
        assert len(lines) == 4

    def test_multibyte_roundtrip(self):
        latex = md_to_latex(_MD_MULTIBYTE)
        result = latex_to_md(latex)
        assert "2等" in result
        assert "3日" in result
        assert "723" in result

    def test_continuation_rows_merged_with_br(self):
        result = latex_to_md(_LATEX_BR_TABLE)
        assert "<br>" in result
        assert "Day1" in result
        # Day2 should not have <br>
        lines = result.splitlines()
        day2_line = next(ln for ln in lines if "Day2" in ln)
        assert "<br>" not in day2_line

    def test_continuation_br_content_preserved(self):
        result = latex_to_md(_LATEX_BR_TABLE)
        day1_line = next(ln for ln in result.splitlines() if "Day1" in ln)
        assert "Aa" in day1_line
        assert "Ab" in day1_line
        assert "Ac" in day1_line


class TestRoundtrip:
    def test_md_to_latex_to_md(self):
        latex = md_to_latex(_MD_TABLE)
        recovered = latex_to_md(latex)
        assert "Col1" in recovered
        assert "Col2" in recovered
        assert "a" in recovered
        assert "f" in recovered

    def test_latex_to_md_to_latex(self):
        md = latex_to_md(_LATEX_TABLE)
        recovered = md_to_latex(md)
        assert r"\textbf{Col1}" in recovered
        assert r"\text{a}" in recovered

    def test_br_roundtrip(self):
        latex = md_to_latex(_MD_BR_TABLE)
        recovered = latex_to_md(latex)
        assert "Day1" in recovered
        assert "Aa" in recovered
        assert "Ab" in recovered
        assert "Ac" in recovered
        assert "<br>" in recovered
