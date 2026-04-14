"""Application-level configuration schema.

Declares user-configurable settings managed via config.json (alfred.config.Config).
Settings controlled by Alfred's Configuration Builder (userconfigurationconfig in
info.plist) are passed as environment variables and do NOT appear here.

Example — reading a setting with its declared default::

    from app.settings import SCHEMA
    from alfred.config import Config

    config = Config()
    value = config.get("my_key", SCHEMA.default_for("my_key"))
"""

from __future__ import annotations

from alfred.config import ConfigSchema

# No app-level config keys yet.
# Settings managed by Alfred's Configuration Builder (e.g. use_uv) are
# available as environment variables set by Alfred at runtime.
SCHEMA: ConfigSchema = ConfigSchema()
