# Security Policy

## Supported Versions

Only the latest release is supported with security fixes.

## Reporting a Vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities.

Instead, report them privately via
[GitHub Security Advisories](https://github.com/yourname/alfred-workflow-template/security/advisories/new)
or email the maintainer directly.

We aim to acknowledge reports within 48 hours and provide a fix within 7 days
for confirmed vulnerabilities.

## Scope

This is a workflow template. Common areas of concern:

- **Credential handling** — never store secrets in `workflow/info.plist` or
  committed files; use Alfred's built-in encrypted keychain instead.
- **Input sanitization** — Alfred query strings are passed to `entry.py`; they
  must not be interpolated into shell commands or SQL without sanitization.
- **Dependency security** — vendored packages in `workflow/vendor/` should be
  kept up-to-date; dependabot monitors `.github/workflows/` automatically.

## Automated security checks

| Hook | What it detects |
|---|---|
| `gitleaks` (`.gitleaks.toml`) | Hardcoded secrets, API keys, local absolute paths |
| `detect-private-key` | SSH/TLS private key headers |
| `no-commit-dotenv` | `.env` files accidentally staged |
| `check-added-large-files` | Files over 500 KB |

These hooks run on every commit (pre-commit) and in CI (`security` job).
