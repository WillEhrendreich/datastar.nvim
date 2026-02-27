# Completion Engine Integrations

datastar.nvim works with three completion engines. The built-in omnifunc requires zero configuration. For nvim-cmp or blink.cmp, add one line to your config.

## Built-in Omnifunc (zero config)

Works out of the box. Press `<C-x><C-o>` in insert mode to trigger Datastar completions.

The plugin automatically sets `omnifunc` for HTML buffers when you call `setup()`.

## nvim-cmp

Add `"datastar"` to your nvim-cmp sources:

```lua
-- In your nvim-cmp config
local cmp = require("cmp")
cmp.setup({
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "datastar" },  -- ← add this
    { name = "luasnip" },
  }),
})
```

The plugin registers itself as an nvim-cmp source automatically during `setup()`. Completions appear as you type in HTML files.

## blink.cmp

Add a provider in your blink.cmp config:

```lua
-- In your blink.cmp config (lazy.nvim example)
{
  "Saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "datastar" },
      providers = {
        datastar = {
          name = "datastar",
          module = "datastar.cmp_source",
          score_offset = 100,  -- prioritize Datastar completions
        },
      },
    },
  },
}
```

## Completion Item Details

All completion items include:
- **Label**: the completion text (e.g., `data-signals`, `__debounce`)
- **Kind**: LSP-compatible kind (Snippet, Property, Event, etc.)
- **Detail**: short description
- **Documentation**: full description with links to official docs
- **Sort text**: items are sorted by relevance, not alphabetically

## Tips

- **Signal completions** (`$name`) come from scanning the current buffer for `data-signals:*` definitions
- **Event properties** (`evt.*`) are narrowed to the specific event type — `keydown` shows `KeyboardEvent` properties, `click` shows `MouseEvent` properties
- **Action completions** (`@get`, `@post`, etc.) appear when you type `@` inside an expression
