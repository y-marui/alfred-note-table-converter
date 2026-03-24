# Contributing

Thank you for contributing!

## Before you start

- Check existing issues and PRs to avoid duplicate work.
- For large changes, open an issue first to discuss the approach.

## Development setup

```bash
git clone https://github.com/yourname/alfred-workflow-template
cd alfred-workflow-template
make install
```

## Making changes

1. Create a branch: `git checkout -b feat/my-feature`
2. Make your changes
3. Run checks:

```bash
make lint
make typecheck
make test
make build
```

4. Test in Alfred: `make build` → double-click the `.alfredworkflow`
5. Open a PR using the template

## Code style

- ruff + black enforced by CI
- Type hints required on all public functions
- Keep runtime dependencies minimal (they're vendored)

## Commit guidelines

- Commit per **feature unit**, after confirming it works.
- **No WIP commits** — do not commit code that does not run.

### Commit message format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add clipboard copy action
fix: cache miss on special characters in query
chore: update ruff to 0.5.0
docs: add examples to usage.md
refactor: simplify router dispatch logic
```

## Pull Request checklist

- [ ] `make lint` passes
- [ ] `make typecheck` passes
- [ ] `make test` passes
- [ ] `make build` succeeds
- [ ] New commands have tests
- [ ] `docs/usage.md` updated if user-facing changes
- [ ] `CHANGELOG.md` entry added under `[Unreleased]`
