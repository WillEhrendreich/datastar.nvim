-- tests/data_spec.lua
-- Tests for lua/datastar/data.lua schema integrity

package.path = "./lua/?.lua;" .. package.path

describe("datastar.data", function()
  local data

  setup(function()
    data = require("datastar.data")
  end)

  describe("plugins", function()
    it("should have all core attributes", function()
      local core = {
        "attr", "bind", "class", "computed", "effect", "ignore",
        "ignore-morph", "indicator", "init", "json-signals", "on",
        "on-intersect", "on-interval", "on-signal-patch",
        "on-signal-patch-filter", "preserve-attr", "ref", "show",
        "signals", "style", "text",
      }
      for _, name in ipairs(core) do
        assert.is_not_nil(data.plugins[name], "missing core plugin: " .. name)
      end
    end)

    it("should have pro attributes", function()
      local pro = {
        "animate", "custom-validity", "on-raf", "on-resize",
        "persist", "query-string", "replace-url", "rocket",
        "scroll-into-view", "view-transition",
      }
      for _, name in ipairs(pro) do
        assert.is_not_nil(data.plugins[name], "missing pro plugin: " .. name)
      end
    end)

    it("should have required fields on every plugin", function()
      for name, plugin in pairs(data.plugins) do
        assert.is_string(plugin.description, name .. " missing description")
        assert.is_string(plugin.doc_url, name .. " missing doc_url")
        assert.is_boolean(plugin.has_key, name .. " missing has_key")
        assert.is_boolean(plugin.value_required, name .. " missing value_required")
        assert.is_table(plugin.modifiers, name .. " missing modifiers")
        assert.is_table(plugin.snippets, name .. " missing snippets")
        assert.is_true(#plugin.snippets > 0, name .. " has no snippets")
      end
    end)

    it("should have doc URLs pointing to data-star.dev", function()
      for name, plugin in pairs(data.plugins) do
        assert.is_truthy(
          plugin.doc_url:match("^https://data%-star%.dev/"),
          name .. " doc_url doesn't start with https://data-star.dev/"
        )
      end
    end)

    it("should have valid modifier entries", function()
      for name, plugin in pairs(data.plugins) do
        for _, mod in ipairs(plugin.modifiers) do
          assert.is_string(mod.name, name .. " has modifier without name")
          if mod.args then
            assert.is_table(mod.args, name .. "." .. mod.name .. " args is not table")
            assert.is_true(#mod.args > 0, name .. "." .. mod.name .. " args is empty")
          end
        end
      end
    end)

    it("should have snippet trigger starting with data-", function()
      for name, plugin in pairs(data.plugins) do
        for _, snippet in ipairs(plugin.snippets) do
          assert.is_truthy(
            snippet.trigger:match("^data%-"),
            name .. " snippet trigger doesn't start with data-: " .. snippet.trigger
          )
        end
      end
    end)

    it("data-on should require key", function()
      assert.is_true(data.plugins.on.key_required)
    end)

    it("data-on should have DOM events as key type", function()
      assert.are_equal("dom_events", data.plugins.on.key_type)
    end)

    it("data-attr should have html_attrs as key type", function()
      assert.are_equal("html_attrs", data.plugins.attr.key_type)
    end)
  end)

  describe("actions", function()
    it("should have all 8 actions", function()
      assert.are_equal(8, #data.actions)
    end)

    it("should have required fields on every action", function()
      for _, action in ipairs(data.actions) do
        assert.is_string(action.name, "action missing name")
        assert.is_string(action.signature, action.name .. " missing signature")
        assert.is_string(action.description, action.name .. " missing description")
        assert.is_string(action.doc_url, action.name .. " missing doc_url")
        assert.is_string(action.snippet, action.name .. " missing snippet")
        assert.is_truthy(action.name:match("^@"), action.name .. " doesn't start with @")
      end
    end)

    it("should have all HTTP method actions", function()
      local methods = { "@get", "@post", "@put", "@patch", "@delete" }
      local action_names = {}
      for _, a in ipairs(data.actions) do
        action_names[a.name] = true
      end
      for _, m in ipairs(methods) do
        assert.is_true(action_names[m], "missing action: " .. m)
      end
    end)

    it("should have utility actions", function()
      local utils = { "@peek", "@setAll", "@toggleAll" }
      local action_names = {}
      for _, a in ipairs(data.actions) do
        action_names[a.name] = true
      end
      for _, u in ipairs(utils) do
        assert.is_true(action_names[u], "missing action: " .. u)
      end
    end)
  end)

  describe("fetch_options", function()
    it("should have all documented options", function()
      local expected = {
        "contentType", "filterSignals", "selector", "headers",
        "openWhenHidden", "payload", "retry", "retryInterval",
        "retryScaler", "retryMaxWaitMs", "retryMaxCount", "requestCancellation",
      }
      assert.are_equal(#expected, #data.fetch_options)
      local option_names = {}
      for _, opt in ipairs(data.fetch_options) do
        option_names[opt.name] = true
      end
      for _, name in ipairs(expected) do
        assert.is_true(option_names[name], "missing fetch option: " .. name)
      end
    end)
  end)

  describe("dom_events", function()
    it("should have common events", function()
      local common = { "click", "submit", "input", "change", "keydown", "keyup", "focus", "blur", "scroll" }
      local event_set = {}
      for _, e in ipairs(data.dom_events) do
        event_set[e] = true
      end
      for _, e in ipairs(common) do
        assert.is_true(event_set[e], "missing DOM event: " .. e)
      end
    end)

    it("should have at least 50 events", function()
      assert.is_true(#data.dom_events >= 50)
    end)
  end)

  describe("html_attrs", function()
    it("should have common attributes", function()
      local common = { "id", "class", "style", "href", "src", "type", "name", "value", "disabled", "hidden" }
      local attr_set = {}
      for _, a in ipairs(data.html_attrs) do
        attr_set[a] = true
      end
      for _, a in ipairs(common) do
        assert.is_true(attr_set[a], "missing HTML attr: " .. a)
      end
    end)
  end)

  describe("filetypes", function()
    it("should include html", function()
      local ft_set = {}
      for _, ft in ipairs(data.filetypes) do
        ft_set[ft] = true
      end
      assert.is_true(ft_set["html"])
    end)

    it("should include common template languages", function()
      local templates = { "php", "vue", "svelte", "astro", "templ", "eruby" }
      local ft_set = {}
      for _, ft in ipairs(data.filetypes) do
        ft_set[ft] = true
      end
      for _, t in ipairs(templates) do
        assert.is_true(ft_set[t], "missing filetype: " .. t)
      end
    end)
  end)

  describe("helpers", function()
    it("plugin_names should return sorted list", function()
      local names = data.plugin_names()
      assert.is_true(#names > 0)
      for i = 2, #names do
        assert.is_true(names[i - 1] <= names[i], "not sorted: " .. names[i - 1] .. " > " .. names[i])
      end
    end)

    it("get_modifiers should return modifiers for known plugin", function()
      local mods = data.get_modifiers("on")
      assert.is_true(#mods > 0)
    end)

    it("get_modifiers should return empty for unknown plugin", function()
      local mods = data.get_modifiers("nonexistent")
      assert.are_equal(0, #mods)
    end)

    it("all_snippets should return sorted flattened list", function()
      local snippets = data.all_snippets()
      assert.is_true(#snippets > 0)
      for i = 2, #snippets do
        assert.is_true(
          snippets[i - 1].trigger <= snippets[i].trigger,
          "not sorted: " .. snippets[i - 1].trigger .. " > " .. snippets[i].trigger
        )
      end
    end)

    it("all_snippets items should have all fields", function()
      local snippets = data.all_snippets()
      for _, s in ipairs(snippets) do
        assert.is_string(s.trigger)
        assert.is_string(s.body)
        assert.is_string(s.description)
        assert.is_string(s.doc_url)
        assert.is_string(s.plugin)
      end
    end)
  end)
end)
