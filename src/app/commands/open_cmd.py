"""open command - open a resource by name or URL.

Usage in Alfred:  wf open <name>
"""

from __future__ import annotations

from alfred.logger import get_logger
from alfred.response import item, output

log = get_logger(__name__)

# Example named shortcuts - replace with your own
_SHORTCUTS: dict[str, str] = {
    "repo": "https://github.com/yourname/your-workflow",
    "docs": "https://github.com/yourname/your-workflow/tree/main/docs",
    "issues": "https://github.com/yourname/your-workflow/issues",
}


def handle(args: str) -> None:
    """Show available shortcuts or open a specific one."""
    log.debug("open command: args=%r", args)

    query = args.strip().lower()
    matches = [
        item(
            title=name,
            subtitle=url,
            arg=url,
            uid=f"open-{name}",
            autocomplete=f"open {name}",
        )
        for name, url in _SHORTCUTS.items()
        if not query or query in name
    ]

    if not matches:
        output(
            [
                item(
                    title=f'No shortcut "{args}"',
                    subtitle="Available: " + ", ".join(_SHORTCUTS),
                    valid=False,
                )
            ]
        )
        return

    output(matches)
