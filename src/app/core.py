"""Application orchestrator.

Wires together the Router and Command handlers.
This is the single entry point called by scripts/entry.py.

To add a new command:
  1. Create src/app/commands/my_command.py with a handle(args: str) -> None
  2. Register it below with router.register("my_command")
"""

from __future__ import annotations

from alfred.router import Router
from app.commands import config_cmd, help_cmd, open_cmd, search

router = Router(default="search")
router.register("search")(search.handle)
router.register("open")(open_cmd.handle)
router.register("config")(config_cmd.handle)
router.register("help")(help_cmd.handle)


def run(query: str) -> None:
    """Main application entry point.

    Args:
        query: Raw query string from Alfred (e.g. "search foo bar").
    """
    router.dispatch(query)
