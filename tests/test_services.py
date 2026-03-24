"""Tests for the table converter service."""

from __future__ import annotations

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


class TestDetectFormat:
    def test_detects_markdown(self):
        assert detect_format(_MD_TABLE) == "markdown"

    def test_detects_latex(self):
        assert detect_format(_LATEX_TABLE) == "latex"

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
        # Last data row ends with \hline \hline
        assert r"\hline \hline" in lines[-3]

    def test_multibyte_cells(self):
        result = md_to_latex(_MD_MULTIBYTE)
        assert r"\textbf{2等}" in result
        assert r"\text{3日}" in result
        assert r"\text{459}" in result

    def test_column_count_matches(self):
        result = md_to_latex(_MD_TABLE)
        assert "|l|l|l|" in result


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


class TestRoundtrip:
    def test_md_to_latex_to_md(self):
        latex = md_to_latex(_MD_TABLE)
        recovered = latex_to_md(latex)
        # Headers and data should survive the roundtrip
        assert "Col1" in recovered
        assert "Col2" in recovered
        assert "a" in recovered
        assert "f" in recovered

    def test_latex_to_md_to_latex(self):
        md = latex_to_md(_LATEX_TABLE)
        recovered = md_to_latex(md)
        assert r"\textbf{Col1}" in recovered
        assert r"\text{a}" in recovered


import re  # noqa: E402 (needed for test helper above)
