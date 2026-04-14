#!/bin/sh
# Select Python runner based on the use_uv workflow variable.
# Alfred sets use_uv ("1" or "") from the Configuration Builder (userconfigurationconfig).
# Falls back to enabled (use_uv=1) when the variable is unset.
if [ "${use_uv:-1}" = "1" ] && command -v uv >/dev/null 2>&1; then
    exec uv run --no-project python3 scripts/entry.py "$1"
else
    exec python3 scripts/entry.py "$1"
fi
