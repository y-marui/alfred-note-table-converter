"""help command - display available commands.

Usage in Alfred:  wf help
"""

from __future__ import annotations

from alfred.response import item, output

_COMMANDS = [
    ("convert", "Convert clipboard table: Markdown <-> LaTeX (default)", "tbl convert"),
    ("open <name>", "Open a named shortcut", "tbl open "),
    ("config", "View or reset configuration", "tbl config"),
    ("help", "Show this help", "tbl help"),
]


def handle(args: str) -> None:  # noqa: ARG001
    """Display all available commands."""
    output(
        [
            item(
                title=f"tbl {cmd}",
                subtitle=desc,
                arg="",
                uid=f"help-{cmd.split()[0]}",
                valid=False,
                autocomplete=autocomplete,
            )
            for cmd, desc, autocomplete in _COMMANDS
        ]
    )
