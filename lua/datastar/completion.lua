-- datastar.completion — context parser + completion resolver
-- Returns LSP-compatible CompletionItem tables

local data = require("datastar.data")

local M = {}

-- CompletionItemKind enum (LSP spec)
local Kind = {
  Property = 10,
  Event = 23,
  EnumMember = 20,
  Value = 12,
  Function = 3,
  Variable = 6,
  Snippet = 15,
  Keyword = 14,
}

--- Detect the Datastar completion context from a line of text and cursor column.
--- Returns a context table or nil if cursor is not in a Datastar context.
--- @param line string the full line text
--- @param col number 0-based or 1-based cursor column (we treat as end-of-typed-text)
--- @return table|nil context { kind, plugin?, partial?, modifier? }
function M.detect_context(line, col)
  local text = line:sub(1, col)

  -- Check if we're inside an attribute value
  -- Walk the text tracking quote state to handle JSON-in-quotes correctly
  do
    local last_plugin = nil
    local last_value = nil
    local i = 1
    while i <= #text do
      -- Look for data- attribute start
      local ds, de, pname = text:find("data%-([%w%-]+)", i)
      if not ds then break end
      -- Skip past the attribute name + key + modifiers to find =
      local eq_pos = text:find("=", de + 1)
      if eq_pos then
        -- Check there's no whitespace between attr and =
        local between = text:sub(de + 1, eq_pos - 1)
        if not between:find("[^%w%-_:.__]") then
          local open_quote = text:sub(eq_pos + 1, eq_pos + 1)
          if open_quote == '"' or open_quote == "'" then
            -- Scan forward for the MATCHING close quote only
            local val_start = eq_pos + 2
            local found_close = false
            for j = val_start, #text do
              if text:sub(j, j) == open_quote then
                found_close = true
                i = j + 1
                break
              end
            end
            if not found_close then
              -- We're inside this value — cursor is between open_quote and end
              last_plugin = pname:match("^([%w%-]+)")
              last_value = text:sub(val_start)
              i = #text + 1
            end
          else
            i = eq_pos + 1
          end
        else
          i = de + 1
        end
      else
        i = de + 1
      end
    end
    if last_plugin then
      return {
        kind = "VALUE",
        plugin = last_plugin,
        partial = last_value or "",
      }
    end
  end

  -- Check for modifier arg: data-PLUGIN[:KEY]__MODIFIER.ARG_PARTIAL
  local ma_plugin, ma_modifier, ma_partial = text:match("data%-([%w%-]+)[^%s]*__([%w%-]+)%.([%w]*)$")
  if ma_plugin then
    return {
      kind = "MODIFIER_ARG",
      plugin = ma_plugin:match("^([%w%-]+)"),
      modifier = ma_modifier,
      partial = ma_partial or "",
    }
  end

  -- Check for modifier: data-PLUGIN[:KEY][__MOD.ARG]*__PARTIAL
  local mod_full, mod_partial = text:match("data%-([%w%-]+[^%s]*)__([%w%-]*)$")
  if mod_full then
    local mod_plugin = mod_full:match("^([%w%-]+)")
    return {
      kind = "MODIFIER",
      plugin = mod_plugin,
      partial = mod_partial or "",
    }
  end

  -- Check for key: data-PLUGIN:KEY_PARTIAL
  local key_plugin, key_partial = text:match("data%-([%w%-]+):([%w%-:]*)$")
  if key_plugin then
    return {
      kind = "KEY",
      plugin = key_plugin,
      partial = key_partial or "",
    }
  end

  -- Check for attribute name: data-PARTIAL
  local attr_partial = text:match("data%-([%w%-]*)$")
  if attr_partial ~= nil then
    return {
      kind = "ATTRIBUTE_NAME",
      partial = attr_partial,
    }
  end

  return nil
end

--- Resolve completions for a given context.
--- Returns a list of LSP CompletionItem-compatible tables.
--- @param ctx table context from detect_context
--- @return table[] items
function M.resolve(ctx)
  if not ctx then return {} end

  if ctx.kind == "ATTRIBUTE_NAME" then
    return M._resolve_attribute_name(ctx)
  elseif ctx.kind == "KEY" then
    return M._resolve_key(ctx)
  elseif ctx.kind == "MODIFIER" then
    return M._resolve_modifier(ctx)
  elseif ctx.kind == "MODIFIER_ARG" then
    return M._resolve_modifier_arg(ctx)
  elseif ctx.kind == "VALUE" then
    return M._resolve_value(ctx)
  end

  return {}
end

