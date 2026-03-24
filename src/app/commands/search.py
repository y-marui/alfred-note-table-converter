"""search command - primary workflow action.

Usage in Alfred:  wf <query>
                  wf search <query>
"""

from __future__ import annotations

from typing import Any

from alfred.logger import get_logger
from alfred.response import item, output
from app.services.example_service import ExampleService

log = get_logger(__name__)
_service = ExampleService()


def handle(args: str) -> None:
    """Search and return results for the given query string."""
    log.debug("search command: args=%r", args)

    if not args.strip():
        output(
            [
                item(
                    title="Type to search",
                    subtitle="Enter a query to get started",
                    valid=False,
                )
            ]
        )
        return

    results = _service.search(args)
    if not results:
        output(
            [
                item(
                    title=f'No results for "{args}"',
                    subtitle="Try a different query",
                    valid=False,
                )
            ]
        )
        return

    output([_result_item(r) for r in results])


def _result_item(result: dict[str, Any]) -> dict[str, Any]:
    return item(
        title=result.get("title", ""),
        subtitle=result.get("subtitle", ""),
        arg=result.get("url", result.get("title", "")),
        uid=result.get("id", ""),
    )
