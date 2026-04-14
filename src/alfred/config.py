"""Workflow configuration backed by Alfred's workflow data directory.

Alfred exposes the data directory via ``alfred_workflow_data``.
Values are stored as a flat JSON file, which Alfred can also read/write
via its built-in "Set Variable" / "Universal Action" objects.

Outside Alfred, falls back to ``~/.config/alfred-workflow/<bundle_id>/``.
"""

from __future__ import annotations

import dataclasses
import json
import os
from pathlib import Path
from typing import Any, cast


@dataclasses.dataclass
class SettingSpec:
    """Declaration of a single configuration setting.

    Attributes:
        key:         Configuration key used in the JSON store.
        default:     Value returned when the key has not been set by the user.
        description: Human-readable description shown in the config command.
    """

    key: str
    default: Any
    description: str


class ConfigSchema:
    """Declares available configuration keys with defaults and descriptions.

    Use as a builder to define all settings for the workflow::

        SCHEMA = (
            ConfigSchema()
            .add("use_uv", True, "Use uv instead of pip when available")
            .add("cache_ttl", 300, "Cache time-to-live in seconds")
        )
    """

    def __init__(self) -> None:
        self._specs: dict[str, SettingSpec] = {}

    def add(self, key: str, default: Any, description: str) -> ConfigSchema:
        """Declare a configuration key with a default value and description."""
        self._specs[key] = SettingSpec(key=key, default=default, description=description)
        return self

    def specs(self) -> list[SettingSpec]:
        """Return all declared settings in declaration order."""
        return list(self._specs.values())

    def default_for(self, key: str) -> Any:
        """Return the declared default for *key*, or ``None`` if not declared."""
        spec = self._specs.get(key)
        return spec.default if spec is not None else None

    def keys(self) -> list[str]:
        """Return all declared keys."""
        return list(self._specs.keys())


def _data_dir() -> Path:
    base = os.environ.get("alfred_workflow_data")
    if not base:
        bundle_id = os.environ.get("alfred_workflow_bundleid", "alfred-workflow-template")
        base = str(Path.home() / ".config" / "alfred-workflow" / bundle_id)
    path = Path(base)
    path.mkdir(parents=True, exist_ok=True)
    return path


class Config:
    """Persistent key-value store for workflow configuration.

    Example::

        config = Config()
        config.set("api_key", "secret")
        key = config.get("api_key")
    """

    _FILENAME = "config.json"

    @property
    def _path(self) -> Path:
        """Resolved lazily so env vars set by test fixtures are honoured."""
        return _data_dir() / self._FILENAME

    def _load(self) -> dict[str, Any]:
        if not self._path.exists():
            return {}
        try:
            return cast(dict[str, Any], json.loads(self._path.read_text(encoding="utf-8")))
        except json.JSONDecodeError:
            return {}

    def _save(self, data: dict[str, Any]) -> None:
        self._path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

    def get(self, key: str, default: Any = None) -> Any:
        return self._load().get(key, default)

    def set(self, key: str, value: Any) -> None:
        data = self._load()
        data[key] = value
        self._save(data)

    def delete(self, key: str) -> None:
        data = self._load()
        data.pop(key, None)
        self._save(data)

    def all(self) -> dict[str, Any]:
        return self._load()

    def reset(self) -> None:
        self._save({})
