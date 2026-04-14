# Alfred Configuration Builder

Alfred's Configuration Builder (`userconfigurationconfig` in `info.plist`) lets users
configure workflow settings through Alfred Preferences without editing plist files directly.

## Structure

Each entry in `userconfigurationconfig` is a dict with these top-level keys:

| Key | Required | Description |
|---|---|---|
| `type` | yes | Widget type (see below) |
| `label` | yes | Display name shown in Alfred Preferences |
| `variable` | yes | Environment variable name passed to scripts |
| `description` | no | Help text shown below the widget |
| `config` | yes | Type-specific settings (see per-type tables) |

Variable names in this project use **lowercase with underscores** (e.g. `use_uv`).

## How variables reach scripts

Alfred sets each `variable` as an environment variable before running the script.
Access them in Python via `os.environ.get("variable_name", default)`.

```python
import os

value = os.environ.get("my_variable", "fallback")
```

Checkbox values are `"1"` (checked) or `""` empty string (unchecked) — not `"true"`/`"false"`.

```python
enabled = os.environ.get("use_uv", "") == "1"
```

---

## Types

### textfield

Single-line text input.

```xml
<dict>
    <key>type</key>      <string>textfield</string>
    <key>label</key>     <string>API Base URL</string>
    <key>variable</key>  <string>api_base_url</string>
    <key>description</key>
    <string>Base URL for the external API.</string>
    <key>config</key>
    <dict>
        <key>default</key>      <string>https://api.example.com/v1</string>
        <key>placeholder</key>  <string>https://</string>
        <key>required</key>     <false/>
        <key>trim</key>         <true/>
    </dict>
</dict>
```

| config key | Type | Description |
|---|---|---|
| `default` | string | Initial value |
| `placeholder` | string | Ghost text when empty |
| `required` | bool | Block workflow if empty |
| `trim` | bool | Strip leading/trailing whitespace before passing to scripts |

---

### textarea

Multi-line text input.

```xml
<dict>
    <key>type</key>      <string>textarea</string>
    <key>label</key>     <string>Prompt Template</string>
    <key>variable</key>  <string>prompt_template</string>
    <key>description</key>
    <string>Multi-line template. Use {query} as placeholder.</string>
    <key>config</key>
    <dict>
        <key>default</key>      <string></string>
        <key>required</key>     <false/>
        <key>trim</key>         <true/>
        <key>verticalsize</key> <integer>0</integer>
    </dict>
</dict>
```

| config key | Type | Description |
|---|---|---|
| `default` | string | Initial value |
| `required` | bool | Block workflow if empty |
| `trim` | bool | Strip whitespace |
| `verticalsize` | integer | Height hint (0 = default) |

---

### checkbox

Boolean toggle. Variable value: `"1"` (checked) or `""` (unchecked).

```xml
<dict>
    <key>type</key>      <string>checkbox</string>
    <key>label</key>     <string>Use uv</string>
    <key>variable</key>  <string>use_uv</string>
    <key>description</key>
    <string>When enabled and uv is installed, scripts run via uv run --no-project.</string>
    <key>config</key>
    <dict>
        <key>default</key>  <true/>
        <key>required</key> <false/>
        <key>text</key>     <string>Use uv instead of python3 when available</string>
    </dict>
</dict>
```

| config key | Type | Description |
|---|---|---|
| `default` | bool | `<true/>` or `<false/>` |
| `required` | bool | (rarely used for checkboxes) |
| `text` | string | Inline label shown next to the checkbox |

In scripts, test with `[ "${use_uv:-0}" = "1" ]` (shell) or `os.environ.get("use_uv") == "1"` (Python).

---

### popupbutton

Drop-down menu. Variable value is the selected `value` string from the chosen pair.

```xml
<dict>
    <key>type</key>      <string>popupbutton</string>
    <key>label</key>     <string>Mode</string>
    <key>variable</key>  <string>mode</string>
    <key>description</key>
    <string>Select operating mode.</string>
    <key>config</key>
    <dict>
        <key>default</key> <string>fast</string>
        <key>pairs</key>
        <array>
            <dict>
                <key>label</key> <string>Fast</string>
                <key>value</key> <string>fast</string>
            </dict>
            <dict>
                <key>label</key> <string>Accurate</string>
                <key>value</key> <string>accurate</string>
            </dict>
        </array>
    </dict>
</dict>
```

| config key | Type | Description |
|---|---|---|
| `default` | string | Must match one of the `value` strings in `pairs` |
| `pairs` | array of dicts | Each dict has `label` (display) and `value` (variable value) |

---

### filepicker

File or folder path picker. Variable value is the selected absolute path.

```xml
<dict>
    <key>type</key>      <string>filepicker</string>
    <key>label</key>     <string>Output Folder</string>
    <key>variable</key>  <string>output_dir</string>
    <key>description</key>
    <string>Folder where results are saved.</string>
    <key>config</key>
    <dict>
        <key>default</key>      <string></string>
        <key>placeholder</key>  <string>Choose a folder…</string>
        <key>required</key>     <false/>
        <key>filtermode</key>   <integer>0</integer>
    </dict>
</dict>
```

| config key | Type | Description |
|---|---|---|
| `default` | string | Default path (usually empty) |
| `placeholder` | string | Ghost text when no path selected |
| `required` | bool | Block workflow if no path selected |
| `filtermode` | integer | `0` = files and folders, `1` = files only, `2` = folders only |

---

### slider

Numeric range picker. Variable value is an integer string.

```xml
<dict>
    <key>type</key>      <string>slider</string>
    <key>label</key>     <string>Result Count</string>
    <key>variable</key>  <string>result_count</string>
    <key>description</key>
    <string>Maximum number of results to show.</string>
    <key>config</key>
    <dict>
        <key>defaultvalue</key>      <integer>5</integer>
        <key>minvalue</key>          <integer>1</integer>
        <key>maxvalue</key>          <integer>20</integer>
        <key>markercount</key>       <integer>4</integer>
        <key>showmarkers</key>       <true/>
        <key>onlystoponmarkers</key> <false/>
    </dict>
</dict>
```

| config key | Type | Description |
|---|---|---|
| `defaultvalue` | integer | Initial position |
| `minvalue` | integer | Minimum value |
| `maxvalue` | integer | Maximum value |
| `markercount` | integer | Number of tick marks shown on the slider |
| `showmarkers` | bool | Show tick marks |
| `onlystoponmarkers` | bool | Snap to tick positions only |

Value is passed as an integer string: `os.environ.get("result_count", "5")` → `"5"`.

---

## This project's configuration

| Variable | Type | Default | Description |
|---|---|---|---|
| `use_uv` | checkbox | `true` | Use `uv run --no-project` when uv is installed |

## References

- [Alfred docs — Workflow Configuration](https://www.alfredapp.com/help/workflows/advanced/variables/#user-configuration)
