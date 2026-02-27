# datastar-lsp.nvim

IDE-quality [Datastar](https://data-star.dev) completions, hover docs, diagnostics, and developer tools for Neovim.

## Features

### Completions
- **Attribute plugins** — all 31 Datastar plugins (`data-on`, `data-signals`, `data-show`, etc.)
- **Key completions** — DOM events for `data-on:`, HTML attributes for `data-attr:`, etc.
- **Modifier completions** — `__debounce`, `__once`, `__capture` with valid args
- **Action completions** — `@get()`, `@post()`, `@peek()`, etc. with fetch option docs
- **Signal completions** — `$signalName` suggestions scanned from the current buffer
- **Event type narrowing** — `evt.` completions narrowed by event type (e.g., `evt.key` for `keydown`, `evt.clientX` for `click`)
- **Snippet expansion** — complete attributes expand to full snippet templates

### Diagnostics
- **Modifier chain validation** — duplicate, conflicting, and invalid modifier detection
- **Expression syntax validation** — unbalanced delimiters, unterminated strings, empty expressions
- **Real-time inline diagnostics** via `vim.diagnostic`

### Navigation
- **Signal goto definition** — `gd` on `$signalName` jumps to defining `data-signals` attribute
- **Route goto definition** — jump from `@get('/api/users')` to matching route handler (Go, F#, Express, ASP.NET, Flask)
- **Cross-file signal tracking** — workspace-wide signal index for multi-file projects

### Documentation
- **Hover docs** — cursor-precise description + modifiers + link to official docs
- **Curated examples** — real-world code snippets in hover for each plugin and modifier
- **Treesitter highlighting** — semantic coloring for `data-*` attributes

### Developer Tools
- **Signal dependency graph** — `:DatastarSignalGraph` visualizes computed signal dependencies
- **Textobjects** — `im`/`am` for modifiers, `ik`/`ak` for keys, modifier navigation
- **Version-aware feature gating** — detects Datastar version and filters completions accordingly

### Integration
- **Zero-config** — works with native omnifunc out of the box
- **Completion engines** — nvim-cmp, blink.cmp, and native omnifunc

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "delaney-data/datastar-lsp.nvim",
  ft = { "html", "htmldjango", "php", "templ", "vue", "svelte", "astro", "eruby", "gohtml" },
  opts = {},
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "delaney-data/datastar-lsp.nvim",
  config = function()
    require("datastar").setup()
  end,
}
```

## Setup

```lua
require("datastar").setup({
  filetypes = nil,      -- Override filetypes (default: html, htmldjango, php, templ, vue, svelte, astro, ...)
  completion = true,    -- Enable completion
  hover = true,         -- Enable hover docs (<leader>dh)
  diagnostics = true,   -- Enable inline diagnostics
  goto_definition = true, -- Enable gd on $signals
  signal_graph = true,  -- Enable :DatastarSignalGraph command
})
```

## Completion Engines

### Native omnifunc

Works automatically after `setup()`. Trigger with `<C-x><C-o>` in insert mode.

### nvim-cmp

Auto-detected. Add `"datastar"` to your sources if you want explicit control:

```lua
require("cmp").setup({
  sources = {
    { name = "datastar" },
    -- ... other sources
  },
})
```

### blink.cmp

Add `"datastar"` as a provider in your blink.cmp config:

```lua
require("blink.cmp").setup({
  sources = {
    default = { "datastar", "lsp", "path", "buffer" },
    providers = {
      datastar = {
        name = "datastar",
        module = "datastar.cmp_source",
        enabled = true,
      },
    },
  },
})
```

## Hover Docs

Press `<leader>dh` in normal mode on any `data-*` attribute to see documentation.

## Datastar Attribute Syntax

```
data-[plugin]:[key]__[modifier].[arg]="expression"
```

| Part | Delimiter | Example |
|------|-----------|---------|
| Plugin | `data-` | `data-on`, `data-signals` |
| Key | `:` | `data-on:click`, `data-attr:class` |
| Modifier | `__` | `data-on:click__debounce` |
| Modifier arg | `.` | `data-on:click__debounce.500ms` |
| Value | `="..."` | `data-on:click="@get('/api')"` |

## Signal Dependency Graph

```vim
:DatastarSignalGraph
```

Opens a split showing signal dependencies (which computed signals depend on which base signals).

## Textobjects

The plugin provides functions for structural editing of modifier chains:

```lua
local to = require("datastar.textobjects")

-- In your config:
vim.keymap.set({"x", "o"}, "im", function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local mod = to.find_modifier_at_col(line, col)
  if mod then
    vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), mod.start_col })
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), mod.end_col - 1 })
  end
end, { desc = "inner modifier" })
```

## Health Check

```vim
:checkhealth datastar
```

## License

MIT
