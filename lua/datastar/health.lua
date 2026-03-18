-- datastar health check
-- :checkhealth datastar

local M = {}

function M.check()
  vim.health.start("datastar.nvim")

  -- Check plugin loaded
  local ok, ds = pcall(require, "datastar")
  if ok then
    vim.health.ok("Plugin loaded")
  else
    vim.health.error("Plugin failed to load: " .. tostring(ds))
    return
  end

  -- Check data schema
  local ok_data, data = pcall(require, "datastar.data")
  if ok_data then
    local count = 0
    for _ in pairs(data.plugins) do count = count + 1 end
    vim.health.ok(count .. " Datastar attribute plugins loaded")
    vim.health.ok(#data.dom_events .. " DOM events")
    vim.health.ok(#data.html_attrs .. " HTML attributes")
    vim.health.ok(#data.actions .. " actions")
  else
    vim.health.error("Data schema failed to load: " .. tostring(data))
  end

  -- Check completion module
  local ok_comp, comp = pcall(require, "datastar.completion")
  if ok_comp then
    vim.health.ok("Completion module loaded")
    -- Quick smoke test
    local ctx = comp.detect_context("data-on:", 8)
    if ctx and ctx.kind == "KEY" then
      vim.health.ok("Context parser working")
    else
      vim.health.warn("Context parser returned unexpected result")
    end
  else
    vim.health.error("Completion module failed: " .. tostring(comp))
  end

  -- Check setup state
  if ds._configured then
    vim.health.ok("Plugin configured via setup()")
  else
    vim.health.info("setup() not yet called — add require('datastar').setup() to your config")
  end

  -- Check templ support
  local has_templ_parser = pcall(vim.treesitter.language.require_language, "templ", nil, true)
  if has_templ_parser then
    vim.health.ok("templ tree-sitter parser installed")
  else
    vim.health.info("templ tree-sitter parser not installed — install with :TSInstall templ for templ.Attributes highlighting")
  end
  if ok_comp then
    local templ_line = '"data-on'
    local templ_ctx = comp.detect_context(templ_line, #templ_line)
    if templ_ctx and templ_ctx.kind == "ATTRIBUTE_NAME" and templ_ctx.in_templ_map then
      vim.health.ok("templ.Attributes context detection working")
    else
      vim.health.warn("templ.Attributes context detection returned unexpected result")
    end
  end

  -- Check completion engine integration
  local has_cmp = pcall(require, "cmp")
  local has_blink = pcall(require, "blink.cmp")
  if has_cmp then
    vim.health.ok("nvim-cmp detected")
  end
  if has_blink then
    vim.health.ok("blink.cmp detected")
  end
  if not has_cmp and not has_blink then
    vim.health.info("No completion engine detected — native omnifunc will be used")
  end

  -- Check additional modules
  local modules = {
    { "datastar.diagnostics", "Diagnostics engine" },
    { "datastar.textobjects", "Textobjects" },
    { "datastar.workspace", "Cross-file signal tracking" },
    { "datastar.routes", "Route goto definition" },
    { "datastar.examples", "Curated examples" },
    { "datastar.depgraph", "Signal dependency graph" },
    { "datastar.versions", "Version-aware feature gating" },
  }
  for _, mod_info in ipairs(modules) do
    local mod_ok = pcall(require, mod_info[1])
    if mod_ok then
      vim.health.ok(mod_info[2] .. " loaded")
    else
      vim.health.warn(mod_info[2] .. " failed to load")
    end
  end
end

return M
