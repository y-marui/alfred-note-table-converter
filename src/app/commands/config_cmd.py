"""config command - view and manage workflow configuration.

Usage in Alfred:  wf config
                  wf config reset
"""

from __future__ import annotations

from alfred.config import Config
from alfred.logger import get_logger
from alfred.response import item, output

log = get_logger(__name__)
_config = Config()


def handle(args: str) -> None:
    """Show config items or perform a config action."""
    log.debug("config command: args=%r", args)

    sub = args.strip().lower()

    if sub == "reset":
        _config.reset()
        output(
            [
                item(
                    title="Configuration reset",
                    subtitle="All settings have been cleared",
                    valid=False,
                )
            ]
        )
        return

    current = _config.all()
    items = [
        item(
            title="Reset all settings",
            subtitle="wf config reset  — clear all stored configuration",
            arg="reset",
            uid="config-reset",
            autocomplete="config reset",
        )
    ]

    if current:
        for key, value in current.items():
            items.insert(
                0,
                item(
                    title=f"{key}: {value}",
                    subtitle="Current setting",
                    arg=str(value),
                    uid=f"config-{key}",
                    valid=False,
                ),
            )
    else:
        items.insert(
            0,
            item(
                title="No settings configured",
                subtitle="Settings will appear here once set",
                valid=False,
            ),
        )

    output(items)
