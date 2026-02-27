# Configuration

All options are passed to `require("datastar").setup()`. Every option has a sensible default — you can call `setup()` with no arguments and everything works.

## Full Options

```lua
require("datastar").setup({
  -- Enable/disable inline diagnostics
  diagnostics = true,

  -- Enable/disable hover documentation (K key)
  hover = true,

  -- Enable/disable goto definition for $signals (gd key)
  goto_definition = true,

  -- Filetypes to activate on (default: HTML only)
  filetypes = { "html" },

  -- Minimum Datastar version to support
  -- Filters out features added in later versions
  -- nil = no filtering (show everything)
  version = nil,  -- e.g., "0.20.0"
})
```

## Option Details

### `diagnostics`

**Default**: `true`

When enabled, the plugin checks Datastar attributes for:
- Duplicate modifiers
- Conflicting modifiers
- Unknown modifiers
- Expression syntax errors (unclosed brackets)
- Empty expressions

Diagnostics run on `TextChanged` and `InsertLeave`.

### `hover`

**Default**: `true`

When enabled, pressing `K` over a `data-*` attribute shows:
- Plugin description
- Link to official docs
- Available modifiers with descriptions
- Curated code examples

### `goto_definition`

**Default**: `true`

When enabled, pressing `gd` on a `$signalName` jumps to its definition (`data-signals:name`, `data-computed:name`, etc.).

### `filetypes`

**Default**: `{ "html" }`

List of filetypes where the plugin activates. You might extend this for template languages:

```lua
filetypes = { "html", "htmldjango", "eruby", "templ" },
```

### `version`

**Default**: `nil` (all features available)

Set this to filter completions to only features available in a specific Datastar version:

```lua
version = "0.20.0",  -- only show features from v0.20.0 and earlier
```

This is useful if you're targeting a specific Datastar release and don't want to accidentally use newer features.

## Health Check

Run `:checkhealth datastar` to verify your configuration:

```vim
:checkhealth datastar
```

This checks:
- Neovim version compatibility
- Treesitter HTML parser
- Plugin configuration status
- Schema integrity
- Completion engine registration
- Diagnostics setup
- Keymap bindings
