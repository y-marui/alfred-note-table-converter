# Dev Charter (full)

> **This is the reference (English) version.**
> For the canonical (Japanese) version, see [README-jp.md](README-jp.md).

The **full** variant of [dev-charter](https://github.com/y-marui/dev-charter)
(the whole charter). Includes software-project-specific content — Python dev
environment, UI design, monetization policy, and so on. See
[CHARTER_INDEX.md](CHARTER_INDEX.md) for what's included. If you need a
lighter variant for documentation-only repositories, consider the `lite`
branch instead.

## Install (git subtree)

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter full --squash
```

After installing, paste the following prompt into your AI tool:

```
Run docs/dev-charter/INSTALL_CHECKLIST.md
```

The Quick Install one-liner does the same thing:

```bash
curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh | bash
```

## Update

Re-running the Quick Install one-liner also works for updates — it detects
the existing install and its branch (here, full), then runs `git subtree
pull` for you (stashing/restoring uncommitted changes as needed, and falling
back to a full re-sync for template-repo checkouts):

```bash
curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh | bash
```

To update manually instead: if the `dev-charter` remote is not set up (e.g., after cloning the project), add it first:

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git subtree pull --prefix=docs/dev-charter dev-charter full --squash
```

> **Note (projects created from a template repository):**
> GitHub templates copy files only — git history is not carried over — so `git subtree pull` will fail.
> The `check-charter.yml` workflow detects this automatically and handles it.
> For manual updates, use the following instead of `git subtree pull`:
> Make sure the working tree is clean first (`git reset --hard HEAD` discards uncommitted changes).
> The finishing commit is built in the same shape a real `git subtree` merge leaves behind
> (`MERGE_HEAD` plus a trailer-carrying squash commit), so it isn't rejected if
> `scripts/check-charter-subtree-edit.sh` is installed:
> ```bash
> git remote add dev-charter https://github.com/y-marui/dev-charter || true
> git fetch dev-charter
> git reset --hard HEAD
> git clean -fd docs/dev-charter/
> SPLIT=$(git rev-parse dev-charter/full)
> rm -rf docs/dev-charter/
> mkdir -p docs/dev-charter/
> git archive dev-charter/full | tar -x -C docs/dev-charter/
> git add docs/dev-charter/
> MSG="Squashed 'docs/dev-charter/' content from commit ${SPLIT}
>
> git-subtree-dir: docs/dev-charter
> git-subtree-split: ${SPLIT}"
> SQUASH=$(git commit-tree "$(git write-tree)" -p "$SPLIT" -m "$MSG")
> echo "$SQUASH" > "$(git rev-parse --git-path MERGE_HEAD)"
> printf '%s\n' "$MSG" > "$(git rev-parse --git-path MERGE_MSG)"
> git commit --no-edit
> ```

> **Note (the `git subtree pull` finishing commit is rejected by a pre-commit hook):**
> If your local copies of `scripts/check-charter-subtree-edit.sh` etc. still predate a fix
> carried by the update you're pulling in (e.g. a `MERGE_HEAD` exemption), the commit that
> finishes the merge can get blocked, leaving `.git/MERGE_HEAD` in place. Trying to work
> around this with a separate pre-sync commit doesn't help either — `docs/dev-charter/VERSION`
> is still the old value at that point, so `check-local-charter-version.sh` blocks that too.
> When `.git/MERGE_HEAD` is still present, finish that same merge instead of restarting it
> (the Quick Install one-liner does this automatically when updating):
> ```bash
> # Re-copy only the files that differ from docs/dev-charter/scripts/ (keep them executable)
> for f in scripts/*.sh scripts/*.ps1; do
>   [ -e "$f" ] || continue
>   incoming="docs/dev-charter/scripts/$(basename "$f")"
>   [ -f "$incoming" ] && ! cmp -s "$f" "$incoming" && cp "$incoming" "$f" && chmod +x "$f"
> done
> git add scripts/
> git commit --no-edit
> ```
> If there are conflicts under `docs/dev-charter/` (e.g. shared history was rewritten), that
> tree is never meant to be hand-edited locally, so always take the incoming side first —
> `git checkout --theirs -- docs/dev-charter/ && git add docs/dev-charter/` — then proceed as above.

After updating, paste the following prompt into your AI tool:

```
Run docs/dev-charter/UPDATE_CHECKLIST.md
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
    types: [opened, synchronize, reopened, ready_for_review]
  push:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  check:
    name: Check
    if: github.actor != 'dependabot[bot]' && (github.event_name != 'pull_request' || github.event.pull_request.draft == false)
    uses: y-marui/dev-charter/.github/workflows/check-charter.yml@main
    permissions:
      contents: write
      pull-requests: write
      actions: read

  gate:
    name: Dev Charter
    needs: [check]
    if: always()
    runs-on: ubuntu-latest
    steps:
      - name: Verify dev-charter check did not fail
        run: |
          result="${{ needs.check.result }}"
          if [ "$result" = "failure" ] || [ "$result" = "cancelled" ]; then
            echo "::error::dev-charter check did not succeed (got: $result)"
            exit 1
          fi
          echo "check result: $result (skipped is fine — draft or dependabot)"
```

full is this workflow's default `branch` input, so you don't need to set
`with: branch: full` explicitly.

> **Note:** `check` is skipped for Dependabot PRs and draft PRs (see below). `gate`
> treats a `skipped` result as fine in both cases and always reports a `Dev Charter`
> status (matching this workflow's own `name:`). Register `Dev Charter` — not `Check /
> check` — as the required status check in Branch Protection (Ruleset); see
> [CI_POLICY.md's Ruleset section](topics/CI_POLICY.md#branch-protection-ruleset).
> Registering the `check` job itself is unsafe: when it's skipped, the `Check / check`
> context is never reported at all, so the PR sits at "Expected — Waiting for status to
> be reported" forever.

> **Note:** Dependabot PRs are skipped — dependency-only activity doesn't warrant a
> charter check. If your repository goes fully quiet, no check will run. If you want a
> guaranteed periodic check regardless of activity, add a low-frequency `schedule`
> (e.g. monthly) alongside this.

> **Note:** Draft PRs are skipped (a draft can't be merged anyway, so there's no risk
> in leaving the check unreported). `ready_for_review` in `on.pull_request.types` makes
> sure taking a PR out of draft re-triggers a real run.

> **Note:** If your repository has Branch Protection rules that prevent direct pushes,
> add a bypass rule for the GitHub Actions bot
> (Settings > Rules > Rulesets > Bypass list > GitHub Actions).

## Makefile helper

`git subtree pull` fails if the working tree has uncommitted changes, so this
target automatically stashes before running and pops afterward.

This target doesn't need to remember whether you installed `full` or `lite`
(or another distribution branch added later). It auto-detects the installed
branch every time from the existing `docs/dev-charter/CHARTER_INDEX.md`'s
`# Charter Index (<branch>)` marker (generated by `scripts/publish-branch.sh`;
absence of a marker means `full`), which prevents the accident of updating a
full install with lite or vice versa.

```
.PHONY: update-charter
update-charter:
	curl -fsSL https://raw.githubusercontent.com/y-marui/dev-charter/main/scripts/install.sh | CHARTER_UPDATE_ONLY=1 bash
```

`CHARTER_UPDATE_ONLY=1` means that if this target is ever run before
anything is installed, it won't silently install `full` — it asks which
branch you want instead (or errors out with guidance in a non-interactive
environment).

## Badge for Adopting Projects

Place this badge in your project README to show dev-charter update health.

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
