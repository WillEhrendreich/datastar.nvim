-- datastar.nvim — Datastar completions, highlighting, and hover for Neovim
-- Entry point: require("datastar").setup(opts)

local completion = require("datastar.completion")
local data = require("datastar.data")

local M = {}
M._configured = false

local defaults = {
  filetypes = nil, -- nil = use data.filetypes
  completion = true,
  hover = true,
}

--- Omnifunc implementation for Neovim's completefunc/omnifunc
--- @param findstart number 1 = find start col, 0 = return matches
--- @param base string partial text (only used when findstart=0)
--- @return number|table
function M.omnifunc(findstart, base)
  if findstart == 1 then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local ctx = completion.detect_context(line, col)
    if not ctx then return -3 end
    -- Find the start of the completion
    if ctx.kind == "ATTRIBUTE_NAME" then
      return col - #(ctx.partial or "")  - #"data-"
    elseif ctx.kind == "KEY" then
      -- Start after the colon
      return col - #(ctx.partial or "")
    elseif ctx.kind == "MODIFIER" then
      return col - #(ctx.partial or "")
    elseif ctx.kind == "MODIFIER_ARG" then
      return col - #(ctx.partial or "")
    elseif ctx.kind == "VALUE" then
      return col - #(ctx.partial or "")
    end
    return -3
  else
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return completion.omnifunc_items(line, col)
  end
end

--- Show hover documentation for the Datastar attribute under cursor
function M.hover()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- Extract the attribute name under/before cursor
  local before = line:sub(1, col + 1)
  local attr_name = before:match("data%-([%w%-]+)")
  if not attr_name then return end

  -- Strip key/modifier suffixes to get base plugin name
  local plugin_name = attr_name:match("^([%w%-]+)")
  local plugin = data.plugins[plugin_name]
  if not plugin then return end

  local lines = {
    "# data-" .. plugin_name,
    "",
    plugin.description,
    "",
    "[Documentation](" .. plugin.doc_url .. ")",
  }

  -- Add modifier info
  if plugin.modifiers and #plugin.modifiers > 0 then
    lines[#lines + 1] = ""
    lines[#lines + 1] = "## Modifiers"
    for _, mod in ipairs(plugin.modifiers) do
      local mod_line = "- `__" .. mod.name .. "`"
      if mod.args and #mod.args > 0 then
        mod_line = mod_line .. " (" .. table.concat(mod.args, ", ") .. ")"
      end
      lines[#lines + 1] = mod_line
    end
  end

  vim.lsp.util.open_floating_preview(lines, "markdown", {
    focus_id = "datastar-hover",
    border = "rounded",
  })
end

--- Setup the plugin
--- @param opts table|nil configuration options
function M.setup(opts)
  if M._configured then return end
  M._configured = true

  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  local ft_list = opts.filetypes or data.filetypes

  -- Register omnifunc for target filetypes
  if opts.completion then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft_list,
      group = vim.api.nvim_create_augroup("DatastarCompletion", { clear = true }),
      callback = function(ev)
        vim.bo[ev.buf].omnifunc = "v:lua.require'datastar'.omnifunc"
      end,
    })
  end

  -- Register hover keymap
  if opts.hover then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft_list,
      group = vim.api.nvim_create_augroup("DatastarHover", { clear = true }),
      callback = function()
        vim.keymap.set("n", "<leader>dh", M.hover, {
          buffer = true,
          desc = "Datastar hover docs",
        })
      end,
    })
  end

  -- Register nvim-cmp source if available
  local ok_cmp, cmp = pcall(require, "cmp")
  if ok_cmp then
    local cmp_source = require("datastar.cmp_source")
    cmp.register_source("datastar", cmp_source.new())
  end

  -- Register blink.cmp source if available
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink and blink.register_source then
    local cmp_source = require("datastar.cmp_source")
    blink.register_source("datastar", cmp_source.new())
  end
end

return M
