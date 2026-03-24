#!/usr/bin/env bash
# Local development runner - simulates Alfred's Script Filter execution.
#
# Usage:
#   ./scripts/dev.sh "search foo"
#   ./scripts/dev.sh "config"
#   ./scripts/dev.sh ""
#
# Output is pretty-printed JSON if `jq` is available.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENTRY="$REPO_ROOT/workflow/scripts/entry.py"

QUERY="${1:-}"

# Make src/ importable without `pip install -e .`
# In the packaged workflow, entry.py adds workflow_root/src/ to sys.path.
# During development, workflow/src/ does not exist – the real source is at
# repo_root/src/, so we set PYTHONPATH explicitly.
export PYTHONPATH="$REPO_ROOT/src${PYTHONPATH:+:$PYTHONPATH}"

# Set environment variables that Alfred normally provides
export alfred_workflow_bundleid="${alfred_workflow_bundleid:-com.example.dev}"
export alfred_workflow_cache="${alfred_workflow_cache:-/tmp/alfred-dev-cache}"
export alfred_workflow_data="${alfred_workflow_data:-/tmp/alfred-dev-data}"
export alfred_workflow_version="${alfred_workflow_version:-0.0.0-dev}"
export alfred_workflow_uid="${alfred_workflow_uid:-com.example.dev}"
export alfred_workflow_name="${alfred_workflow_name:-Workflow Dev}"

mkdir -p "$alfred_workflow_cache" "$alfred_workflow_data"

echo "─────────────────────────────────────"
echo "  Alfred Script Filter Simulator"
echo "  Query: \"$QUERY\""
echo "─────────────────────────────────────"

if command -v jq &>/dev/null; then
  python3 "$ENTRY" "$QUERY" | jq .
else
  python3 "$ENTRY" "$QUERY"
fi
