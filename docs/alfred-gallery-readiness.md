# Alfred Gallery Readiness

Tracks this Workflow's compliance with the
[Alfred Gallery submission requirements](https://alfred.app/submit/) and
[style guide](https://alfred.app/submit/styleguide/), per dev-charter's
[`topics/alfred/ALFRED_GALLERY.md`](docs/dev-charter/topics/alfred/ALFRED_GALLERY.md).
This is a checklist against an external, occasionally-changing policy —
re-read the linked pages before acting on stale entries here.

## Submission process

Alfred does not accept Gallery submissions directly. The documented path is:
share the workflow on the [Alfred Forum](https://www.alfredforum.com/) first;
once it is "generally stable and trusted by a number of users," the Alfred
team may invite an official Gallery submission. There is no self-service
form. Forum posting itself stays out of scope here unless explicitly
requested — this document only tracks technical/documentation readiness so
that submission is not blocked on our side whenever that step happens.

## Checklist

| Requirement | Status | Notes |
|---|---|---|
| Binaries signed and notarised | ⏳ Pending | `.github/workflows/release.yml` has the signing/notarization steps, but no tag has been pushed yet — unverified until a real release ships. Tracked in [#43](https://github.com/y-marui/alfred-note-table-converter/issues/43) |
| No self-update | ✅ Done | Updates ship only as new `.alfredworkflow` releases; no self-update code path |
| No self-installed external software | ✅ Done | `go.mod` has no third-party dependencies; nothing is fetched at runtime |
| Icon ≥ 256×256 px | ✅ Done | `workflow/icon.png` is now 1024×1024 (previously 1024×1048, not square — cropped to match Alfred's square icon frame) |
| Keyword ≥ 3 characters | ✅ Done | `tbl` (exactly 3) |
| Category set | ✅ Done | `Productivity` — see [`docs/alfred-workflow-notes/workflow-object-schema.md`](docs/alfred-workflow-notes/workflow-object-schema.md#category) for the valid value list |
| User Configuration over environment variables | ✅ N/A | Nothing today needs user-facing configuration |
| English instructions in About/README | ✅ Done | `README.md` is the reference (English) version; `README-jp.md` is canonical |
| README follows Gallery style guide | ✅ Done | `## Usage` opens with "via the `tbl` keyword" phrasing; the Enter action is a `<kbd>` bullet, not a table |
| Screenshots (full Alfred window, shadow, no background) | ✅ Done | `images/tbl.png`, real window capture (rounded corners + drop shadow, transparent background) |

## Out of scope here

- Posting to the Alfred Forum and the Gallery submission itself — a
  per-project decision, not mandated by this checklist
- Exporting a Developer ID certificate, generating a notarization API key,
  and registering the GitHub Actions secrets `release.yml` expects — manual
  steps only the repository owner can perform
