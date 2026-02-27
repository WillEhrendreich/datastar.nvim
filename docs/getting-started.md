# Getting Started

Welcome to **datastar-lsp.nvim** — IDE-quality Datastar support for Neovim.

## What is Datastar?

[Datastar](https://data-star.dev) is a hypermedia framework that brings reactivity to HTML using `data-*` attributes. Instead of writing JavaScript components, you declare behavior directly in your markup:

```html
<div data-signals:count="0">
  <button data-on:click="$count++">+1</button>
  <span data-text="$count"></span>
</div>
```

This plugin gives you completions, hover docs, diagnostics, and navigation for all Datastar attributes — right inside Neovim.

## Requirements

- **Neovim ≥ 0.9** (0.10+ recommended)
- **Treesitter HTML parser**: `TSInstall html`

Optional (for enhanced completions):
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) or [blink.cmp](https://github.com/Saghen/blink.cmp)

## Installation

### lazy.nvim (recommended)

```lua
{
  "WillEhrendreich/datastar-lsp.nvim",
  ft = "html",
  opts = {},
}
```

That's it. The plugin activates automatically for HTML files.

### packer.nvim

```lua
use {
  "WillEhrendreich/datastar-lsp.nvim",
  config = function()
    require("datastar").setup()
  end,
  ft = "html",
}
```

### Manual

Clone to your Neovim packages directory:

```bash
git clone https://github.com/WillEhrendreich/datastar-lsp.nvim \
  ~/.local/share/nvim/site/pack/plugins/start/datastar-lsp.nvim
```

Add to your `init.lua`:

```lua
require("datastar").setup()
```

## Verify Installation

Run `:checkhealth datastar` — you should see all green checks:

```
datastar: health#datastar#check
========================================
- OK Neovim version: 0.10.x
- OK Treesitter HTML parser installed
- OK Plugin configured successfully
- OK Datastar schema loaded: 31 plugins
- OK Completion engine: omnifunc registered
```

## Your First Completions

1. Open any `.html` file
2. Type `data-` inside an HTML tag
3. A completion menu appears with all Datastar attributes
4. Select one and keep typing — modifiers, keys, and values all complete contextually

## What's Next?

- [Completions Guide](completions.md) — all 5 completion contexts explained
- [Diagnostics](diagnostics.md) — real-time error detection
- [Navigation](navigation.md) — goto definition, signal graph
- [Configuration](configuration.md) — all options
- [Integrations](integrations.md) — nvim-cmp, blink.cmp setup
