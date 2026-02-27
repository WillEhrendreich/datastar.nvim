-- datastar.routes — route goto definition for @fetch actions
-- Matches URLs in @get/@post/etc to route handlers in Go, F#, Express, ASP.NET, Flask

local M = {}

local fetch_methods = {
  get = "GET",
  post = "POST",
  put = "PUT",
  patch = "PATCH",
  delete = "DELETE",
}

--- Extract route info from a Datastar @action call.
--- @param action string e.g. "@get('/api/users')"
--- @return table|nil { path, method }
function M.extract_route_from_action(action)
  if not action or action == "" then return nil end

  local method_name, url = action:match("^@(%w+)%(['\"`]([^'\"`]+)['\"`]")
  if not method_name then return nil end

  local http_method = fetch_methods[method_name:lower()]
  if not http_method then return nil end

  return { path = url, method = http_method }
end

--- Route pattern matchers for different frameworks.
--- Each returns { path, method } or nil.
local route_matchers = {
  -- Go chi/mux: r.Get("/path", handler) or r.Post(...)
  function(line)
    local method, path = line:match('[%w_]+%.(%u%l+)%(["\']([^"\']+)["\']')
    if method and path then
      local m = method:upper()
      if fetch_methods[method:lower()] then
        return { path = path, method = m }
      end
    end
  end,

  -- Go http.HandleFunc("/path", handler)
  function(line)
    local path = line:match('http%.HandleFunc%(["\']([^"\']+)["\']')
    if path then
      return { path = path, method = "ANY" }
    end
  end,

  -- F#/Falco: get "/path" handler or post "/path" handler
  function(line)
    local method, path = line:match('^%s*(%l+)%s+"([^"]+)"')
    if method and path and fetch_methods[method] then
      return { path = path, method = fetch_methods[method] }
    end
  end,

  -- Express: app.get('/path', handler)
  function(line)
    local method, path = line:match('app%.(%l+)%(["\']([^"\']+)["\']')
    if method and path and fetch_methods[method] then
      return { path = path, method = fetch_methods[method] }
    end
  end,

  -- ASP.NET: app.MapGet("/path", ...)
  function(line)
    local method, path = line:match('%.Map(%u%l+)%(["\']([^"\']+)["\']')
    if method and path then
      local m = method:upper()
      if fetch_methods[method:lower()] then
        return { path = path, method = m }
      end
    end
  end,

  -- Flask: @app.route('/path', methods=['GET'])
  function(line)
    local path = line:match("@%w+%.route%(['\"]([^'\"]+)['\"]")
    if path then
      return { path = path, method = "ANY" }
    end
  end,
}

--- Try to match a line of source code as a route definition.
--- @param line string
--- @return table|nil { path, method }
function M.match_route_line(line)
  for _, matcher in ipairs(route_matchers) do
    local result = matcher(line)
    if result then return result end
  end
  return nil
end

--- Check if a route definition path matches a target URL path.
--- Handles trailing slashes, {param}, :param placeholders.
--- @param route_path string the definition path (may have params)
--- @param target_path string the URL from the action
--- @return boolean
function M.path_matches(route_path, target_path)
  -- Normalize trailing slashes
  local r = route_path:gsub("/$", "")
  local t = target_path:gsub("/$", "")

  if r == t then return true end

  -- Convert route params to regex pattern
  -- {param} and :param → match any segment
  local pattern = "^" .. r:gsub("{[^}]+}", "[^/]+"):gsub(":(%w+)", "[^/]+") .. "$"
  return t:match(pattern) ~= nil
end

return M
