"""Application-level configuration schema.

Declares all user-configurable settings with defaults and descriptions.
The schema is consumed by the config command to display and manage settings.

Example — reading a setting with its declared default::

    from app.settings import SCHEMA
    from alfred.config import Config

    config = Config()
    use_uv = config.get("use_uv", SCHEMA.default_for("use_uv"))
"""

from __future__ import annotations

from alfred.config import ConfigSchema

SCHEMA: ConfigSchema = ConfigSchema().add(
    "use_uv",
    True,
    "Use uv run to execute the workflow script when uv is available",
)
