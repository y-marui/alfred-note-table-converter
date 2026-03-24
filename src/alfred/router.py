"""Command router for Alfred Script Filter workflows.

Parses the raw Alfred query string into a command name and arguments,
then dispatches to the appropriate handler.

Query format::

    <command> [arguments...]
    wf search foo bar   → command="search", args="foo bar"
    wf config           → command="config",  args=""
    wf help             → command="help",    args=""
    wf                  → command="" (show default)
"""

from __future__ import annotations

from typing import Callable

Handler = Callable[[str], None]


class Router:
    """Maps command names to handler callables.

    Example::

        router = Router(default="search")

        @router.register("search")
        def handle_search(args: str) -> None:
            ...

        router.dispatch("search foo bar")
    """

    def __init__(self, default: str = "search") -> None:
        self._handlers: dict[str, Handler] = {}
        self._default = default

    def register(self, command: str) -> Callable[[Handler], Handler]:
        """Decorator to register a handler for a command name."""

        def decorator(fn: Handler) -> Handler:
            self._handlers[command] = fn
            return fn

        return decorator

    def dispatch(self, query: str) -> None:
        """Parse query and call the matching handler.

        Args:
            query: Raw query string from Alfred.
        """
        parts = query.strip().split(None, 1)
        if not parts:
            command, args = self._default, ""
        else:
            command = parts[0].lower()
            args = parts[1] if len(parts) > 1 else ""

        handler = self._handlers.get(command)
        if handler is None:
            # Fall back to default command, passing the full query as args
            handler = self._handlers.get(self._default)
            if handler is None:
                raise ValueError(f"No handler registered for command '{command}'")
            args = query.strip()

        handler(args)
