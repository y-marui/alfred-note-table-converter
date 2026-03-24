#!/usr/bin/env bash
# Create a GitHub Release from the current git tag.
#
# Prerequisites:
#   - gh CLI installed and authenticated
#   - Current commit is tagged (e.g. v1.2.3)
#   - dist/ contains the built .alfredworkflow
#
# Usage:
#   git tag v1.2.3
#   make build
#   make release
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$REPO_ROOT/dist"

# ---------------------------------------------------------------------------
# Validate prerequisites
# ---------------------------------------------------------------------------
if ! command -v gh &>/dev/null; then
  echo "ERROR: gh CLI not found. Install it: https://cli.github.com" >&2
  exit 1
fi

TAG=$(git tag --points-at HEAD | head -n 1)
if [[ -z "$TAG" ]]; then
  echo "ERROR: HEAD is not tagged. Run: git tag v<version>" >&2
  exit 1
fi

ARTIFACT=$(find "$DIST_DIR" -maxdepth 1 -name "*.alfredworkflow" 2>/dev/null | head -n 1)
if [[ -z "$ARTIFACT" ]]; then
  echo "ERROR: No .alfredworkflow found in dist/. Run: make build" >&2
  exit 1
fi

echo "→ Releasing $TAG"
echo "  Artifact: $(basename "$ARTIFACT")"

# ---------------------------------------------------------------------------
# Extract release notes from CHANGELOG.md
# ---------------------------------------------------------------------------
NOTES=$(python3 "$REPO_ROOT/scripts/extract_changelog.py" "$TAG")

# ---------------------------------------------------------------------------
# Create GitHub Release
# ---------------------------------------------------------------------------
gh release create "$TAG" \
  "$ARTIFACT" \
  --title "$TAG" \
  --notes "$NOTES"

echo "✓ Release $TAG created"
