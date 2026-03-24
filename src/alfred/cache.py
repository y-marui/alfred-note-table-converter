"""TTL-based disk cache stored in Alfred's workflow cache directory.

Alfred exposes the cache directory via the environment variable
``alfred_workflow_cache``. Outside Alfred (tests, CLI), a temporary
directory under ``/tmp`` is used as a fallback.
"""

from __future__ import annotations

import json
import os
import string
import time
from pathlib import Path
from typing import Any, Callable


def _cache_dir() -> Path:
    base = os.environ.get("alfred_workflow_cache") or str(Path("/tmp") / "alfred-workflow-cache")
    path = Path(base)
    path.mkdir(parents=True, exist_ok=True)
    return path


class Cache:
    """Simple TTL cache backed by JSON files on disk.

    Example::

        cache = Cache(ttl=300)
        result = cache.get("my_key")
        if result is None:
            result = expensive_operation()
            cache.set("my_key", result)
    """

    def __init__(self, ttl: float = 300, namespace: str = "default") -> None:
        """
        Args:
            ttl: Time-to-live in seconds. Default 300 (5 minutes).
            namespace: Sub-directory name within the cache dir.
        """
        self.ttl = ttl
        self._namespace = namespace

    @property
    def _dir(self) -> Path:
        """Resolved lazily so env vars set by test fixtures are honoured."""
        path = _cache_dir() / self._namespace
        path.mkdir(parents=True, exist_ok=True)
        return path

    # Characters allowed in cache filenames (whitelist approach)
    _SAFE_CHARS = frozenset(string.ascii_letters + string.digits + "-_.")

    def _path(self, key: str) -> Path:
        """Return the cache file path for key, sanitizing to safe filename chars."""
        safe_key = "".join(c if c in self._SAFE_CHARS else "_" for c in key)
        if not safe_key:
            safe_key = "_empty_"
        return self._dir / f"{safe_key}.json"

    def get(self, key: str) -> Any | None:
        """Return cached value if it exists and has not expired."""
        path = self._path(key)
        if not path.exists():
            return None
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            if time.time() - data["timestamp"] > self.ttl:
                path.unlink(missing_ok=True)
                return None
            return data["value"]
        except (json.JSONDecodeError, KeyError):
            path.unlink(missing_ok=True)
            return None

    def set(self, key: str, value: Any) -> None:
        """Store value with the current timestamp."""
        path = self._path(key)
        payload = {"timestamp": time.time(), "value": value}
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")

    def delete(self, key: str) -> None:
        """Remove a single cached entry."""
        self._path(key).unlink(missing_ok=True)

    def clear(self) -> None:
        """Remove all entries in this namespace."""
        for f in self._dir.glob("*.json"):
            f.unlink(missing_ok=True)

    def get_or_set(self, key: str, fn: Callable[..., Any], *args: Any, **kwargs: Any) -> Any:
        """Return cached value, or call fn(*args, **kwargs) and cache the result."""
        value = self.get(key)
        if value is None:
            value = fn(*args, **kwargs)
            self.set(key, value)
        return value
