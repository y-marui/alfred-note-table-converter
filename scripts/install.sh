#!/usr/bin/env bash
# dev-charter quick installer
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
#
# Environment variables (all optional):
#   CHARTER_REMOTE   git remote name          (default: dev-charter)
#   CHARTER_URL      repository URL           (default: https://github.com/y-marui/dev-charter)
#   CHARTER_PREFIX   install directory        (default: docs/dev-charter)
#   CHARTER_BRANCH   branch to install from   (default: main)

set -euo pipefail

REMOTE_NAME="${CHARTER_REMOTE:-dev-charter}"
REMOTE_URL="${CHARTER_URL:-https://github.com/y-marui/dev-charter}"
PREFIX="${CHARTER_PREFIX:-docs/dev-charter}"
BRANCH="${CHARTER_BRANCH:-main}"

# 1. Verify we are inside a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: not in a git repository. Run this script from your project root." >&2
    exit 1
fi

# 2. Skip if already installed
if [ -d "$PREFIX" ]; then
    echo "dev-charter is already installed at $PREFIX."
    echo "To update, run:"
    printf "  git remote | grep -q '%s' || git remote add '%s' '%s'\n" \
        "$REMOTE_NAME" "$REMOTE_NAME" "$REMOTE_URL"
    printf "  git subtree pull --prefix=%s %s %s --squash\n" \
        "$PREFIX" "$REMOTE_NAME" "$BRANCH"
    exit 0
fi

# 3. Add remote if not present
if ! git remote get-url "$REMOTE_NAME" > /dev/null 2>&1; then
    echo "Adding remote '$REMOTE_NAME'..."
    git remote add "$REMOTE_NAME" "$REMOTE_URL"
fi

# 4. Fetch
echo "Fetching $REMOTE_NAME..."
git fetch "$REMOTE_NAME"

# 5. Install via git subtree
echo "Installing dev-charter to $PREFIX..."
git subtree add --prefix="$PREFIX" "$REMOTE_NAME" "$BRANCH" --squash

# 6. Success message + prompt examples
cat <<EOF

dev-charter installed at $PREFIX

Next — paste this prompt into your AI tool (Claude Code, Copilot, Gemini, etc.):

  $PREFIX/INSTALL_CHECKLIST.md を実行して
  (English: Run $PREFIX/INSTALL_CHECKLIST.md)

EOF

# 7. Offer to launch Claude Code if available
if command -v claude > /dev/null 2>&1; then
    if [ -t 0 ]; then
        printf "Launch Claude Code now to run the setup? [Y/n] "
        read -r answer
        case "${answer:-Y}" in
            [Yy]*|"")
                exec claude "${PREFIX}/INSTALL_CHECKLIST.md を実行して"
                ;;
            *)
                printf "\nTo start setup later, run:\n"
                printf "  claude \"%s/INSTALL_CHECKLIST.md を実行して\"\n" "$PREFIX"
                ;;
        esac
    else
        printf "Tip: launch Claude Code to start setup:\n"
        printf "  claude \"%s/INSTALL_CHECKLIST.md を実行して\"\n" "$PREFIX"
    fi
fi
