"""Table converter service: Markdown <-> LaTeX table conversion."""

from __future__ import annotations

import re


def detect_format(text: str) -> str:
    """Detect whether text is a Markdown or LaTeX table.

    Returns "markdown", "latex", or "unknown".
    """
    stripped = text.strip()
    if stripped.startswith("$$") and r"\begin{array}" in stripped:
        return "latex"
    lines = [ln for ln in stripped.splitlines() if ln.strip()]
    if len(lines) >= 2 and "|" in lines[0] and re.match(r"^[\s|:-]+$", lines[1]):
        return "markdown"
    return "unknown"


def md_to_latex(text: str) -> str:
    """Convert a Markdown table to LaTeX array format.

    LaTeX format:
    - Double hline at top, between header and data, and at bottom.
    - Header cells wrapped in \\textbf{}, data cells in \\text{}.
    """
    lines = [ln.strip() for ln in text.strip().splitlines() if ln.strip()]

    header = _parse_md_row(lines[0])
    # lines[1] is the separator row — skip it
    data_rows = [_parse_md_row(ln) for ln in lines[2:] if ln.strip()]

    ncols = len(header)
    col_spec = "|" + "|".join(["l"] * ncols) + "|"

    out: list[str] = [
        "$$",
        rf"\begin{{array}}{{{col_spec}}} \hline \hline",
    ]

    header_cells = " & ".join(rf"\textbf{{{cell}}}" for cell in header)
    out.append(header_cells + r" \\ \hline \hline")

    for i, row in enumerate(data_rows):
        cells = " & ".join(rf"\text{{{cell}}}" for cell in row)
        hline = r"\hline \hline" if i == len(data_rows) - 1 else r"\hline"
        out.append(cells + r" \\ " + hline)

    out.append(r"\end{array}")
    out.append("$$")

    return "\n".join(out)


def latex_to_md(text: str) -> str:
    """Convert a LaTeX array table to Markdown format."""
    content = text.strip()
    if content.startswith("$$"):
        content = content[2:]
    elif content.startswith("$"):
        content = content[1:]
    if content.endswith("$$"):
        content = content[:-2]
    elif content.endswith("$"):
        content = content[:-1]
    content = content.strip()

    header: list[str] = []
    data_rows: list[list[str]] = []

    for line in content.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith(r"\begin{array}") or line.startswith(r"\end{array}"):
            continue
        if re.match(r"^(\\hline[\s　]*)+$", line):
            continue

        # Strip trailing \\ \hline... suffix to get cell content
        row_content = re.sub(r"\s*\\\\.*$", "", line).strip()
        if not row_content:
            continue

        if r"\textbf{" in row_content:
            header = _parse_latex_cells(row_content, r"\textbf")
        elif r"\text{" in row_content:
            data_rows.append(_parse_latex_cells(row_content, r"\text"))

    if not header:
        return ""

    ncols = len(header)
    sep = "|" + "|".join(["---"] * ncols) + "|"
    md_lines = ["| " + " | ".join(header) + " |", sep]
    for row in data_rows:
        md_lines.append("| " + " | ".join(row) + " |")

    return "\n".join(md_lines)


def _parse_md_row(line: str) -> list[str]:
    """Parse a Markdown table row into a list of cell values."""
    cells = line.split("|")
    if cells and not cells[0].strip():
        cells = cells[1:]
    if cells and not cells[-1].strip():
        cells = cells[:-1]
    return [c.strip() for c in cells]


def _parse_latex_cells(line: str, cmd: str) -> list[str]:
    """Extract cell values from a LaTeX row using \\cmd{} notation."""
    pattern = re.escape(cmd) + r"\{([^}]*)\}"
    return re.findall(pattern, line)
