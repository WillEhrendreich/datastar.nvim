-- datastar.cmp_source — nvim-cmp and blink.cmp source adapter
-- Provides a cmp-compatible source that delegates to datastar.completion

local completion = require("datastar.completion")
local data = require("datastar.data")

local source = {}
source.__index = source

function source.new()
  return setmetatable({}, source)
end

function source:get_debug_name()
  return "datastar"
end

function source:is_available(filetype)
  local ft = filetype
  if not ft and vim and vim.bo then
    ft = vim.bo.filetype
  end
  if not ft then return false end
  return data.filetypes_set[ft] or false
end

function source:get_trigger_characters()
  return { "-", ":", "_", ".", "@", "$", "=", '"', "'", "`" }
end

--- Shared completion logic used by both nvim-cmp and blink.cmp
--- @param line string text before the cursor
--- @param callback function
local function do_complete(line, callback)
  local col = #line

  local detected = completion.detect_context(line, col)
  if not detected then
    callback({ items = {}, isIncomplete = false, is_incomplete_forward = false, is_incomplete_backward = false })
    return
  end

  -- Inject buffer signals for $signal completions
  if detected.kind == "VALUE" and vim and vim.api then
    local buf_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    detected.signals = completion.scan_signals(buf_lines)
  end

  local items = completion.resolve(detected)
  callback({ items = items, isIncomplete = false, is_incomplete_forward = false, is_incomplete_backward = false })
end

--- nvim-cmp: complete(params, callback) — params.context.cursor_before_line
function source:complete(params, callback)
  local ctx = params.context or params
  local line = ctx.cursor_before_line or ""
  do_complete(line, callback)
end

--- blink.cmp: get_completions(ctx, callback)
--- blink.cmp context has ctx.line (full line) + ctx.cursor[2] (0-based col), not cursor_before_line
function source:get_completions(ctx, callback)
  local line = ctx.cursor_before_line
    or (ctx.line and ctx.cursor and ctx.line:sub(1, ctx.cursor[2]))
    or ""
  do_complete(line, callback)
end

return source
