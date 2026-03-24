"""Pytest configuration and shared fixtures."""

from __future__ import annotations

import sys
from collections.abc import Generator
from pathlib import Path

import pytest

# Ensure src/ is importable without installing the package
_src = str(Path(__file__).parent.parent / "src")
if _src not in sys.path:
    sys.path.insert(0, _src)


@pytest.fixture(autouse=True)
def alfred_env(
    tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> Generator[dict[str, Path], None, None]:
    """Set Alfred environment variables to temporary directories.

    This prevents tests from reading/writing real Alfred data dirs
    and isolates each test run.
    """
    cache_dir = tmp_path / "cache"
    data_dir = tmp_path / "data"
    cache_dir.mkdir()
    data_dir.mkdir()

    monkeypatch.setenv("alfred_workflow_cache", str(cache_dir))
    monkeypatch.setenv("alfred_workflow_data", str(data_dir))
    monkeypatch.setenv("alfred_workflow_bundleid", "com.example.test")

    yield {"cache": cache_dir, "data": data_dir}
