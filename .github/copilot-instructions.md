# datastar.nvim — Copilot Instructions

A pure-Lua Neovim plugin providing IDE-quality support for the [Datastar](https://data-star.dev) hypermedia framework. No LSP server, no Node.js, no external processes — everything is bundled.

## Tests

Tests use [busted](https://lunarmodules.github.io/busted/) and run without Neovim (pure Lua):

```sh
# Full suite
busted tests/

# Single spec file
busted tests/completion_spec.lua

# Single test by name (grep pattern)
busted tests/completion_spec.lua --filter "detects data- prefix"
```

Each test file sets `package.path = "./lua/?.lua;" .. package.path` so `require("datastar.*")` resolves from the repo root — run busted from the repo root.

## Architecture

### Module map

| File | Role |
|------|------|
| `lua/datastar/init.lua` | Entry point. `setup()` registers autocmds, keymaps, cmp source. All Neovim API calls live here. |
| `lua/datastar/data.lua` | Static schema — the source of truth for all 31 Datastar plugins, their modifiers, key types, and snippets. Pure Lua table, no Neovim API. |
| `lua/datastar/completion.lua` | Context parser (`detect_context`) + resolver (`resolve`). Backward-scans from cursor to classify context as `ATTRIBUTE_NAME`, `KEY`, `MODIFIER`, `MODIFIER_ARG`, or `VALUE`. Returns LSP-compatible `CompletionItem` tables. |
| `lua/datastar/cmp_source.lua` | nvim-cmp adapter wrapping `completion`. blink.cmp uses a provider config instead — no runtime registration needed. |
| `lua/datastar/diagnostics.lua` | Line-level validator. Returns `{ lnum, col, message, severity }` tables. Called on `TextChanged`/`InsertLeave`/`BufEnter`. |
| `lua/datastar/workspace.lua` | Cross-file signal scanner. Produces `{ name, file, lnum, col, kind }` for goto-definition across files. |
| `lua/datastar/routes.lua` | Route goto-definition for `@get`/`@post` etc. Matches URLs to Go, F#, Express, ASP.NET, Flask handlers. |
| `lua/datastar/depgraph.lua` | Builds and formats signal dependency graph for `:DatastarSignalGraph`. |
| `lua/datastar/versions.lua` | Semver feature-gating. `version_gte(a, b)` returns `true` when either is nil (no gating). |
| `lua/datastar/examples.lua` | Curated code examples rendered into hover docs. |
| `lua/datastar/health.lua` | `:checkhealth datastar` implementation. |
| `lua/datastar/textobjects.lua` | Text objects for selecting Datastar attribute values. |
| `after/queries/html/highlights.scm` | Treesitter highlight query — captures `data-*` attribute names as `@tag.attribute`. |

### Key data shape — plugin entry in `data.lua`

```lua
plugin_name = {
  description   = string,
  doc_url       = string,
  has_key       = bool,       -- whether data-plugin:KEY syntax is valid
  key_type      = string,     -- "html_attrs" | "signal_name" | "css_class" | "dom_event" | ...
  value_required = bool,
  value_type    = string,     -- "expression" | "signal_name" | "boolean" | ...
  modifiers     = { { name, args? } },
  snippets      = { { trigger, body } },
}
```

`data.lua` is purely static — no Neovim API. Tests that only test data shape or context parsing can run without Neovim.

### Attribute grammar

```
data-[plugin]:[key]__[modifier].[arg]="expression"
```

The context parser in `completion.lua` backward-scans from the cursor to determine which part of this grammar the user is typing.

## Key conventions

- **Neovim API isolation**: only `init.lua` calls `vim.*` APIs. All other modules are pure Lua and testable with busted standalone.
- **Completion items**: always return LSP-compatible tables with at minimum `label`, `kind`, `filterText`, and `documentation` fields.
- **Diagnostics**: `diagnostics.validate_line(line, lnum)` returns 1-based `lnum`; `init.lua` converts to 0-based when calling `vim.diagnostic.set`.
- **Signal locations**: `scan_signals_with_locations` returns 0-based `lnum`; `init.lua` adds 1 when calling `nvim_win_set_cursor`.
- **Hover fallback**: the `K` keymap checks `find_plugin_at_cursor` first; if nil it falls through to the user's existing `K` mapping.
- **`gd` fallback**: same pattern — only intercepts when cursor is on a `$signal`.
- **Version gating**: pass `version = "1.0.0"` to `setup()` to filter features; `nil` means allow all.
- **Supported filetypes**: defined in `workspace.lua`'s `supported_patterns` (html, vue, svelte, astro, templ, etc.); `data.filetypes` drives autocmd registration.
- **Version bump**: use `scripts/bump-version.ps1` (PowerShell).
