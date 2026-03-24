"""Wraps the main workflow function to catch all exceptions.

In Alfred's Script Filter, an unhandled exception produces no output,
which causes Alfred to show nothing — confusing the user.  ``safe_run``
catches any exception and outputs a visible error item instead.
"""

from __future__ import annotations

import traceback
from typing import Callable


def safe_run(fn: Callable[[], None]) -> None:
    """Call fn(), displaying an error item if any exception is raised.

    Args:
        fn: Zero-argument callable that runs the workflow logic.

    Example::

        from alfred.safe_run import safe_run
        from app.core import run

        def main() -> None:
            run(query)

        safe_run(main)
    """
    try:
        fn()
    except Exception:  # noqa: BLE001
        _emit_error(traceback.format_exc())


def _emit_error(tb: str) -> None:
    import json
    import sys

    # First line of the traceback is the most useful for display
    summary = tb.strip().splitlines()[-1] if tb.strip() else "Unknown error"

    payload = {
        "items": [
            {
                "title": "Workflow Error",
                "subtitle": summary,
                "arg": tb,
                "valid": False,
                "mods": {
                    "cmd": {
                        "subtitle": "Copy full traceback",
                        "arg": tb,
                        "valid": True,
                    }
                },
            }
        ]
    }
    sys.stdout.write(json.dumps(payload, ensure_ascii=False))
    sys.stdout.flush()
