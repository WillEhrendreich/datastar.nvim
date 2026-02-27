-- tests/routes_spec.lua
-- Tests for route goto definition

package.path = "./lua/?.lua;" .. package.path

describe("datastar.routes", function()
  local routes

  setup(function()
    routes = require("datastar.routes")
  end)

  describe("extract_route_from_action", function()
    it("extracts URL from @get action", function()
      local action = "@get('/api/users')"
      local result = routes.extract_route_from_action(action)
      assert.is_not_nil(result)
      assert.are_equal("/api/users", result.path)
      assert.are_equal("GET", result.method)
    end)

    it("extracts URL from @post action", function()
      local action = "@post('/api/users')"
      local result = routes.extract_route_from_action(action)
      assert.are_equal("/api/users", result.path)
      assert.are_equal("POST", result.method)
    end)

    it("extracts URL from @put action", function()
      local action = "@put('/api/users/1')"
      local result = routes.extract_route_from_action(action)
      assert.are_equal("/api/users/1", result.path)
      assert.are_equal("PUT", result.method)
    end)

    it("extracts URL from @patch action", function()
      local action = "@patch('/api/users/1')"
      local result = routes.extract_route_from_action(action)
      assert.are_equal("/api/users/1", result.path)
      assert.are_equal("PATCH", result.method)
    end)

    it("extracts URL from @delete action", function()
      local action = "@delete('/api/users/1')"
      local result = routes.extract_route_from_action(action)
      assert.are_equal("/api/users/1", result.path)
      assert.are_equal("DELETE", result.method)
    end)

    it("handles double-quoted URLs", function()
      local action = [[@get("/api/items")]]
      local result = routes.extract_route_from_action(action)
      assert.are_equal("/api/items", result.path)
    end)

    it("handles backtick template URLs", function()
      local action = "@get(`/api/items/${$id}`)"
      local result = routes.extract_route_from_action(action)
      assert.is_not_nil(result)
      assert.are_equal("/api/items/${$id}", result.path)
    end)

    it("returns nil for non-fetch actions", function()
      local result = routes.extract_route_from_action("@toggleAll()")
      assert.is_nil(result)
    end)

    it("returns nil for invalid input", function()
      assert.is_nil(routes.extract_route_from_action(""))
      assert.is_nil(routes.extract_route_from_action("not an action"))
    end)
  end)

  describe("route_patterns", function()
    -- Go/Gorilla/Chi patterns
    it("matches Go chi-style route handler", function()
      local line = [[r.Get("/api/users", handleUsers)]]
      local result = routes.match_route_line(line)
      assert.is_not_nil(result)
      assert.are_equal("/api/users", result.path)
      assert.are_equal("GET", result.method)
    end)

    it("matches Go http.HandleFunc", function()
      local line = [[http.HandleFunc("/api/users", handleUsers)]]
      local result = routes.match_route_line(line)
      assert.is_not_nil(result)
      assert.are_equal("/api/users", result.path)
    end)

    -- F#/Falco patterns
    it("matches Falco route handler", function()
      local line = [[get "/api/users" handleUsers]]
      local result = routes.match_route_line(line)
      assert.is_not_nil(result)
      assert.are_equal("/api/users", result.path)
      assert.are_equal("GET", result.method)
    end)

    it("matches Falco post route", function()
      local line = [[post "/api/users" createUser]]
      local result = routes.match_route_line(line)
      assert.are_equal("/api/users", result.path)
      assert.are_equal("POST", result.method)
    end)

    -- Express/Node patterns
    it("matches Express route", function()
      local line = [[app.get('/api/users', handler)]]
      local result = routes.match_route_line(line)
      assert.is_not_nil(result)
      assert.are_equal("/api/users", result.path)
    end)

    -- ASP.NET patterns
    it("matches ASP.NET MapGet", function()
      local line = [[app.MapGet("/api/users", () =>]]
      local result = routes.match_route_line(line)
      assert.is_not_nil(result)
      assert.are_equal("/api/users", result.path)
    end)

    -- Python/Flask patterns
    it("matches Flask decorator route", function()
      local line = [[@app.route('/api/users', methods=['GET'])]]
      local result = routes.match_route_line(line)
      assert.is_not_nil(result)
      assert.are_equal("/api/users", result.path)
    end)
  end)

  describe("routes_match_url", function()
    it("matches exact path", function()
      assert.is_true(routes.path_matches("/api/users", "/api/users"))
    end)

    it("matches with trailing slash difference", function()
      assert.is_true(routes.path_matches("/api/users/", "/api/users"))
    end)

    it("matches parametric route to concrete path", function()
      assert.is_true(routes.path_matches("/api/users/{id}", "/api/users/123"))
    end)

    it("matches :param style", function()
      assert.is_true(routes.path_matches("/api/users/:id", "/api/users/123"))
    end)

    it("does not match different paths", function()
      assert.is_false(routes.path_matches("/api/posts", "/api/users"))
    end)
  end)
end)
