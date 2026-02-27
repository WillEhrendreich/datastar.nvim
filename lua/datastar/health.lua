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
end

return M
