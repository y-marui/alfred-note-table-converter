# Usage

## Quick Start

Open Alfred and type `wf` followed by a space.

## Commands

### Search (default)

```
wf <query>
wf search <query>
```

Type any query to search. Press Enter to open the result.

| Key | Action |
|---|---|
| ↩ Enter | Open result |
| ⌘C | Copy result URL |

### Open

```
wf open <name>
```

Open a named shortcut.

Available shortcuts: `repo`, `docs`, `issues`

### Config

```
wf config
wf config reset
```

View current settings or reset all configuration.

### Help

```
wf help
```

Show all available commands.

## Tips

- The workflow remembers your most-used results (Alfred learns from usage).
- Results are cached for 5 minutes to minimize API calls.
- Use `⌘,` in Alfred to access Workflow Preferences.

## Troubleshooting

**No results appear**
- Check Alfred's debugger: open Alfred → ⌘D
- Check logs: `~/Library/Logs/Alfred/Workflow/<bundle-id>.log`

**Results are stale**
- The cache TTL is 5 minutes. Wait for it to expire, or clear manually:
  `wf config reset`
