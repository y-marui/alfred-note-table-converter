"""Table converter service: Markdown <-> LaTeX table conversion."""

from __future__ import annotations

import re

_BR_SPLIT = re.compile(r"\s*<br\s*/?>\s*", re.IGNORECASE)


def detect_format(text: str) -> str:
    """Detect whether text is a Markdown or LaTeX table.

    Returns "markdown", "latex", or "unknown".
    """
    stripped = text.strip()
    if stripped.startswith("$") and r"\begin{array}" in stripped:
        return "latex"
    lines = [ln for ln in stripped.splitlines() if ln.strip()]
    if len(lines) >= 2 and "|" in lines[0] and re.match(r"^[\s|:-]+$", lines[1]):
        return "markdown"
    return "unknown"


def md_to_latex(text: str, *, quadruple_backslash: bool = False) -> str:
    """Convert a Markdown table to LaTeX array format.

    LaTeX format:
    - Double hline at top, between header and data, and at bottom.
    - Header cells wrapped in \\textbf{}, data cells in \\text{}.
    - Cells containing <br> are split into continuation sub-rows.

    Args:
        text: Markdown table string.
        quadruple_backslash: Use \\\\\\\\ instead of \\\\ for row breaks.
    """
    lines = [ln.strip() for ln in text.strip().splitlines() if ln.strip()]

    header = _parse_md_row(lines[0])
    # lines[1] is the separator row — skip it
    data_rows = [_parse_md_row(ln) for ln in lines[2:] if ln.strip()]

    ncols = len(header)
    col_spec = "|" + "|".join(["l"] * ncols) + "|"
    row_br = r" \\\\" if quadruple_backslash else r" \\"

    out: list[str] = [
        "$$",
        rf"\begin{{array}}{{{col_spec}}} \hline \hline",
    ]

    header_cells = " & ".join(rf"\textbf{{{cell}}}" for cell in header)
    out.append(header_cells + row_br + r" \hline \hline")

    for i, row in enumerate(data_rows):
        is_last = i == len(data_rows) - 1
        sub_rows = _expand_br(row)

        for j, sub_row in enumerate(sub_rows):
            is_last_sub = j == len(sub_rows) - 1
            cells_latex = " & ".join(rf"\text{{{c}}}" if c else "" for c in sub_row)

            if is_last_sub:
                hline = r"\hline \hline" if is_last else r"\hline"
                out.append(cells_latex + row_br + " " + hline)
            else:
                out.append(cells_latex + row_br)

    out.append(r"\end{array}")
    out.append("$$")

    return "\n".join(out)


def latex_to_md(text: str) -> str:
    """Convert a LaTeX array table to Markdown format.

    Continuation sub-rows (empty first cell) are merged back using <br>.
    """
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

        # Strip trailing \\ (or \\\\) and \hline markers
        row_content = re.sub(r"\s*\\\\+.*$", "", line).strip()
        if not row_content:
            continue

        if r"\textbf{" in row_content:
            header = _parse_row_cells(row_content, r"\textbf")
        elif r"\text{" in row_content:
            ncols = len(header) if header else None
            cells = _parse_row_cells(row_content, r"\text", ncols)

            # Continuation row: first cell is empty but later cells have content
            is_continuation = bool(data_rows) and not cells[0] and any(cells[1:])
            if is_continuation:
                prev = data_rows[-1]
                merged: list[str] = []
                for k in range(max(len(prev), len(cells))):
                    prev_val = prev[k] if k < len(prev) else ""
                    new_val = cells[k] if k < len(cells) else ""
                    merged.append(prev_val + " <br> " + new_val if new_val else prev_val)
                data_rows[-1] = merged
            else:
                data_rows.append(cells)

    if not header:
        return ""

    ncols = len(header)
    sep = "|" + "|".join(["---"] * ncols) + "|"
    md_lines = ["| " + " | ".join(header) + " |", sep]
    for row in data_rows:
        md_lines.append("| " + " | ".join(row) + " |")

    return "\n".join(md_lines)


def _expand_br(cells: list[str]) -> list[list[str]]:
    """Expand cells containing <br> into multiple sub-rows.

    Cells without <br> appear only in the first sub-row; subsequent sub-rows
    use an empty string for those columns.
    """
    split = [_BR_SPLIT.split(cell) for cell in cells]
    max_rows = max(len(parts) for parts in split)
    if max_rows == 1:
        return [cells]
    return [
        [parts[i].strip() if i < len(parts) else "" for parts in split] for i in range(max_rows)
    ]


def _parse_md_row(line: str) -> list[str]:
    """Parse a Markdown table row into a list of cell values."""
    cells = line.split("|")
    if cells and not cells[0].strip():
        cells = cells[1:]
    if cells and not cells[-1].strip():
        cells = cells[:-1]
    return [c.strip() for c in cells]


def _parse_row_cells(line: str, cmd: str, ncols: int | None = None) -> list[str]:
    """Parse LaTeX row cells by splitting on &, extracting \\cmd{} values.

    Returns empty string for cells that have no matching \\cmd{} content.
    """
    pattern = re.escape(cmd) + r"\{([^}]*)\}"
    segments = [s.strip() for s in line.split("&")]
    cells: list[str] = []
    for seg in segments:
        m = re.search(pattern, seg)
        cells.append(m.group(1) if m else "")
    if ncols is not None and len(cells) < ncols:
        cells.extend([""] * (ncols - len(cells)))
    return cells
