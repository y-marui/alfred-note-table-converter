# Architecture

## Overview

This workflow uses a layered architecture to keep Alfred-specific code isolated
from business logic, making it easy to test and extend.

```
Alfred
  │  keyword + query
  ▼
workflow/scripts/entry.py       ← Alfred boundary (UI layer)
  │
  ▼
src/alfred/safe_run.py          ← Exception safety wrapper
  │
  ▼
src/app/core.py                 ← Application orchestrator
  │
  ▼
src/alfred/router.py            ← Command dispatcher
  │
  ├─ search  → src/app/commands/search.py
  ├─ open    → src/app/commands/open_cmd.py
  ├─ config  → src/app/commands/config_cmd.py
  └─ help    → src/app/commands/help_cmd.py
                │
                ▼
            src/app/services/   ← Business logic + caching
                │
                ▼
            src/app/clients/    ← External API / IO
```

## Layers

### UI Layer (`workflow/`)

- `scripts/entry.py`: The only file Alfred executes directly.
  - Sets up `sys.path` (vendor + src)
  - Calls `safe_run(main)`
  - No business logic here

### Alfred SDK (`src/alfred/`)

Thin helpers that abstract Alfred-specific behavior.
These are **not** application logic — they wrap Alfred's environment.

| Module | Purpose |
|---|---|
| `response.py` | Build and emit Script Filter JSON |
| `router.py` | Parse query → dispatch to command |
| `safe_run.py` | Catch exceptions → show error item |
| `cache.py` | TTL disk cache via `alfred_workflow_cache` |
| `config.py` | Persistent config via `alfred_workflow_data` |
| `logger.py` | File logger to `~/Library/Logs/Alfred/Workflow/` |

### Application Layer (`src/app/`)

Pure Python business logic — no Alfred dependency.
This layer can be tested without Alfred and run from the CLI.

| Directory | Purpose |
|---|---|
| `commands/` | One module per Alfred command. Each has `handle(args: str) -> None` |
| `services/` | Business logic coordinating between commands and clients |
| `clients/` | Thin HTTP/IO wrappers for external APIs |
| `core.py` | Wires router to commands — the dependency injection point |

## Query Parsing

Alfred sends the full query string to the script.
The router splits it into `<command> <args>`:

```
"search foo bar"  →  command="search",  args="foo bar"
"open repo"       →  command="open",    args="repo"
"config"          →  command="config",  args=""
"foo bar"         →  command="search",  args="foo bar" (default fallback)
```

## Dependency Flow

```
commands → services → clients → external APIs
         ↘
           alfred SDK (response, cache, config, logger)
```

Commands depend on services, not clients directly.
Services own caching logic.
Clients are stateless HTTP wrappers.

## Packaging

At build time (`make build`):

```
.build/               ← temporary build directory
├── info.plist        ← version synced from pyproject.toml
├── icon.png
├── scripts/
│   └── entry.py
├── src/              ← copied from repo src/
│   ├── alfred/
│   └── app/
└── vendor/           ← pip install -r requirements.txt -t vendor/
```

The entire `.build/` directory is zipped to `dist/<name>-<version>.alfredworkflow`.
