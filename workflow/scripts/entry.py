#!/usr/bin/env python3
"""Alfred Script Filter entrypoint.

This file is executed by Alfred with the query as the first argument.
It sets up the Python path (vendor + src) and delegates to the application.

Alfred runs this script from the workflow package root, so paths are
relative to the directory containing info.plist.
"""

from __future__ import annotations

import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Path setup
# ---------------------------------------------------------------------------
# workflow_root/
# ├── info.plist
# ├── scripts/
# │   └── entry.py   ← here
# ├── src/           ← application code (copied by build.sh)
# └── vendor/        ← third-party packages (pip installed)

_workflow_root = Path(__file__).resolve().parent.parent

for _p in (
    str(_workflow_root / "vendor"),
    str(_workflow_root / "src"),
):
    if _p not in sys.path:
        sys.path.insert(0, _p)

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
from alfred.safe_run import safe_run  # noqa: E402
from app.core import run  # noqa: E402


def main() -> None:
    query = sys.argv[1] if len(sys.argv) > 1 else ""
    run(query)


if __name__ == "__main__":
    safe_run(main)
