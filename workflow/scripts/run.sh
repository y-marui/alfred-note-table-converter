#!/bin/sh
# Select Python runner based on use_uv setting from config.json.
# Reads alfred_workflow_data (set by Alfred at runtime) to locate config.
# Falls back to ~/.config/alfred-workflow/<bundleid>/ outside Alfred.
_data="${alfred_workflow_data:-$HOME/.config/alfred-workflow/${alfred_workflow_bundleid:-com.y-marui.alfred-note-table-converter}}"
_cfg="$_data/config.json"

_use_uv=$(python3 - "$_cfg" << 'PYEOF'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1])
try:
    v = json.loads(p.read_text()).get("use_uv", True) if p.exists() else True
except Exception:
    v = True
print("1" if v else "0")
PYEOF
)

if [ "${_use_uv:-1}" = "1" ] && command -v uv >/dev/null 2>&1; then
    exec uv run python3 scripts/entry.py "$1"
else
    exec python3 scripts/entry.py "$1"
fi
