-- datastar.cmp_source — nvim-cmp and blink.cmp source adapter
-- Provides a cmp-compatible source that delegates to datastar.completion

local completion = require("datastar.completion")

local source = {}
source.__index = source

function source.new()
  return setmetatable({}, source)
end

function source:get_debug_name()
  return "datastar"
end

function source:is_available()
  return true
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
