# datastar-lsp.nvim

IDE-quality [Datastar](https://data-star.dev) completions, hover docs, and syntax highlighting for Neovim.

## Features

- **Completions** for all 27 Datastar attribute plugins (`data-on`, `data-signals`, `data-show`, etc.)
- **Key completions** — DOM events for `data-on:`, HTML attributes for `data-attr:`, etc.
- **Modifier completions** — `__debounce`, `__once`, `__capture` with valid args
- **Action completions** — `@get()`, `@post()`, `@peek()`, etc. inside attribute values
- **Hover documentation** — description + link to official docs
- **Treesitter highlighting** — semantic coloring for `data-*` attributes
- **Zero-config** — works with native omnifunc out of the box
- **Completion engine support** — nvim-cmp, blink.cmp, and native omnifunc

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
  -- Override filetypes (default: html, htmldjango, php, templ, vue, svelte, astro, ...)
  filetypes = nil,
  -- Enable completion (default: true)
  completion = true,
  -- Enable hover docs (default: true)
  hover = true,
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

Auto-detected. Add `"datastar"` to your providers:

```lua
require("blink.cmp").setup({
  sources = {
    providers = {
      datastar = {
        name = "datastar",
        module = "datastar.cmp_source",
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

## Health Check

```vim
:checkhealth datastar
```

## License

MIT
