-- datastar.diagnostics — modifier chain validation and expression syntax checking
-- Produces diagnostic items compatible with vim.diagnostic

local data = require("datastar.data")

local M = {}

-- Modifier conflict groups: modifiers within the same group are mutually exclusive
M.conflicts = {
  ["scroll-into-view"] = {
    { "smooth", "instant", "auto" }, -- scroll behavior: pick one
  },
}

--- Parse a datastar attribute string into its components.
--- @param attr string e.g. "data-on:click__debounce.500ms__once"
--- @return table|nil { plugin, key, modifiers: { {name, args: string[], pos: number} } }
function M.parse_attribute(attr)
  -- Must start with data-
  local rest = attr:match("^data%-(.+)$")
  if not rest then return nil end

  -- Split on __ to get segments
  local segments = {}
  local pos = 1
  -- First segment is plugin[:key]
  local first_end = rest:find("__", 1, true)
  local first_seg
  if first_end then
    first_seg = rest:sub(1, first_end - 1)
    pos = first_end + 2
  else
    first_seg = rest
    pos = #rest + 1
  end

  -- Extract plugin and key from first segment
  local plugin, key = first_seg:match("^([%w%-]+):(.*)$")
  if not plugin then
    plugin = first_seg:match("^([%w%-]+)")
    key = nil
  end

  if not plugin then return nil end

  -- Parse modifier segments
  local modifiers = {}
  while pos <= #rest do
    local next_sep = rest:find("__", pos, true)
    local seg
    if next_sep then
      seg = rest:sub(pos, next_sep - 1)
      pos = next_sep + 2
    else
      seg = rest:sub(pos)
      pos = #rest + 1
    end

    -- Split modifier.arg1.arg2
    local parts = {}
    for part in seg:gmatch("[^%.]+") do
      parts[#parts + 1] = part
    end
    if #parts > 0 then
      local mod_name = parts[1]
      local args = {}
      for i = 2, #parts do
        args[#args + 1] = parts[i]
      end
      modifiers[#modifiers + 1] = {
        name = mod_name,
        args = args,
      }
    end
  end

  return {
    plugin = plugin,
    key = key,
    modifiers = modifiers,
  }
end

--- Validate modifier chain on a parsed attribute.
--- @param attr_str string the raw data-* attribute text
--- @return table[] diagnostics { message: string, severity: string }
function M.validate_modifiers(attr_str)
  local parsed = M.parse_attribute(attr_str)
  if not parsed then return {} end

  local plugin_def = data.plugins[parsed.plugin]
  if not plugin_def then return {} end

  local valid_mods = plugin_def.modifiers or {}
  local valid_mod_set = {}
  local valid_mod_args = {}
  for _, mod in ipairs(valid_mods) do
    valid_mod_set[mod.name] = true
    if mod.args then
      valid_mod_args[mod.name] = {}
      for _, a in ipairs(mod.args) do
        valid_mod_args[mod.name][a] = true
      end
    end
  end

  local diagnostics = {}
  local seen_mods = {}

  for _, mod in ipairs(parsed.modifiers) do
    -- Check for unknown/invalid modifier
    if not valid_mod_set[mod.name] then
      diagnostics[#diagnostics + 1] = {
        message = string.format("Modifier '%s' is not valid for data-%s", mod.name, parsed.plugin),
        severity = "WARN",
      }
    end

    -- Check for duplicate modifier
    if seen_mods[mod.name] then
      diagnostics[#diagnostics + 1] = {
        message = string.format("Duplicate modifier '%s'", mod.name),
        severity = "WARN",
      }
    end
    seen_mods[mod.name] = true

    -- Check for duplicate args
    local seen_args = {}
    for _, arg in ipairs(mod.args) do
      if seen_args[arg] then
        diagnostics[#diagnostics + 1] = {
          message = string.format("Duplicate argument '%s' for modifier '%s'", arg, mod.name),
          severity = "WARN",
        }
      end
      seen_args[arg] = true
    end
  end

  -- Check for conflicting modifiers
  local conflict_groups = M.conflicts[parsed.plugin]
  if conflict_groups then
    for _, group in ipairs(conflict_groups) do
      local found = {}
      for _, mod in ipairs(parsed.modifiers) do
        for _, member in ipairs(group) do
          if mod.name == member then
            found[#found + 1] = mod.name
          end
        end
      end
      if #found > 1 then
        diagnostics[#diagnostics + 1] = {
          message = string.format("Conflicting modifiers: %s (pick one)", table.concat(found, ", ")),
          severity = "WARN",
        }
      end
    end
  end

  return diagnostics
end

--- Validate a JavaScript expression for syntax errors.
--- Lightweight check: balanced delimiters, terminated strings, non-empty.
--- @param expr string the expression text
--- @return table[] diagnostics { message: string, severity: string }
function M.validate_expression(expr)
  local diagnostics = {}

  -- Empty check
  if not expr or expr:match("^%s*$") then
    diagnostics[#diagnostics + 1] = {
      message = "Empty expression",
      severity = "WARN",
    }
    return diagnostics
  end

  -- Walk character by character tracking delimiters and strings
  local stack = {}
  local i = 1
  local len = #expr
  local match_close = { ["("] = ")", ["["] = "]", ["{"] = "}" }
  local match_open = { [")"] = "(", ["]"] = "[", ["}"] = "{" }

  while i <= len do
    local c = expr:sub(i, i)

    -- String literals
    if c == "'" or c == '"' or c == "`" then
      local quote = c
      i = i + 1
      local found_close = false
      while i <= len do
        local sc = expr:sub(i, i)
        if sc == "\\" then
          i = i + 2 -- skip escaped char
        elseif sc == quote then
          found_close = true
          i = i + 1
          break
        else
          i = i + 1
        end
      end
      if not found_close then
        diagnostics[#diagnostics + 1] = {
          message = string.format("Unterminated string (opened with %s)", quote),
          severity = "ERROR",
        }
        return diagnostics
      end
    elseif match_close[c] then
      stack[#stack + 1] = c
      i = i + 1
    elseif match_open[c] then
      if #stack == 0 or stack[#stack] ~= match_open[c] then
        diagnostics[#diagnostics + 1] = {
          message = string.format("Unexpected '%s' without matching '%s'", c, match_open[c]),
          severity = "ERROR",
        }
        return diagnostics
      end
      stack[#stack] = nil -- pop
      i = i + 1
    else
      i = i + 1
    end
  end

  -- Check for unclosed delimiters
  if #stack > 0 then
    local unclosed = stack[#stack]
    diagnostics[#diagnostics + 1] = {
      message = string.format("Unclosed '%s' (expected '%s')", unclosed, match_close[unclosed]),
      severity = "ERROR",
    }
  end

  return diagnostics
end

--- Scan a line for all data- attributes and validate each.
--- @param line string the full line text
--- @param lnum number 0-based line number
--- @return table[] diagnostics with lnum and col fields
function M.validate_line(line, lnum)
  local diags = {}
  local pos = 1

  while pos <= #line do
    local s, e = line:find("data%-[%w%-]+", pos)
    if not s then break end

    -- Extend match to include full attribute (key, modifiers, args)
    local attr_end = e + 1
    while attr_end <= #line do
      local c = line:sub(attr_end, attr_end)
      if c:match("[%w%-_:.__]") then
        attr_end = attr_end + 1
      else
        break
      end
    end
    local attr_str = line:sub(s, attr_end - 1)

    -- Modifier validation
    local issues = M.validate_modifiers(attr_str)
    for _, issue in ipairs(issues) do
      diags[#diags + 1] = {
        lnum = lnum,
        col = s - 1,
        message = issue.message,
        severity = issue.severity,
        source = "datastar",
      }
    end

    -- Expression validation: check the attribute value if present
    local eq_pos = line:find("=", attr_end)
    if eq_pos and eq_pos == attr_end then
      local open_q = line:sub(eq_pos + 1, eq_pos + 1)
      if open_q == '"' or open_q == "'" then
        local val_start = eq_pos + 2
        -- Find matching close quote
        local val_end = nil
        for j = val_start, #line do
          if line:sub(j, j) == open_q and line:sub(j - 1, j - 1) ~= "\\" then
            val_end = j - 1
            break
          end
        end
        if val_end then
          local value = line:sub(val_start, val_end)
          -- Get plugin info
          local parsed = M.parse_attribute(attr_str)
          if parsed then
            local plugin_def = data.plugins[parsed.plugin]
            if plugin_def then
              -- Check empty on value_required
              if plugin_def.value_required and value:match("^%s*$") then
                diags[#diags + 1] = {
                  lnum = lnum,
                  col = val_start - 1,
                  message = string.format("Empty expression for data-%s (value required)", parsed.plugin),
                  severity = "WARN",
                  source = "datastar",
                }
              elseif not value:match("^%s*$") then
                local expr_issues = M.validate_expression(value)
                for _, issue in ipairs(expr_issues) do
                  diags[#diags + 1] = {
                    lnum = lnum,
                    col = val_start - 1,
                    message = issue.message,
                    severity = issue.severity,
                    source = "datastar",
                  }
                end
              end
            end
          end
        end
      end
    end

    pos = attr_end
  end

  return diags
end

return M
