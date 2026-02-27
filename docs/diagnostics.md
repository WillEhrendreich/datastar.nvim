# Diagnostics

datastar.nvim checks your Datastar attributes for common mistakes and shows inline warnings as you type.

## How It Works

Diagnostics run automatically on `TextChanged` and `InsertLeave` events in HTML buffers. Errors appear as virtual text annotations and in the Neovim diagnostics list (`:lua vim.diagnostic.setloclist()`).

## What's Detected

### Duplicate Modifiers

Using the same modifier twice on one attribute:

```html
<!-- ⚠ Duplicate modifier: debounce -->
<div data-on:click__debounce.500ms__debounce.1s="@get('/api')"></div>
```

### Conflicting Modifiers

Using modifiers that contradict each other:

```html
<!-- ⚠ Conflicting modifiers: smooth, instant -->
<div data-scroll-into-view__smooth__instant></div>
```

Known conflict groups:
- `smooth` ↔ `instant` ↔ `auto` (scroll behavior)
- `hstart` ↔ `hcenter` ↔ `hend` ↔ `hnearest` (horizontal alignment)
- `vstart` ↔ `vcenter` ↔ `vend` ↔ `vnearest` (vertical alignment)

### Unknown Modifiers

Using a modifier that doesn't exist for the plugin:

```html
<!-- ⚠ Unknown modifier 'foo' for data-on -->
<div data-on:click__foo="$count++"></div>
```

### Expression Syntax Errors

Unclosed brackets, parentheses, or template literals:

```html
<!-- ⚠ Unclosed '(' — expected matching ')' -->
<div data-text="$name + (unclosed"></div>

<!-- ⚠ Unclosed '[' — expected matching ']' -->
<div data-text="$items[0"></div>
```

### Empty Expressions

Attributes that require a value but have none:

```html
<!-- ⚠ Empty expression for data-text -->
<div data-text=""></div>
```

## Configuration

Diagnostics are enabled by default. To disable:

```lua
require("datastar").setup({
  diagnostics = false,
})
```

## Diagnostic Severity

| Issue | Severity |
|-------|----------|
| Empty expression | Error |
| Unclosed delimiter | Error |
| Unknown modifier | Warning |
| Duplicate modifier | Warning |
| Conflicting modifiers | Warning |
