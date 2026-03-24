#!/usr/bin/env python3
"""Extract release notes for a given version tag from CHANGELOG.md.

Usage:
    python3 scripts/extract_changelog.py v1.2.3
    python3 scripts/extract_changelog.py 1.2.3

Exits 0 and prints the notes, or exits 0 with a fallback message if the
version is not found (avoids CI failure on missing changelog entry).
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


def extract(changelog_path: Path, version: str) -> str:
    tag = version.lstrip("v")
    content = changelog_path.read_text(encoding="utf-8")

    # Match: ## [1.2.3] or ## 1.2.3, capture until next ## heading or EOF
    pattern = rf"^## \[?{re.escape(tag)}\]?[^\n]*\n(.*?)(?=^## |\Z)"
    match = re.search(pattern, content, re.DOTALL | re.MULTILINE)
    if match:
        return match.group(1).strip()
    return f"Release {tag}"


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: extract_changelog.py <version>", file=sys.stderr)
        sys.exit(1)

    notes = extract(Path("CHANGELOG.md"), sys.argv[1])
    print(notes)
