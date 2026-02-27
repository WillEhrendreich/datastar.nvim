-- datastar.textobjects — structural editing for modifier chains and keys
-- Provides functions for textobject selection, navigation, and deletion

local M = {}

--- Parse all modifier segments from a data- attribute on a line.
--- @param line string
--- @return table[] segments { name, text, start_col (0-based), end_col (0-based exclusive), outer_start, outer_end }
function M.parse_modifiers(line)
  -- Find a data- attribute
  local attr_start = line:find("data%-[%w%-]+")
  if not attr_start then return {} end

  local segments = {}
  local pos = attr_start
  -- Find all __ delimiters
  while true do
    local sep_start, sep_end = line:find("__", pos, true)
    if not sep_start then break end
    -- The modifier text runs from sep_end+1 to the next __ or whitespace/>/=/end
    local mod_start = sep_end + 1
    local mod_end = #line + 1
    -- Find next __ or boundary
    local next_sep = line:find("__", mod_start, true)
    local next_boundary = line:find("[%s>='\"]", mod_start)
    if next_sep and (not next_boundary or next_sep < next_boundary) then
      mod_end = next_sep
    elseif next_boundary then
      mod_end = next_boundary
    end

    local text = line:sub(mod_start, mod_end - 1)
    if text ~= "" then
      local name = text:match("^([%w%-]+)")
      segments[#segments + 1] = {
        name = name or text,
        text = text,
        start_col = mod_start - 1, -- 0-based
        end_col = mod_end - 1, -- 0-based exclusive
        outer_start = sep_start - 1, -- includes __ delimiter
        outer_end = mod_end - 1,
      }
    end

    pos = mod_end
  end

  return segments
end

--- Find the modifier segment under the given column.
--- @param line string
--- @param col number 0-based cursor column
--- @return table|nil { text, start_col, end_col, outer_start, outer_end, name }
function M.find_modifier_at_col(line, col)
  local mods = M.parse_modifiers(line)
  for _, mod in ipairs(mods) do
    if col >= mod.start_col and col < mod.end_col then
      return mod
    end
  end
  return nil
end

--- Find the key segment under the given column.
--- @param line string
--- @param col number 0-based cursor column
--- @return table|nil { text, start_col, end_col, outer_start, outer_end }
function M.find_key_at_col(line, col)
  -- Look for data-PLUGIN:KEY pattern
  local s, e, key = line:find("data%-[%w%-]+:([%w%-]+)")
  if not s then return nil end

  -- Find where the key starts
  local colon_pos = line:find(":", s)
  if not colon_pos then return nil end

  local key_start = colon_pos + 1
  local key_end = key_start + #key

  -- col is 0-based, key_start is 1-based
  local key_start_0 = key_start - 1
  local key_end_0 = key_end - 1

  if col >= key_start_0 and col < key_end_0 then
    return {
      text = key,
      start_col = key_start_0,
      end_col = key_end_0,
      outer_start = colon_pos - 1, -- includes colon
      outer_end = key_end_0,
    }
  end
  return nil
end

--- Find the next modifier after the given column.
--- @param line string
--- @param col number 0-based cursor column
--- @return table|nil modifier segment
function M.next_modifier(line, col)
  local mods = M.parse_modifiers(line)
  for _, mod in ipairs(mods) do
    if mod.start_col > col then
      return mod
    end
  end
  return nil
end

--- Find the previous modifier before the given column.
--- @param line string
--- @param col number 0-based cursor column
--- @return table|nil modifier segment
function M.prev_modifier(line, col)
  local mods = M.parse_modifiers(line)
  local prev = nil
  for _, mod in ipairs(mods) do
    if mod.end_col <= col then
      prev = mod
    end
  end
  return prev
end

--- Delete a modifier at cursor position and return the resulting line.
--- @param line string
--- @param col number 0-based cursor column
--- @return string|nil modified line, or nil if no modifier found
function M.delete_modifier_text(line, col)
  local mod = M.find_modifier_at_col(line, col)
  if not mod then return nil end
  -- Remove outer (including __) from the line
  local before = line:sub(1, mod.outer_start)
  local after = line:sub(mod.outer_end + 1)
  return before .. after
end

return M
