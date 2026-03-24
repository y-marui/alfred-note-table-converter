"""help command - display available commands.

Usage in Alfred:  wf help
"""

from __future__ import annotations

from alfred.response import item, output

_COMMANDS = [
    ("search <query>", "Search for items  (default command)", "wf search "),
    ("open <name>", "Open a named shortcut", "wf open "),
    ("config", "View or reset configuration", "wf config"),
    ("help", "Show this help", "wf help"),
]


def handle(args: str) -> None:  # noqa: ARG001
    """Display all available commands."""
    output(
        [
            item(
                title=f"wf {cmd}",
                subtitle=desc,
                arg="",
                uid=f"help-{cmd.split()[0]}",
                valid=False,
                autocomplete=autocomplete,
            )
            for cmd, desc, autocomplete in _COMMANDS
        ]
    )
