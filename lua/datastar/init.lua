-- datastar.nvim — Datastar completions, highlighting, and hover for Neovim
-- Entry point: require("datastar").setup(opts)

local completion = require("datastar.completion")
local data = require("datastar.data")
local diagnostics = require("datastar.diagnostics")
local examples = require("datastar.examples")

local M = {}

local defaults = {
  filetypes = nil, -- nil = use data.filetypes
  completion = true,
  hover = true,
  diagnostics = true,
  goto_definition = true,
  signal_graph = true,
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
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local signals = completion.scan_signals(buf_lines)
    return completion.omnifunc_items(line, col, base, signals)
  end
end

--- Show hover documentation for the Datastar attribute under cursor
function M.hover()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- Find the data- attribute whose span contains the cursor
  local plugin_name = completion.find_plugin_at_cursor(line, col)
  if not plugin_name then return end

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

  -- Add curated examples
  local example_md = examples.format_hover_examples(plugin_name)
  if example_md ~= "" then
    lines[#lines + 1] = ""
    lines[#lines + 1] = example_md
  end

  vim.lsp.util.open_floating_preview(lines, "markdown", {
    focus_id = "datastar-hover",
    border = "rounded",
  })
end

--- Go to definition for signal under cursor ($signalName)
function M.goto_definition()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  local signal_name = completion.find_signal_at_cursor(line, col)
  if not signal_name then
    vim.notify("No Datastar signal under cursor", vim.log.levels.INFO)
    return
  end

  -- Search current buffer for signal definition
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local locs = completion.scan_signals_with_locations(buf_lines)

  for _, loc in ipairs(locs) do
    if loc.name == signal_name then
      vim.api.nvim_win_set_cursor(0, { loc.lnum + 1, loc.col })
      return
    end
  end

  -- Try cross-file store if available
  if M._signal_store then
    local defs = M._signal_store:find_definitions(signal_name)
    if #defs > 0 then
      local def = defs[1]
      vim.cmd("edit " .. vim.fn.fnameescape(def.file))
      vim.api.nvim_win_set_cursor(0, { def.lnum, def.col or 0 })
      return
    end
  end

  vim.notify("Definition not found for $" .. signal_name, vim.log.levels.WARN)
end

--- Show signal dependency graph for current buffer
function M.signal_graph()
  local depgraph = require("datastar.depgraph")
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local graph = depgraph.build_graph(buf_lines)
  local text = depgraph.format_graph(graph)

  -- Show in a scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.cmd("split")
  vim.api.nvim_win_set_buf(0, buf)
end

--- Run diagnostics on current buffer
function M.run_diagnostics()
  local buf = vim.api.nvim_get_current_buf()
  local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local ns = vim.api.nvim_create_namespace("datastar_diagnostics")
  vim.diagnostic.reset(ns, buf)

  local diags = {}
  for lnum, line in ipairs(buf_lines) do
    local line_diags = diagnostics.validate_line(line, lnum)
    for _, d in ipairs(line_diags) do
      diags[#diags + 1] = {
        lnum = d.lnum - 1, -- 0-indexed for vim.diagnostic
        col = d.col or 0,
        message = d.message,
        severity = d.severity == "error" and vim.diagnostic.severity.ERROR
          or d.severity == "warning" and vim.diagnostic.severity.WARN
          or vim.diagnostic.severity.INFO,
        source = "datastar",
      }
    end
  end

  vim.diagnostic.set(ns, buf, diags)
end

--- Setup the plugin
--- @param opts table|nil configuration options
function M.setup(opts)
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

  -- Register hover keymap — intercept K on data-* attributes, else fall through
  if opts.hover then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft_list,
      group = vim.api.nvim_create_augroup("DatastarHover", { clear = true }),
      callback = function()
        local prev_K = vim.fn.maparg("K", "n", false, true)
        vim.keymap.set("n", "K", function()
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          if completion.find_plugin_at_cursor(line, col) then
            M.hover()
          elseif prev_K and prev_K.callback then
            prev_K.callback()
          else
            vim.cmd("normal! K")
          end
        end, { buffer = true, desc = "Datastar hover docs / fallback" })
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

  -- blink.cmp uses a provider-based config; no runtime registration needed.
  -- Users add the source to their blink.cmp provider config. See README.

  -- Register diagnostics via FileType (TextChanged/InsertLeave don't match filetype patterns)
  if opts.diagnostics then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft_list,
      group = vim.api.nvim_create_augroup("DatastarDiagnostics", { clear = true }),
      callback = function(ev)
        vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufEnter" }, {
          buffer = ev.buf,
          callback = function()
            M.run_diagnostics()
          end,
        })
        -- Run immediately on filetype detection
        M.run_diagnostics()
      end,
    })
  end

  -- Register goto definition keymap
  if opts.goto_definition then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = ft_list,
      group = vim.api.nvim_create_augroup("DatastarGotoDef", { clear = true }),
      callback = function()
        vim.keymap.set("n", "gd", function()
          -- Only intercept if cursor is on a $signal, else fall through
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          if completion.find_signal_at_cursor(line, col) then
            M.goto_definition()
          else
            -- Fall through to default gd
            vim.cmd("normal! gd")
          end
        end, { buffer = true, desc = "Datastar: go to signal definition" })
      end,
    })
  end

  -- Register signal graph command
  if opts.signal_graph then
    vim.api.nvim_create_user_command("DatastarSignalGraph", function()
      M.signal_graph()
    end, { desc = "Show Datastar signal dependency graph" })
  end

  M._configured = true
end

return M
