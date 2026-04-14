"""config command - view and manage workflow configuration.

Usage in Alfred:  tbl config
                  tbl config reset
"""

from __future__ import annotations

from alfred.config import Config
from alfred.logger import get_logger
from alfred.response import item, output
from app.settings import SCHEMA

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

    items = [
        item(
            title="Reset all settings",
            subtitle="tbl config reset  — clear all stored configuration",
            arg="reset",
            uid="config-reset",
            autocomplete="config reset",
        )
    ]

    for spec in SCHEMA.specs():
        stored = _config.get(spec.key)
        current = stored if stored is not None else spec.default
        is_default = stored is None
        subtitle = spec.description + ("  [default]" if is_default else "")
        items.insert(
            0,
            item(
                title=f"{spec.key}: {current}",
                subtitle=subtitle,
                arg=str(current),
                uid=f"config-{spec.key}",
                valid=False,
            ),
        )

    output(items)
