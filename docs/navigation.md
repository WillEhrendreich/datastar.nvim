# Navigation

datastar-lsp.nvim provides signal-aware navigation: jump to where signals are defined and visualize how they depend on each other.

## Goto Definition (`gd`)

Place your cursor on a `$signal` reference and press `gd` — the cursor jumps to where that signal was defined with `data-signals`.

```html
<!-- Line 5: definition -->
<div data-signals:userName="'Will'"></div>

<!-- Line 18: usage — press gd on $userName -->
<span data-text="$userName"></span>
<!-- ↑ jumps to line 5 -->
```

This works for signals defined anywhere in the current buffer via:
- `data-signals:name="..."`
- `data-computed:name="..."`
- `data-bind:name`
- `data-ref:name`
- `data-indicator:name`

### How it works

The plugin scans the buffer for all `data-signals:*`, `data-computed:*`, `data-bind:*`, `data-ref:*`, and `data-indicator:*` attributes, recording their line and column positions. When you press `gd` on a `$signalName`, it finds the matching definition and moves your cursor there.

## Signal Dependency Graph

Run `:DatastarSignalGraph` to see a visualization of all signals and their dependencies in the current buffer.

```
Signal Dependency Graph
═══════════════════════

Computed signals:
  fullName    ← firstName, lastName
  doubleCount ← count
  isAdult     ← age

Leaf signals (no dependencies):
  age, count, firstName, isOpen, lastName, userName
```

This helps you understand the reactive data flow in your page at a glance:
- **Computed signals** show what they depend on (with `←` arrows)
- **Leaf signals** are standalone values with no dependencies

## Cross-File Signal Tracking

The workspace scanner tracks signals across all HTML files in your project. When you open a file, signals from other files in the same directory tree are available for completions.

This means if `header.html` defines:
```html
<div data-signals:theme="'dark'"></div>
```

Then in `page.html`, typing `$` will include `$theme` in the completions — even though it's defined in a different file.

## Keybindings

| Key | Action | Context |
|-----|--------|---------|
| `gd` | Goto signal definition | Cursor on `$signalName` |
| `:DatastarSignalGraph` | Show dependency graph | Any HTML buffer |