--- @private
function M._resolve_attribute_name(ctx)
  local items = {}
  local partial = (ctx.partial or ""):lower()
  -- Build snippet lookup: data-pluginName -> snippet
  local snippet_map = {}
  for _, s in ipairs(data.all_snippets()) do
    -- Prefer base trigger (e.g. "data-show") over keyed ("data-on:*")
    if not s.trigger:find("*", 1, true) then
      if not snippet_map[s.trigger] then
        snippet_map[s.trigger] = s
      end
    else
      -- For keyed snippets like "data-on:*", map to base name "data-on"
      local base_trigger = s.trigger:match("^(.-):%*$")
      if base_trigger and not snippet_map[base_trigger] then
        snippet_map[base_trigger] = s
      end
    end
  end
  for name, plugin in pairs(data.plugins) do
    local label = "data-" .. name
    local filter = name:lower()
    if partial == "" or filter:find(partial, 1, true) then
      local item = {
        label = label,
        kind = Kind.Property,
        detail = plugin.description,
        filterText = name,
        sortText = label,
        documentation = {
          kind = "markdown",
          value = plugin.description .. "\n\n[Documentation](" .. plugin.doc_url .. ")",
        },
      }
      -- Wire snippet body if available
      local snippet = snippet_map[label]
      if snippet then
        item.insertText = snippet.body
        item.insertTextFormat = 2 -- Snippet
        item.kind = Kind.Snippet
      end
      items[#items + 1] = item
    end
  end
  table.sort(items, function(a, b) return a.label < b.label end)
  return items
end

--- @private
function M._resolve_key(ctx)
  local items = {}
  local plugin = data.plugins[ctx.plugin]
  if not plugin or not plugin.has_key then return {} end

  local partial = (ctx.partial or ""):lower()
  local candidates = {}

  if plugin.key_type == "dom_events" then
    for _, ev in ipairs(data.dom_events) do
      candidates[#candidates + 1] = { label = ev, detail = "DOM event" }
    end
  elseif plugin.key_type == "html_attrs" then
    for _, attr in ipairs(data.html_attrs) do
      candidates[#candidates + 1] = { label = attr, detail = "HTML attribute" }
    end
  else
    -- signal_name, css_class, etc. — no fixed candidates
    return {}
  end

  for _, c in ipairs(candidates) do
    if partial == "" or c.label:lower():find(partial, 1, true) then
      items[#items + 1] = {
        label = c.label,
        kind = Kind.EnumMember,
        detail = c.detail,
        filterText = c.label,
        sortText = c.label,
      }
    end
  end
  table.sort(items, function(a, b) return a.label < b.label end)
  return items
end

--- @private
function M._resolve_modifier(ctx)
  local items = {}
  local mods = data.get_modifiers(ctx.plugin)
  local partial = (ctx.partial or ""):lower()

  for _, mod in ipairs(mods) do
    if partial == "" or mod.name:lower():find(partial, 1, true) then
      local detail = "Modifier for data-" .. ctx.plugin
      items[#items + 1] = {
        label = mod.name,
        kind = Kind.Keyword,
        detail = detail,
        filterText = mod.name,
        sortText = mod.name,
      }
    end
  end
  table.sort(items, function(a, b) return a.label < b.label end)
  return items
end

--- @private
function M._resolve_modifier_arg(ctx)
  local items = {}
  local mods = data.get_modifiers(ctx.plugin)
  local partial = (ctx.partial or ""):lower()

  -- Find the specific modifier
  local target_mod = nil
  for _, mod in ipairs(mods) do
    if mod.name == ctx.modifier then
      target_mod = mod
      break
    end
  end

  if not target_mod or not target_mod.args then return {} end

  for _, arg in ipairs(target_mod.args) do
    if partial == "" or arg:lower():find(partial, 1, true) then
      items[#items + 1] = {
        label = arg,
        kind = Kind.Value,
        detail = "Argument for __" .. ctx.modifier,
        filterText = arg,
        sortText = arg,
      }
    end
  end
  table.sort(items, function(a, b) return a.label < b.label end)
  return items
end

--- @private
function M._resolve_value(ctx)
  local items = {}
  local partial = (ctx.partial or "")

  -- Action completions (@ prefix)
  if partial == "" or partial:sub(1, 1) == "@" then
    local action_partial = partial:sub(2):lower()
    for _, action in ipairs(data.actions) do
      local short = action.name:sub(2):lower()
      if action_partial == "" or short:find(action_partial, 1, true) then
        -- Build documentation with fetch options for fetch-type actions
        local doc_parts = { action.description }
        if action.is_fetch and data.fetch_options and #data.fetch_options > 0 then
          doc_parts[#doc_parts + 1] = "\n\n**Fetch Options:**"
          for _, opt in ipairs(data.fetch_options) do
            doc_parts[#doc_parts + 1] = string.format("- `%s` — %s", opt.name, opt.description)
          end
        end
        doc_parts[#doc_parts + 1] = "\n\n[Documentation](" .. action.doc_url .. ")"
        items[#items + 1] = {
          label = action.name,
          kind = Kind.Function,
          detail = action.signature,
          filterText = action.name,
          sortText = action.name,
          insertText = action.snippet,
          insertTextFormat = 2, -- Snippet
          documentation = {
            kind = "markdown",
            value = table.concat(doc_parts, "\n"),
          },
        }
      end
    end
  end

  -- Signal completions ($ prefix)
  if partial == "" or partial:sub(1, 1) == "$" then
    local sig_partial = partial:sub(2):lower()
    local signals = ctx.signals or {}
    for _, sig in ipairs(signals) do
      if sig_partial == "" or sig:lower():find(sig_partial, 1, true) then
        items[#items + 1] = {
          label = "$" .. sig,
          kind = Kind.Variable,
          detail = "Signal: " .. sig,
          filterText = "$" .. sig,
          sortText = "$" .. sig,
        }
      end
    end
  end

  table.sort(items, function(a, b) return a.label < b.label end)
  return items
end

--- Scan buffer lines for signal-creating attributes.
--- Returns a list of signal names found in the buffer.
--- @param lines string[] buffer lines
--- @return string[] signal names
function M.scan_signals(lines)
  local seen = {}
  local signals = {}

  -- Signal-creating plugins: signals, bind, ref, computed, indicator
  local signal_plugins = { signals = true, bind = true, ref = true, computed = true, indicator = true }

  for _, line in ipairs(lines) do
    -- Match data-PLUGIN:KEY form (colon-keyed signals)
    for plugin, key in line:gmatch("data%-(%w+):([%w%-_]+)") do
      if signal_plugins[plugin] and not seen[key] then
        seen[key] = true
        signals[#signals + 1] = key
      end
    end
    -- Match object-form data-signals='{ key: val, key2: val2 }'
    local obj_body = line:match('data%-signals%s*=%s*["\']%s*{(.-)%s*}')
    if obj_body then
      for key in obj_body:gmatch("([%w_]+)%s*:") do
        if not seen[key] then
          seen[key] = true
          signals[#signals + 1] = key
        end
      end
    end
  end

  table.sort(signals)
  return signals
end

--- Find the Datastar plugin name under the cursor position.
--- Scans all data- attributes on the line and returns the one
--- whose span contains the given column (0-based).
--- @param line string the full line text
--- @param col number 0-based cursor column
--- @return string|nil plugin name, or nil if cursor is not on a data- attribute
function M.find_plugin_at_cursor(line, col)
  local best_plugin = nil
  local pos = 1
  while true do
    local s, e, pname = line:find("data%-([%w%-]+)", pos)
    if not s then break end
    -- The attribute spans from "data-" start to end-of-value or next whitespace
    -- Find end of this attribute (next whitespace or > or end of line)
    local attr_end = line:find("[%s>]", e + 1)
    if not attr_end then attr_end = #line + 1 end
    -- col is 0-based, s is 1-based, so convert: col+1 for 1-based comparison
    local cursor_1 = col + 1
    if cursor_1 >= s and cursor_1 < attr_end then
      best_plugin = pname:match("^([%w%-]+)")
    end
    pos = e + 1
  end
  return best_plugin
end

--- Produce vim-compatible completion items (for omnifunc).
--- Returns a list of tables with word, menu, info, kind fields.
--- @param line string the current line text
--- @param col number cursor column (1-based, end of typed text)
--- @param base string|nil optional filter text for the completion items
--- @return table[] items suitable for complete()
function M.omnifunc_items(line, col, base)
  local ctx = M.detect_context(line, col)
  if not ctx then return {} end

  local lsp_items = M.resolve(ctx)
  local results = {}
  local filter = base and base:lower() or nil
  for _, item in ipairs(lsp_items) do
    local word = item.label
    -- Apply base filtering when provided
    local dominated = filter and filter ~= "" and not word:lower():find(filter, 1, true)
    if not dominated then
      local info = ""
      if item.documentation then
        if type(item.documentation) == "table" then
          info = item.documentation.value or ""
        else
          info = item.documentation
        end
      end
      results[#results + 1] = {
        word = word,
        menu = "[DS]",
        info = info,
        kind = item.detail or "",
        label = item.label,
      }
    end
  end
  return results
end

return M
