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
  return { "-", ":", "_", ".", "@", "$", "=", '"', "'" }
end

--- Complete callback for nvim-cmp / blink.cmp
--- @param params table cmp request params
--- @param callback function callback(items)
function source:complete(params, callback)
  local ctx = params.context or {}
  local line = ctx.cursor_before_line or ""
  local col = #line

  local detected = completion.detect_context(line, col)
  if not detected then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local items = completion.resolve(detected)
  callback({ items = items, isIncomplete = false })
end

return source
