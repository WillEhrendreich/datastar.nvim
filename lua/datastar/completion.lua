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

  -- Check if we're inside an attribute value (between opening quote and no closing quote)
  -- Pattern: data-PLUGIN[:KEY][__MOD...]="VALUE_SO_FAR  (no closing quote)
  local val_plugin, val_rest = text:match('data%-([%w%-]+)[^"\']*=["\']([^"\']*)')
  if val_plugin then
    -- strip key/modifiers from plugin match — we need the raw plugin name
    local plugin = val_plugin:match("^([%w%-]+)")
    -- Check this is the LAST attribute value on the line (not a closed one)
    -- Find the last data- attribute with an open quote
    local last_open_pos = nil
    local last_plugin = nil
    local last_value = nil
    local pos = 1
    while true do
      -- find next data- attribute with open quote
      local s, e, p, v = text:find('data%-([%w%-]+)[^"\']*=["\']([^"\']*)', pos)
      if not s then break end
      -- Check if the quote is closed after the value
      local quote_char = text:sub(s + #("data-" .. p), e - #v):match("[\"']")
      local after_val = text:sub(e + 1, e + 1)
      if after_val ~= quote_char and after_val ~= '"' and after_val ~= "'" then
        last_open_pos = s
        last_plugin = p:match("^([%w%-]+)")
        last_value = v
      end
      pos = e + 1
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
  for name, plugin in pairs(data.plugins) do
    local label = "data-" .. name
    local filter = name:lower()
    if partial == "" or filter:find(partial, 1, true) then
      items[#items + 1] = {
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
            value = action.description .. "\n\n[Documentation](" .. action.doc_url .. ")",
          },
        }
      end
    end
  end

  -- Signal completions ($ prefix) — placeholder for buffer scanning
  -- In a real Neovim context, this would scan the buffer for signal definitions.
  -- For now, return empty. The infrastructure is here for future use.

  table.sort(items, function(a, b) return a.label < b.label end)
  return items
end

--- Produce vim-compatible completion items (for omnifunc).
--- Returns a list of tables with word, menu, info, kind fields.
--- @param line string the current line text
--- @param col number cursor column (1-based, end of typed text)
--- @return table[] items suitable for complete()
function M.omnifunc_items(line, col)
  local ctx = M.detect_context(line, col)
  if not ctx then return {} end

  local lsp_items = M.resolve(ctx)
  local results = {}
  for _, item in ipairs(lsp_items) do
    local word = item.label
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
  return results
end

return M
