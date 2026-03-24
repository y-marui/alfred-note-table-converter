"""Command handlers - one module per command.

Each module must expose a ``handle(args: str) -> None`` function that
calls ``alfred.response.output()`` with the result items.
"""

from __future__ import annotations
