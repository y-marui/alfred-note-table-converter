# Alfred Workflow Notes

Cross-project reference material for building Alfred 5 Script Filter
workflows — knowledge that isn't specific to any single workflow project.

`alfred-workflow-template` is the **canonical** source for this directory.
Edit files under here directly in that repository. Other Alfred workflow
projects (including ones generated from this template) pull it in via
`git subtree`, the same distribution pattern this repo itself uses for
[`docs/dev-charter/`](../dev-charter/README.md).

## Contents

| Document | Description |
|---|---|
| [configuration-builder.md](configuration-builder.md) | Alfred's Configuration Builder (`userconfigurationconfig`) — widget types and their config keys |
| [workflow-object-schema.md](workflow-object-schema.md) | Reverse-engineered schema of `info.plist` objects (Script Filter, Universal Action Trigger, etc.) — Alfred does not publish this |

## Installing in a consuming project

This directory lives at `docs/alfred-workflow-notes/` *inside* the
`alfred-workflow-template` repo, not at that repo's root (unlike
`docs/dev-charter/`, whose upstream repo root *is* the shared content). A
plain `git subtree add`/`pull` against `alfred-workflow-template` pulls in
that repo's entire root — `.github/`, `pyproject.toml`, `uv.lock`, everything
— not just this subdirectory.
[`scripts/install-workflow-notes.sh`](../../scripts/install-workflow-notes.sh)
handles that correctly: it splits this subdirectory's history out first
(`git subtree split`, which — without `--branch` — prints the split commit's
SHA directly, with no throwaway ref to collide with or clean up), then
adds or merges just that, auto-detecting whether this is a first-time
install or an update.

Run from the consuming project's root:

```bash
curl -fsSL https://raw.githubusercontent.com/y-marui/alfred-workflow-template/main/scripts/install-workflow-notes.sh | bash
```

(Piped into `bash` rather than `bash <(curl ...)` — the latter needs
process substitution, which the outer shell must parse, and Make's default
`$(SHELL)` is `/bin/sh`, which can't. A plain pipe works under any shell.)

To wire this into a Makefile target (mirroring `update-charter`):

```makefile
update-workflow-notes:
	curl -fsSL https://raw.githubusercontent.com/y-marui/alfred-workflow-template/main/scripts/install-workflow-notes.sh | bash
```

This repo's own [`Makefile`](../../Makefile) carries this exact target
commented out — it's the *source* of this directory, so it has nothing to
pull from itself; the commented block exists only as the copy-paste
reference for consumers.

If the script's `git subtree split`/`add`/`merge` steps abort partway
through (e.g. a `git subtree split` failure), any stash it took beforehand
is left in place rather than popped — recoverable manually (`git stash
list`), safer than popping onto a tree a failed step may have left in an
unexpected state.

And a pre-commit hook blocking direct edits under the installed subtree,
mirroring this repo's `scripts/check-charter-subtree-edit.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
PREFIX="docs/alfred-workflow-notes"

# `git subtree`'s squash commit is made via `git commit-tree` and never
# touches this hook. A *clean* join merge fires `pre-merge-commit`, not
# this hook, either — only when the join needs manual conflict resolution
# does finishing it with a normal `git commit` reach this hook. Skip only
# when MERGE_HEAD carries the `git-subtree-dir: $PREFIX` trailer git
# subtree itself writes — a bare "mid-merge" check would also exempt an
# unrelated merge that happens to touch this prefix.
MERGE_HEAD_PATH=$(git rev-parse --git-path MERGE_HEAD 2>/dev/null || true)
if [ -n "$MERGE_HEAD_PATH" ] && [ -f "$MERGE_HEAD_PATH" ]; then
  MERGE_HEAD_SHA=$(cat "$MERGE_HEAD_PATH")
  if git log -1 --format=%B "$MERGE_HEAD_SHA" 2>/dev/null | grep -qxF "git-subtree-dir: ${PREFIX}"; then
    exit 0
  fi
fi

CHANGED=$(git diff --cached --name-only -- "$PREFIX" || true)
[ -n "$CHANGED" ] || exit 0
echo "error: ${PREFIX}/ must not be edited directly."
echo "  Open an issue against alfred-workflow-template and pull the update via git subtree pull."
exit 1
```

No CI automation pulls updates on a schedule — same choice `dev-charter`
makes. Pull manually when you know something changed.

If a change is needed, open an issue against `alfred-workflow-template`
(this repo) rather than editing the consuming project's copy — edits made
downstream are lost on the next `git subtree pull` and never reach the
other projects sharing this directory.
