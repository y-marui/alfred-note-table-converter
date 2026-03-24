"""convert command - convert table between Markdown and LaTeX formats.

Usage in Alfred:  tbl
                  tbl convert

Reads the clipboard, detects the table format, and offers to convert it.
The converted text is returned as the action arg so Alfred can copy it.
"""

from __future__ import annotations

import subprocess

from alfred.logger import get_logger
from alfred.response import error_item, item, output
from app.services.table_converter import detect_format, latex_to_md, md_to_latex

log = get_logger(__name__)


def _clipboard() -> str:
    """Return current clipboard contents."""
    result = subprocess.run(["pbpaste"], capture_output=True, text=True)
    return result.stdout


def handle(args: str) -> None:  # noqa: ARG001
    """Detect clipboard table format and offer conversion."""
    log.debug("convert command")

    text = _clipboard()
    fmt = detect_format(text)

    if fmt == "markdown":
        converted = md_to_latex(text)
        output(
            [
                item(
                    title="Markdown -> LaTeX",
                    subtitle="Convert and copy LaTeX to clipboard",
                    arg=converted,
                    uid="convert-md-to-latex",
                )
            ]
        )

    elif fmt == "latex":
        converted = latex_to_md(text)
        output(
            [
                item(
                    title="LaTeX -> Markdown",
                    subtitle="Convert and copy Markdown to clipboard",
                    arg=converted,
                    uid="convert-latex-to-md",
                )
            ]
        )

    else:
        output(
            [
                error_item(
                    "No table found in clipboard",
                    "Copy a Markdown or LaTeX table first",
                )
            ]
        )
