# Dev Charter

> **This is the reference (English) version.**
> For the canonical (Japanese) version, see [README-jp.md](README-jp.md).

Shared development charter for AI-assisted software projects.

This repository defines common philosophy, architecture principles,
and development rules used across projects.

## Documents

| File | Description |
|---|---|
| [PRINCIPLES.md](PRINCIPLES.md) | Development philosophy, design and architecture principles |
| [CODE_STYLE.md](CODE_STYLE.md) | Code style guide |
| [AI_COLLABORATION_RULES.md](AI_COLLABORATION_RULES.md) | AI collaboration rules and role assignments |
| [AI_CONTEXT_HIERARCHY.md](AI_CONTEXT_HIERARCHY.md) | AI context priority hierarchy |
| [LANGUAGE_POLICY.md](LANGUAGE_POLICY.md) | Language policy (canonical = Japanese) |
| [LOCALIZATION_POLICY.md](LOCALIZATION_POLICY.md) | Localization and supported languages |
| [PROJECT_LIFECYCLE.md](PROJECT_LIFECYCLE.md) | Project lifecycle and team structure |
| [UI_GUIDELINES.md](UI_GUIDELINES.md) | UI guidelines, color palette, iconography |
| [MONETIZATION_POLICY.md](MONETIZATION_POLICY.md) | Monetization policy and platform-specific guidelines |
| [SECURITY_POLICY.md](SECURITY_POLICY.md) | Security policy and hook configuration reference |
| [GITHUB_TEMPLATE_GUIDELINES.md](GITHUB_TEMPLATE_GUIDELINES.md) | GitHub template repository guidelines (environment, language, LICENSE, README) |

## How to Use

### 1. Add to your project
Use `git subtree` to pull dev-charter into `docs/dev-charter/`. Commit the files — do not `.gitignore` them. This keeps the charter version-controlled, reproducible, and accessible offline.

### 2. Generate AI_CONTEXT.md at project setup
At the start of a new project, have the AI read the dev-charter files and generate or update `AI_CONTEXT.md` at the project root. This compiles the charter into a project-specific context file.

### 3. Configure AI tools to auto-load AI_CONTEXT.md

Create a config file for each AI tool so it is loaded automatically at the start of every session.

**Claude Code** — create `CLAUDE.md` at the project root:

```
@AI_CONTEXT.md
```

**GitHub Copilot** — copy the contents of `AI_CONTEXT.md` into `.github/copilot-instructions.md`.
Copilot cannot read files dynamically, so the content must be included directly. Keep it in sync with `AI_CONTEXT.md` in the same commit whenever `AI_CONTEXT.md` changes.

**Gemini CLI** — no automatic loading is available; pass `AI_CONTEXT.md` manually at each session.
Update this instruction when Gemini CLI gains an auto-loading mechanism.

### 4. Update when the charter changes
After `git subtree pull`, have the AI review the diff and update `AI_CONTEXT.md` as needed.

## Install (git subtree)

```
git remote add dev-charter https://github.com/y-marui/dev-charter
git fetch dev-charter
git subtree add --prefix=docs/dev-charter dev-charter main --squash
```

After installing, paste the following prompt into Claude Code to generate a project-specific `AI_CONTEXT.md`.

```
Read all files in docs/dev-charter/, explore this project, and generate or update
AI_CONTEXT.md at the project root.
AI_CONTEXT.md is the single context file AI will reference in every subsequent session.

## Step 1: Explore

Read and understand the following:

- Charter: docs/dev-charter/*.md (all files)
- Project overview: README and existing documentation
- Tech stack: languages, frameworks, versions (package.json, go.mod, Podfile, etc.)
- Existing conventions: .editorconfig, lint config, pre-commit config, CI config
- Existing AI config: CLAUDE.md, AI_CONTEXT.md (if present, review and update with any differences)

## Step 2: Generate AI_CONTEXT.md

Create the file with the following sections.
Do not copy the charter verbatim — extract and summarize only what is directly relevant to this project.
Charter documents that do not apply to this project may be skipped.

### Project Overview
Purpose, tech stack (language, framework, version), key directories

### Applied Charter Principles
Principles and rules that directly affect this project's development and operational workflow

### Project-Specific Rules
Existing conventions not covered by the charter, or items that override / extend it

### AI Tool Assignments
Roles for Claude Code / Copilot / Gemini CLI
(Omit unused tools; reflect the actual team setup)

### Prohibited Actions
Security constraints and out-of-scope changes

## Notes

- If you have questions or ambiguities, ask all of them at once before starting
- If the charter conflicts with existing conventions, list the conflicts and confirm priority with the user before proceeding
- Do not commit after generating (let the user review first)
```

## Update

```
git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```

After updating, paste the following prompt into Claude Code to bring `AI_CONTEXT.md` in sync with the latest charter.

```
Read all files in docs/dev-charter/, compare them with the current AI_CONTEXT.md,
and update only the sections affected by charter changes.

## Steps

1. Read docs/dev-charter/*.md
2. Read AI_CONTEXT.md
3. Identify the differences and rewrite only the affected sections

## Notes

- No need to re-explore the entire project
- If AI_CONTEXT.md does not exist, use the install prompt instead
- If a charter change conflicts with a project-specific rule, list the conflicts and confirm priority with the user
- Do not commit after updating (let the user review first)
```

## Makefile helper

```
update-charter:
	git subtree pull --prefix=docs/dev-charter dev-charter main --squash
```
