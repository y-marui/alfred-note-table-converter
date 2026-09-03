# Alfred Workflow Object Schema (Reverse-Engineered)

Alfred does not publish an official schema for the objects inside a
workflow's `info.plist` — not for Script Filter, not for Keyword, not for
Universal Action Trigger, not for anything. The [Alfred help
pages](https://www.alfredapp.com/help/workflows/) only document the GUI;
the raw plist format is undocumented and has to be learned by building an
object in Alfred and inspecting what it writes. This file records that
knowledge so it doesn't have to be rediscovered per project.

There is no official builder to point at for hand-authoring `info.plist` —
it has to be edited directly, using this reference.

## How this reference was generated

1. In Alfred Preferences → Workflows, create a blank workflow and add one
   of every object from each category in the `+` menu (Triggers, Inputs,
   Outputs, Actions, Utilities, User Interface, Automation). Leave every
   field at its default — the goal is the object's config *keys*, not
   meaningful values.
2. Right-click the workflow → **Export Workflow…**.
3. Unzip the `.alfredworkflow` (it's a zip archive) and read its
   `info.plist` (e.g. `plutil -convert xml1 -o pretty.plist info.plist`,
   or `plistlib.load()` in Python).

Every type below shows the exact `<dict>` for that object taken from
exactly such an export (uids replaced with `…`; array/dict item uids
redacted the same way) — not a hand-typed approximation. If a config
key's meaning here turns out to be wrong, or Alfred has added/renamed
keys since, redo the export and inspect the real plist directly — that
always out-ranks any prose description below, including this one. A key
that's present with an empty/zero value was explicitly serialized by
Alfred; a key that's *entirely absent* means Alfred only writes it once
the corresponding field has actually been touched (see `keyword` on
Script Filter and `name` on Universal Action Trigger below for concrete
examples of that distinction).

## General structure

Every workflow's `info.plist` is a dict with (at minimum):

- `objects` — an array of objects, each `{config: {...}, type: "alfred.workflow.…", uid: "<UUID>", version: <int>}`. Order in the array is cosmetic only; Alfred re-sorts it on every save. Never rely on array position — always match by `uid`.
- `connections` — a dict keyed by a source object's `uid`, each value an array of `{destinationuid, modifiers, modifiersubtext, vitoclose}` (one entry per outgoing wire, `modifiers` distinguishing plain vs. modifier-key connections).
- `uidata` — a dict keyed by `uid`, each value `{xpos, ypos}`: purely the canvas layout, never functional.
- `bundleid`, `name`, `description`, `createdby`, `webaddress`, `readme`, `version`, `disabled`, `userconfigurationconfig`, `variablesdontexport` — workflow-level metadata, not object-level.

A `uid` is a stable identifier for that object for as long as the workflow exists — reconnecting objects doesn't change it, but deleting and re-adding one does. When hand-authoring a plist, invent your own UUIDs; Alfred accepts any well-formed UUID string.

## Connection graph gotchas

**A source object's connections are not selective by held modifier unless you add a modifier-specific wire.** Each entry in a source uid's `connections` array carries a `modifiers` bitmask (`0` = no modifier / default catch-all). If a source object has only the default (`modifiers: 0`) wire, *every* keypress variant on a result row — plain Enter, ⌘+Enter, ⇧+Enter, etc. — routes through that same single wire to the same `destinationuid`, carrying whatever `arg`/`variables` that keypress's `mods` override set. To route a specific modifier elsewhere, add a second connection entry for that source uid with the modifier's bitmask (standard macOS `NSEvent.ModifierFlags` values: shift `131072`, control `262144`, option/alt `524288`, command `1048576`, fn `8388608`) and a distinct `destinationuid` — including a self-loop back to the same node it originated from, which is a valid way to re-enter e.g. a Script Filter's `run` on a specific modifier to redo an action with different variables. **Caveat:** the modifier bitmask values above are standard macOS constants, not independently confirmed against a real Alfred export the way the rest of this file's content is (see "How this reference was generated") — if anyone verifies (or refutes) them against an actual exported plist, please correct this entry and remove this caveat.

**Variables set by an Arguments and Variables node (or any node) are only in scope for connections that actually pass through it.** A self-loop or alternate-modifier connection from a downstream node back to an upstream one bypasses any node that doesn't sit on that specific wire — including one that set a variable the downstream node depends on (e.g. `{clipboard}` → `text`). Any variable a re-entrant path needs must be re-set explicitly on that path's own `variables`, not assumed to still be in scope from an earlier hop.

## Object types

Every object type Alfred offers, grouped by its `+` menu category, each
with the UI name Alfred's own help pages use and the real `<dict>` from
the reference export described above.

## Triggers

### `alfred.workflow.trigger.action`

[File Action](https://www.alfredapp.com/help/workflows/triggers/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>acceptsmulti</key><integer>0</integer>
    </dict>
    <key>type</key><string>alfred.workflow.trigger.action</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.trigger.contact`

[Contact Action](https://www.alfredapp.com/help/workflows/triggers/)

```xml
<dict>
    <key>config</key><dict/>
    <key>type</key><string>alfred.workflow.trigger.contact</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.trigger.external`

[External](https://www.alfredapp.com/help/workflows/triggers/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>availableviaurlhandler</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.trigger.external</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.trigger.fallback`

[Fallback Search](https://www.alfredapp.com/help/workflows/triggers/)

```xml
<dict>
    <key>config</key><dict/>
    <key>type</key><string>alfred.workflow.trigger.fallback</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.trigger.hotkey`

[Hotkey](https://www.alfredapp.com/help/workflows/triggers/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>action</key><integer>0</integer>
        <key>argument</key><integer>0</integer>
        <key>focusedappvariable</key><false/>
        <key>focusedappvariablename</key><string></string>
        <key>hotkey</key><integer>0</integer>
        <key>hotmod</key><integer>0</integer>
        <key>leftcursor</key><false/>
        <key>modsmode</key><integer>0</integer>
        <key>relatedAppsMode</key><integer>0</integer>
    </dict>
    <key>type</key><string>alfred.workflow.trigger.hotkey</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>2</integer>
</dict>
```

### `alfred.workflow.trigger.remote`

[Remote (Alfred Remote app)](https://www.alfredapp.com/help/workflows/triggers/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>argumenttype</key><integer>0</integer>
        <key>workflowonly</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.trigger.remote</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.trigger.snippet`

[Snippet](https://www.alfredapp.com/help/workflows/triggers/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>focusedappvariable</key><false/>
        <key>focusedappvariablename</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.trigger.snippet</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.trigger.universalaction`

[Universal Action](https://www.alfredapp.com/help/workflows/triggers/)

Entirely static — no machine-specific state, no registration step baked into the plist. `name` is the label shown in Alfred's Universal Actions list; like `keyword` on Script Filter, it's omitted entirely until it's actually set rather than stored as `""`. `acceptsmulti` (an integer, not a bool) is `0` for "single selection only", `1` to accept multiple selections as an array. `acceptstext`/`acceptsfiles`/`acceptsurls` gate which selection types Alfred offers this action for.

This object **can** be committed to `workflow/info.plist` and works immediately on import — no one-time manual registration in Alfred Preferences is required, contrary to what its name might suggest.

```xml
<dict>
    <key>config</key>
    <dict>
        <key>acceptsfiles</key><true/>
        <key>acceptsmulti</key><integer>0</integer>
        <key>acceptstext</key><true/>
        <key>acceptsurls</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.trigger.universalaction</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

## Inputs

### `alfred.workflow.input.dictionaryfilter`

[Dictionary Lookup](https://www.alfredapp.com/help/workflows/inputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>keyword</key><string></string>
        <key>language</key><string></string>
        <key>showallwords</key><false/>
        <key>subtext</key><string></string>
        <key>title</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.input.dictionaryfilter</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.input.filefilter`

[File Filter](https://www.alfredapp.com/help/workflows/inputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>anchorfields</key><true/>
        <key>argumenttrimmode</key><integer>0</integer>
        <key>argumenttype</key><integer>0</integer>
        <key>daterange</key><integer>0</integer>
        <key>fields</key>
        <array>
            <dict>
                <key>field</key><string>kMDItemDisplayName</string>
                <key>not</key><false/>
                <key>split</key><true/>
                <key>value</key><string>{query}</string>
                <key>words</key><true/>
            </dict>
            <dict>
                <key>field</key><string>kMDItemAlternateNames</string>
                <key>not</key><false/>
                <key>split</key><true/>
                <key>value</key><string>{query}</string>
                <key>words</key><true/>
            </dict>
            <dict>
                <key>field</key><string>kMDItemFinderComment</string>
                <key>not</key><false/>
                <key>split</key><true/>
                <key>value</key><string>{query}</string>
                <key>words</key><true/>
            </dict>
        </array>
        <key>includesystem</key><false/>
        <key>limit</key><integer>0</integer>
        <key>runningsubtext</key><string></string>
        <key>scopes</key><array/>
        <key>sortmode</key><integer>0</integer>
        <key>subtext</key><string></string>
        <key>title</key><string></string>
        <key>types</key><array/>
        <key>withspace</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.input.filefilter</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>2</integer>
</dict>
```

### `alfred.workflow.input.keyword`

[Keyword](https://www.alfredapp.com/help/workflows/inputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>argumenttype</key><integer>0</integer>
        <key>subtext</key><string></string>
        <key>text</key><string></string>
        <key>withspace</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.input.keyword</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.input.listfilter`

[List Filter](https://www.alfredapp.com/help/workflows/inputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>argumenttrimmode</key><integer>0</integer>
        <key>argumenttype</key><integer>0</integer>
        <key>fixedorder</key><false/>
        <key>items</key><string></string>
        <key>matchmode</key><integer>0</integer>
        <key>runningsubtext</key><string></string>
        <key>subtext</key><string></string>
        <key>title</key><string></string>
        <key>withspace</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.input.listfilter</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.input.runningappsfilter`

[Running Apps Filter](https://www.alfredapp.com/help/workflows/inputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>argumenttype</key><integer>0</integer>
        <key>keyword</key><string></string>
        <key>outputprefix</key><string></string>
        <key>outputtype</key><integer>0</integer>
        <key>subtext</key><string></string>
        <key>title</key><string></string>
        <key>withspace</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.input.runningappsfilter</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.input.scriptfilter`

[Script Filter](https://www.alfredapp.com/help/workflows/inputs/)

`keyword` is only present once a keyword is actually typed into the node's UI — a keyword-less node driven only by an incoming connection (e.g. from a Universal Action Trigger) omits the key entirely rather than storing it as `""`. `alfredfiltersresults` fuzzy-filters returned items' `title`/`match` against the incoming query before displaying them — set it `false` on a keyword-less node whose incoming query is arbitrary input rather than something meant to fuzzy-match static item titles, or every item gets silently filtered away when the query never matches a title. `alfredfiltersresultsmatchmode`, `queuemode`, `queuedelaymode`, `queuedelaycustom`, and `queuedelayimmediatelyinitially` control Alfred 5.5+'s keystroke-queueing behavior for slow scripts. `title`/`subtext` are the static label/placeholder shown before the script runs, distinct from any individual result item's own `title`/`subtitle`; `runningsubtext` is shown while the script executes (e.g. "Reading the clipboard…"). `script`/`scriptargtype` are the command line run and whether `$1`/`argv` or `{query}` substitution is used.

**Gotcha**: a chain of two keyword-less Script Filter nodes — a chooser that lists options and an executor that runs the chosen one — can look identical on the canvas; both display as unlabelled-looking boxes with the same workflow title. Wiring a trigger directly to the *executor* instead of the *chooser* skips the selection step entirely: the raw upstream argument arrives at the executor, matches none of its recognized options, and every input falls through to an unhandled/fallback branch. Identify the correct target by `subtext` (each node's placeholder text differs even when `title` doesn't), not by title alone.

```xml
<dict>
    <key>config</key>
    <dict>
        <key>alfredfiltersresults</key><false/>
        <key>alfredfiltersresultsmatchmode</key><integer>0</integer>
        <key>argumenttreatemptyqueryasnil</key><true/>
        <key>argumenttrimmode</key><integer>0</integer>
        <key>argumenttype</key><integer>0</integer>
        <key>escaping</key><integer>127</integer>
        <key>queuedelaycustom</key><integer>3</integer>
        <key>queuedelayimmediatelyinitially</key><true/>
        <key>queuedelaymode</key><integer>0</integer>
        <key>queuemode</key><integer>1</integer>
        <key>runningsubtext</key><string></string>
        <key>script</key><string></string>
        <key>scriptargtype</key><integer>1</integer>
        <key>scriptfile</key><string></string>
        <key>subtext</key><string></string>
        <key>title</key><string></string>
        <key>type</key><integer>11</integer>
        <key>withspace</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.input.scriptfilter</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>3</integer>
</dict>
```

## Outputs

### `alfred.workflow.output.callexternaltrigger`

[Call External Trigger](https://www.alfredapp.com/help/workflows/outputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>externaltriggerid</key><string></string>
        <key>passinputasargument</key><true/>
        <key>passvariables</key><true/>
        <key>workflowbundleid</key><string>self</string>
    </dict>
    <key>type</key><string>alfred.workflow.output.callexternaltrigger</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.output.clipboard`

[Copy to Clipboard](https://www.alfredapp.com/help/workflows/outputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>autopaste</key><false/>
        <key>clipboardtext</key><string>{query}</string>
        <key>ignoredynamicplaceholders</key><false/>
        <key>transient</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.output.clipboard</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>3</integer>
</dict>
```

### `alfred.workflow.output.dispatchkeycombo`

[Dispatch Key Combo](https://www.alfredapp.com/help/workflows/outputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>count</key><integer>1</integer>
        <key>keychar</key><string></string>
        <key>keycode</key><integer>-1</integer>
        <key>keymod</key><integer>0</integer>
        <key>overridewithargument</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.output.dispatchkeycombo</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.output.largetype`

[Large Type](https://www.alfredapp.com/help/workflows/outputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>alignment</key><integer>0</integer>
        <key>backgroundcolor</key><string></string>
        <key>fadespeed</key><integer>0</integer>
        <key>fillmode</key><integer>0</integer>
        <key>font</key><string></string>
        <key>ignoredynamicplaceholders</key><false/>
        <key>largetypetext</key><string>{query}</string>
        <key>textcolor</key><string></string>
        <key>wrapat</key><integer>50</integer>
    </dict>
    <key>type</key><string>alfred.workflow.output.largetype</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>3</integer>
</dict>
```

### `alfred.workflow.output.notification`

[Post Notification](https://www.alfredapp.com/help/workflows/outputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>lastpathcomponent</key><false/>
        <key>onlyshowifquerypopulated</key><false/>
        <key>removeextension</key><false/>
        <key>text</key><string></string>
        <key>title</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.output.notification</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.output.playsound`

[Play Sound](https://www.alfredapp.com/help/workflows/outputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>soundname</key><string>Hero</string>
        <key>systemsound</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.output.playsound</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.output.speak`

[Speak](https://www.alfredapp.com/help/workflows/outputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>text</key><string></string>
        <key>usevoiceover</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.output.speak</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.output.writefile`

[Write File](https://www.alfredapp.com/help/workflows/outputs/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>adduuid</key><false/>
        <key>allowemptyfiles</key><true/>
        <key>createintermediatefolders</key><false/>
        <key>filename</key><string></string>
        <key>filetext</key><string>{query}</string>
        <key>ignoredynamicplaceholders</key><false/>
        <key>relativepathmode</key><integer>0</integer>
        <key>type</key><integer>1</integer>
    </dict>
    <key>type</key><string>alfred.workflow.output.writefile</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

## Actions

### `alfred.workflow.action.actioninalfred`

[Action in Alfred](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>path</key><string></string>
        <key>type</key><integer>100</integer>
    </dict>
    <key>type</key><string>alfred.workflow.action.actioninalfred</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.applescript`

[Run NSAppleScript](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>applescript</key><string>on alfred_script(q)
  -- your script here
end alfred_script</string>
        <key>cachescript</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.action.applescript</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.browseinalfred`

[Browse in Alfred](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>path</key><string></string>
        <key>sortBy</key><integer>0</integer>
        <key>sortDirection</key><integer>0</integer>
        <key>sortFoldersAtTop</key><false/>
        <key>sortOverride</key><false/>
        <key>stackBrowserView</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.action.browseinalfred</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.browseinterminal`

[Browse in Terminal](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>path</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.action.browseinterminal</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.buffer`

[File Buffer](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>addfilestobuffer</key><false/>
        <key>clearbuffer</key><false/>
        <key>outputtype</key><integer>0</integer>
    </dict>
    <key>type</key><string>alfred.workflow.action.buffer</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.itunescommand`

[Music Command](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>command</key><integer>0</integer>
    </dict>
    <key>type</key><string>alfred.workflow.action.itunescommand</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.launchfiles`

[Launch Apps / Files](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>paths</key><array/>
        <key>toggle</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.action.launchfiles</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.openfile`

[Open File](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>openwith</key><string></string>
        <key>sourcefile</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.action.openfile</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>3</integer>
</dict>
```

### `alfred.workflow.action.openurl`

[Open URL](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>browser</key><string></string>
        <key>skipqueryencode</key><false/>
        <key>skipvarencode</key><false/>
        <key>spaces</key><string></string>
        <key>url</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.action.openurl</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.revealfile`

[Reveal File in Finder](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>path</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.action.revealfile</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.script`

[Run Script](https://www.alfredapp.com/help/workflows/actions/)

A plain "Run Script" step with no result list of its own.

```xml
<dict>
    <key>config</key>
    <dict>
        <key>concurrently</key><false/>
        <key>escaping</key><integer>127</integer>
        <key>script</key><string></string>
        <key>scriptargtype</key><integer>1</integer>
        <key>scriptfile</key><string></string>
        <key>type</key><integer>11</integer>
    </dict>
    <key>type</key><string>alfred.workflow.action.script</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>2</integer>
</dict>
```

### `alfred.workflow.action.systemcommand`

[System Command](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>command</key><integer>0</integer>
        <key>confirm</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.action.systemcommand</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>2</integer>
</dict>
```

### `alfred.workflow.action.systemwebsearch`

[Default Web Search](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>browser</key><string></string>
        <key>searcher</key><integer>1635215215</integer>
    </dict>
    <key>type</key><string>alfred.workflow.action.systemwebsearch</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.action.terminalcommand`

[Terminal Command](https://www.alfredapp.com/help/workflows/actions/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>escaping</key><integer>0</integer>
        <key>script</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.action.terminalcommand</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

## Utilities

### `alfred.workflow.utility.argument`

[Arguments and Variables](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>argument</key><string>{query}</string>
        <key>passthroughargument</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.utility.argument</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.conditional`

[Conditional](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>conditions</key>
        <array>
            <dict>
                <key>inputstring</key><string></string>
                <key>matchcasesensitive</key><false/>
                <key>matchmode</key><integer>0</integer>
                <key>matchstring</key><string></string>
                <key>outputlabel</key><string></string>
                <key>uid</key><string>…</string>
            </dict>
        </array>
        <key>elselabel</key><string>else</string>
        <key>hideelse</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.utility.conditional</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.debug`

[Debug](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>argument</key><string>'{query}', {variables}</string>
        <key>cleardebuggertext</key><false/>
        <key>processoutputs</key><true/>
    </dict>
    <key>type</key><string>alfred.workflow.utility.debug</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.delay`

[Delay](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>seconds</key><string>1</string>
    </dict>
    <key>type</key><string>alfred.workflow.utility.delay</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.dialog`

[Dialog Conditional](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>button1</key><string>Ok</string>
        <key>button2</key><string>Cancel</string>
        <key>button3</key><string></string>
        <key>description</key><string></string>
        <key>title</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.utility.dialog</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.expression`

[Expression](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>expression</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.utility.expression</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.file`

[File Conditional](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>fileutivariablename</key><string></string>
        <key>outputfileuti</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.utility.file</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.filter`

[Filter (legacy)](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>inputstring</key><string></string>
        <key>matchcasesensitive</key><true/>
        <key>matchmode</key><integer>0</integer>
        <key>matchstring</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.utility.filter</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.hidealfred`

[Hide Alfred](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>unstackview</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.utility.hidealfred</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.joinargs`

[Join Args](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>delimiter</key><string>
</string>
    </dict>
    <key>type</key><string>alfred.workflow.utility.joinargs</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.json`

[JSON Configuration](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>json</key><string>{
  "alfredworkflow" : {
    "arg" : "{query}",
    "config" : {
    },
    "variables" : {
    }
  }
}</string>
    </dict>
    <key>type</key><string>alfred.workflow.utility.json</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.junction`

[Junction](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key><dict/>
    <key>type</key><string>alfred.workflow.utility.junction</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.random`

[Random](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>type</key><integer>0</integer>
    </dict>
    <key>type</key><string>alfred.workflow.utility.random</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.replace`

[Replace](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>matchmode</key><integer>0</integer>
        <key>matchstring</key><string></string>
        <key>replacestring</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.utility.replace</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>2</integer>
</dict>
```

### `alfred.workflow.utility.showalfred`

[Show Alfred](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>argument</key><string></string>
        <key>leftcursor</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.utility.showalfred</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.split`

[Split Arg](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>delimiter</key><string>,</string>
        <key>discardemptyarguments</key><false/>
        <key>outputas</key><integer>0</integer>
        <key>trimarguments</key><true/>
        <key>variableprefix</key><string>split</string>
    </dict>
    <key>type</key><string>alfred.workflow.utility.split</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.utility.transform`

[Transform](https://www.alfredapp.com/help/workflows/utilities/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>type</key><integer>0</integer>
    </dict>
    <key>type</key><string>alfred.workflow.utility.transform</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

## User Interface

### `alfred.workflow.userinterface.grid`

[Grid View](https://www.alfredapp.com/help/workflows/user-interface/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>columncount</key><integer>4</integer>
        <key>filterable</key><true/>
        <key>fixedorder</key><false/>
        <key>imageaspect</key><integer>0</integer>
        <key>inputfile</key><string></string>
        <key>inputtype</key><integer>0</integer>
        <key>loadingtext</key><string></string>
        <key>showsubtitles</key><true/>
        <key>showtitles</key><true/>
        <key>subtitlesinfooter</key><false/>
        <key>titlesinfooter</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.userinterface.grid</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.userinterface.image`

[Image View](https://www.alfredapp.com/help/workflows/user-interface/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>imageresizemode</key><integer>0</integer>
        <key>stackview</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.userinterface.image</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.userinterface.pdf`

[PDF View](https://www.alfredapp.com/help/workflows/user-interface/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>displaymode</key><integer>0</integer>
        <key>stackview</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.userinterface.pdf</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.userinterface.text`

[Text View](https://www.alfredapp.com/help/workflows/user-interface/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>behaviour</key><integer>0</integer>
        <key>fontmode</key><integer>0</integer>
        <key>fontsizing</key><integer>0</integer>
        <key>footertext</key><string></string>
        <key>inputfile</key><string></string>
        <key>inputtype</key><integer>0</integer>
        <key>loadingtext</key><string></string>
        <key>outputmode</key><integer>0</integer>
        <key>scriptinput</key><integer>0</integer>
        <key>spellchecking</key><integer>0</integer>
        <key>stackview</key><false/>
    </dict>
    <key>type</key><string>alfred.workflow.userinterface.text</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

## Automation

### `alfred.workflow.automation.runshortcut`

[Run Shortcut](https://www.alfredapp.com/help/workflows/automations/)

```xml
<dict>
    <key>config</key>
    <dict>
        <key>inputmode</key><integer>-1</integer>
        <key>outputmode</key><integer>0</integer>
        <key>shortcut</key><string></string>
    </dict>
    <key>type</key><string>alfred.workflow.automation.runshortcut</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

### `alfred.workflow.automation.task`

[Automation Task](https://www.alfredapp.com/help/workflows/automations/)

```xml
<dict>
    <key>config</key><dict/>
    <key>type</key><string>alfred.workflow.automation.task</string>
    <key>uid</key><string>…</string>
    <key>version</key><integer>1</integer>
</dict>
```

## Provenance

The prose (general structure, gotchas) originates from
[`alfred-clean-invisible-text#22`](https://github.com/y-marui/alfred-clean-invisible-text/pull/22),
generalized to remove project-specific references. The per-type `<dict>`
examples were regenerated from a real Alfred export covering every object
type (2026-09-02), replacing hand-typed approximations with source taken
directly from Alfred's own output. The connection graph gotchas were added
after bugs found while working on
[`alfred-clean-invisible-text#31`](https://github.com/y-marui/alfred-clean-invisible-text/issues/31)/[`#32`](https://github.com/y-marui/alfred-clean-invisible-text/issues/32).
Corrections belong here, not back in the originating project.
