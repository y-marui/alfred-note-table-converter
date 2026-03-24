#!/usr/bin/env python3
"""Read the project version from pyproject.toml.

Supports both double-quoted and single-quoted TOML values.
Uses stdlib tomllib on Python 3.11+, falls back to regex on 3.9/3.10.

Usage:
    python3 scripts/read_version.py
"""

from __future__ import annotations

import pathlib
import re
import sys


def read_version(toml_path: pathlib.Path) -> str:
    content = toml_path.read_text(encoding="utf-8")

    # stdlib tomllib is available on Python 3.11+
    try:
        import tomllib  # type: ignore[import]

        data = tomllib.loads(content)
        return str(data["project"]["version"])
    except ImportError:
        pass

    # Fallback: scan line-by-line for [project] section
    in_project = False
    for line in content.splitlines():
        if re.match(r"^\[project\]", line):
            in_project = True
        elif re.match(r"^\[", line):
            in_project = False
        elif in_project:
            # Match: version = "1.2.3"  or  version = '1.2.3'
            m = re.match(r"^version\s*=\s*['\"]([^'\"]+)['\"]", line)
            if m:
                return m.group(1)

    sys.exit("ERROR: version not found in pyproject.toml [project] section")


if __name__ == "__main__":
    print(read_version(pathlib.Path("pyproject.toml")))
