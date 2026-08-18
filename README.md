# Dev Charter

> **This is the reference (English) version.**
> For the canonical (Japanese) version, see [README-jp.md](README-jp.md).

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](LICENSE)
[![check-charter CI](https://github.com/y-marui/dev-charter/actions/workflows/check-charter.yml/badge.svg)](https://github.com/y-marui/dev-charter/actions/workflows/check-charter.yml)

Shared development charter for AI-assisted software projects.

This repository defines common philosophy, architecture principles,
and development rules used across projects.

## Documents

See the canonical [CHARTER_INDEX.md](CHARTER_INDEX.md) for the complete document list and topic-to-file lookup table.

## How to Use

1. Pull dev-charter into `docs/dev-charter/` via `git subtree`
2. Have the AI read the charter and generate `AI_CONTEXT.md` and agent config files at the project root
3. After charter updates, run `git subtree pull` and have the AI sync the context files

See [AI_TOOL_SETUP.md](AI_TOOL_SETUP.md) for the structure spec.

## Quick Install

Run from your project root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh)
```

On Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.ps1 | iex
```

The script automates the git subtree setup and, if Claude Code is available,
guides you through the initial setup (INSTALL_CHECKLIST).

> **Note:** To customize the install path or branch, use environment variables:
> `CHARTER_PREFIX=path/to/charter bash <(curl -fsSL .../install.sh)`

## Install (git subtree)

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter main --squash
```

After installing, paste the following prompt into your AI tool:

```
Run docs/dev-charter/INSTALL_CHECKLIST.md
```

## Update

If the `dev-charter` remote is not set up (e.g., after cloning the project), add it first:

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```

> **Note (projects created from a template repository):**
> GitHub templates copy files only — git history is not carried over — so `git subtree pull` will fail.
> The `check-charter.yml` workflow detects this automatically and handles it.
> For manual updates, use the following instead of `git subtree pull`:
> ```bash
> git remote add dev-charter https://github.com/y-marui/dev-charter || true
> git fetch dev-charter
> SPLIT=$(git rev-parse dev-charter/main)
> rm -rf docs/dev-charter/
> mkdir -p docs/dev-charter/
> git archive dev-charter/main | tar -x -C docs/dev-charter/
> git add docs/dev-charter/
> git commit -m "Squashed 'docs/dev-charter/' content from commit ${SPLIT}
>
> git-subtree-dir: docs/dev-charter
> git-subtree-split: ${SPLIT}"
> ```

After updating, paste the following prompt into your AI tool:

```
Run docs/dev-charter/UPDATE_CHECKLIST.md
```

## Makefile helper

`git subtree pull` fails if the working tree has uncommitted changes, so this
target automatically stashes before running and pops afterward.

```
.PHONY: update-charter
update-charter:
	git remote | grep -q '^dev-charter$$' || \
	  git remote add dev-charter https://github.com/y-marui/dev-charter
	git fetch dev-charter
	@STASHED=0; \
	if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$$(git ls-files --others --exclude-standard)" ]; then \
		git stash push -u -m "update-charter"; \
		STASHED=1; \
	fi; \
	git subtree pull --prefix=docs/dev-charter dev-charter main --squash; \
	if [ "$$STASHED" = "1" ]; then git stash pop; fi
```

## Version Check (CI)

Add `.github/workflows/dev-charter-check.yml` to your project to check for updates
when a PR is opened or a commit is pushed to main, and open an update PR if outdated
(the check is skipped if one already succeeded within the last 7 days, so busy repos
don't re-check on every single event).

```yaml
name: Dev Charter

on:
  pull_request:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  check:
    name: Check
    if: github.actor != 'dependabot[bot]'
    uses: y-marui/dev-charter/.github/workflows/check-charter.yml@main
    permissions:
      contents: write
      pull-requests: write
      actions: read
```

> **Note:** Dependabot PRs are skipped — dependency-only activity doesn't warrant a
> charter check. If your repository goes fully quiet, no check will run. If you want a
> guaranteed periodic check regardless of activity, add a low-frequency `schedule`
> (e.g. monthly) alongside this.

> **Note:** If your repository has Branch Protection rules that prevent direct pushes,
> add a bypass rule for the GitHub Actions bot
> (Settings > Rules > Rulesets > Bypass list > GitHub Actions).

## Badge for Adopting Projects

Place this badge in your project README to show dev-charter update health.

### Workflow Status Badge

Shows whether dev-charter is up to date.

```markdown
[![Charter Check](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml/badge.svg)](https://github.com/{owner}/{repo}/actions/workflows/dev-charter-check.yml)
```

Replace `{owner}` and `{repo}` with your GitHub organization and repository name.

| State | Status Badge |
|---|---|
| Not installed / CI not set up | red (VERSION not found) |
| Installed, up to date | green |
| Installed, outdated | red |

---

*This document has a Japanese canonical version [README-jp.md](README-jp.md). Update both in the same commit when editing.*
