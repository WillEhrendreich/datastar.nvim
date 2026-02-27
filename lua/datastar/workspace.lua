-- datastar.workspace — cross-file signal tracking
-- Scans workspace files for signal definitions and references

local M = {}

--- File patterns that can contain Datastar attributes
M.supported_patterns = {
  "*.html",
  "*.htm",
  "*.vue",
  "*.svelte",
  "*.astro",
  "*.templ",
  "*.razor",
  "*.cshtml",
  "*.erb",
  "*.hbs",
  "*.njk",
  "*.jinja",
  "*.jinja2",
  "*.twig",
  "*.liquid",
  "*.php",
  "*.jsx",
  "*.tsx",
}

--- Scan file content for signal definitions and references.
--- @param content string file content
--- @param filepath string source file path
--- @return table[] signals { name, file, lnum, col (0-based), kind }
function M.scan_file_for_signals(content, filepath)
  local signals = {}
  local seen = {}
  local lines = {}
  for line in (content .. "\n"):gmatch("([^\n]*)\n") do
    lines[#lines + 1] = line
  end

  local def_plugins = { "signals", "bind", "ref", "computed", "indicator" }
  for lnum, line in ipairs(lines) do
    -- data-{plugin}:KEY="value" → definition (for all signal-defining plugins)
    for _, plugin in ipairs(def_plugins) do
      for key in line:gmatch("data%-" .. plugin .. ":([%w%-]+)") do
        if not seen[key] then
          seen[key] = true
          local col = line:find("data%-" .. plugin .. ":" .. key, 1, true) or 0
          signals[#signals + 1] = {
            name = key,
            file = filepath,
            lnum = lnum,
            col = col - 1,
            kind = "definition",
          }
        end
      end
    end

    -- data-signals="{key: val, key2: val2}" → merged definitions
    local merged = line:match('data%-signals%s*=%s*["\']({.-})["\']')
    if merged then
      for key in merged:gmatch("([%w_]+)%s*:") do
        if not seen[key] then
          seen[key] = true
          signals[#signals + 1] = {
            name = key,
            file = filepath,
            lnum = lnum,
            col = 0,
            kind = "definition",
          }
        end
      end
    end

    -- $signalName references in attribute values
    for sig in line:gmatch("%$([%w_]+)") do
      if not seen[sig] then
        seen[sig] = true
        signals[#signals + 1] = {
          name = sig,
          file = filepath,
          lnum = lnum,
          col = 0,
          kind = "reference",
        }
      end
    end
  end

  return signals
end

--- Create a signal store for managing cross-file signal data.
--- @return table store
function M.create_store()
  local store = {
    _files = {}, -- filepath → signal[]
  }

  --- Update signals for a given file (replaces previous data).
  --- @param filepath string
  --- @param signals table[]
  function store:update_file(filepath, signals)
    self._files[filepath] = signals
  end

  --- Get all unique signal names across all files.
  --- @return string[]
  function store:get_all_names()
    local seen = {}
    local names = {}
    for _, sigs in pairs(self._files) do
      for _, sig in ipairs(sigs) do
        if not seen[sig.name] then
          seen[sig.name] = true
          names[#names + 1] = sig.name
        end
      end
    end
    table.sort(names)
    return names
  end

  --- Find all definitions of a signal by name.
  --- @param name string
  --- @return table[] definitions
  function store:find_definitions(name)
    local defs = {}
    for _, sigs in pairs(self._files) do
      for _, sig in ipairs(sigs) do
        if sig.name == name and sig.kind == "definition" then
          defs[#defs + 1] = sig
        end
      end
    end
    return defs
  end

  --- Clear all stored data.
  function store:clear()
    self._files = {}
  end

  return store
end

return M
