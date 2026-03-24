"""Alfred Script Filter JSON response helpers.

Reference: https://www.alfredapp.com/help/workflows/inputs/script-filter/json/
"""

from __future__ import annotations

import json
import sys
from typing import Any


def item(
    title: str,
    subtitle: str = "",
    arg: str = "",
    *,
    uid: str = "",
    icon: str | None = None,
    valid: bool = True,
    autocomplete: str = "",
    type: str = "default",
    mods: dict[str, Any] | None = None,
    variables: dict[str, str] | None = None,
    quicklookurl: str = "",
) -> dict[str, Any]:
    """Build a single Alfred result item dict.

    Args:
        title: Primary text shown in Alfred.
        subtitle: Secondary text shown below the title.
        arg: Value passed to the next workflow action.
        uid: Stable identifier for Alfred's learned ordering.
        icon: Path to an icon file, or None to use the workflow icon.
        valid: Whether pressing Enter on this item triggers an action.
        autocomplete: Text auto-filled in the search box on Tab.
        type: "default", "file", or "file:skipcheck".
        mods: Modifier key overrides (cmd, alt, ctrl, shift, fn).
        variables: Workflow variables set when this item is actioned.
        quicklookurl: URL or file path shown in Quick Look (⇧ or ⌘Y).
    """
    result: dict[str, Any] = {
        "title": title,
        "subtitle": subtitle,
        "arg": arg,
        "valid": valid,
    }

    if uid:
        result["uid"] = uid
    if autocomplete:
        result["autocomplete"] = autocomplete
    if type != "default":
        result["type"] = type
    if icon is not None:
        result["icon"] = {"path": icon}
    if mods:
        result["mods"] = mods
    if variables:
        result["variables"] = variables
    if quicklookurl:
        result["quicklookurl"] = quicklookurl

    return result


def output(
    items: list[dict[str, Any]],
    *,
    variables: dict[str, str] | None = None,
    rerun: float | None = None,
    cache: dict[str, Any] | None = None,
    skip_knowledge: bool = False,
) -> None:
    """Write Alfred Script Filter JSON to stdout.

    Args:
        items: List of result items built with :func:`item`.
        variables: Workflow variables available to downstream actions.
        rerun: Seconds after which Alfred re-runs the script (0.1 - 5.0).
        cache: Alfred caching hints dict.
        skip_knowledge: If True, Alfred won't reorder based on usage.
    """
    payload: dict[str, Any] = {"items": items}

    if variables:
        payload["variables"] = variables
    if rerun is not None:
        payload["rerun"] = rerun
    if cache is not None:
        payload["cache"] = cache
    if skip_knowledge:
        payload["skipknowledge"] = True

    sys.stdout.write(json.dumps(payload, ensure_ascii=False))
    sys.stdout.flush()


def error_item(message: str, subtitle: str = "Press ⌘C to copy the error") -> dict[str, Any]:
    """Build a result item that displays an error to the user."""
    return item(
        title=f"Error: {message}",
        subtitle=subtitle,
        arg=message,
        valid=False,
    )
