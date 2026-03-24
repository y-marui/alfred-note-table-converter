#!/usr/bin/env bash
# Install runtime dependencies into workflow/vendor/
# Run this after adding packages to requirements.txt.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/workflow/vendor"

echo "→ Installing dependencies into $VENDOR_DIR"
mkdir -p "$VENDOR_DIR"

# Clear existing vendor dir to avoid stale packages
rm -rf "${VENDOR_DIR:?}"/*

if [[ ! -f "$REPO_ROOT/requirements.txt" ]]; then
  echo "  No requirements.txt found - skipping vendor install"
  exit 0
fi

pip3 install \
  --quiet \
  --requirement "$REPO_ROOT/requirements.txt" \
  --target "$VENDOR_DIR" \
  --upgrade

echo "✓ Vendor install complete"
