-- tests/panel_fixes_spec.lua
-- Tests for issues identified by the expert panel critique
-- Each section corresponds to a numbered panel finding

package.path = "./lua/?.lua;" .. package.path

describe("panel fixes", function()
  local completion, data

  setup(function()
    completion = require("datastar.completion")
    data = require("datastar.data")
  end)

  -- Panel #2: hover() targets first data- on line, not cursor position
  -- We test the underlying logic: find_plugin_at_cursor
  describe("find_plugin_at_cursor", function()
    it("finds the second attribute when cursor is on it", function()
      local line = '<div data-signals:name="Will" data-on:click="@post()">'
      -- cursor is on "data-on" (col ~31, 0-based)
      local plugin = completion.find_plugin_at_cursor(line, 35)
      assert.are_equal("on", plugin)
    end)

    it("finds the first attribute when cursor is on it", function()
      local line = '<div data-signals:name="Will" data-on:click="@post()">'
      local plugin = completion.find_plugin_at_cursor(line, 10)
      assert.are_equal("signals", plugin)
    end)

    it("returns nil when cursor is not on any data- attribute", function()
      local line = '<div class="foo" data-on:click="@post()">'
      local plugin = completion.find_plugin_at_cursor(line, 5)
      assert.is_nil(plugin)
    end)

    it("handles cursor at the very start of data-", function()
      local line = '<div data-show="true">'
      local plugin = completion.find_plugin_at_cursor(line, 5)
      assert.are_equal("show", plugin)
    end)

    it("handles cursor inside modifier chain", function()
      local line = '<div data-on:click__debounce.500ms="@post()">'
      local plugin = completion.find_plugin_at_cursor(line, 25)
      assert.are_equal("on", plugin)
    end)

    it("handles three attributes on one line", function()
      local line = '<div data-show="true" data-on:click="@get()" data-text="$msg">'
      local plugin = completion.find_plugin_at_cursor(line, 40)
      assert.are_equal("on", plugin)
    end)
  end)

  -- Panel #3: VALUE context breaks on JSON-in-quotes
  describe("VALUE context with JSON-in-quotes", function()
    it("handles single-quoted attr with inner double quotes", function()
      local line = [[  data-signals='{"name": "Will", "count": 0}']]
      -- cursor is NOT inside the value (quotes are closed)
      local ctx = completion.detect_context(line, #line)
      assert.is_not_equal("VALUE", ctx and ctx.kind)
    end)

    it("detects open value with inner different-style quotes", function()
      local line = [[  data-signals='{"name": "Will]]
      local ctx = completion.detect_context(line, #line)
      assert.is_not_nil(ctx)
      assert.are_equal("VALUE", ctx.kind)
      assert.are_equal("signals", ctx.plugin)
    end)

    it("handles double-quoted attr with inner single quotes", function()
      local line = '  data-on:click="@get(\'/api\')"'
      -- closed — cursor after closing quote
      local ctx = completion.detect_context(line, #line)
      assert.is_not_equal("VALUE", ctx and ctx.kind)
    end)

    it("detects open double-quoted attr with inner single quotes", function()
      local line = "  data-on:click=\"@get('/api'"
      local ctx = completion.detect_context(line, #line)
      assert.is_not_nil(ctx)
      assert.are_equal("VALUE", ctx.kind)
    end)
  end)

  -- Panel #6: is_available() should check filetype
  describe("cmp_source filetype awareness", function()
    local cmp_source

    setup(function()
      cmp_source = require("datastar.cmp_source")
    end)

    it("reports available for html filetype", function()
      local src = cmp_source.new()
      assert.is_true(src:is_available("html"))
    end)

    it("reports available for templ filetype", function()
      local src = cmp_source.new()
      assert.is_true(src:is_available("templ"))
    end)

    it("reports not available for python filetype", function()
      local src = cmp_source.new()
      assert.is_false(src:is_available("python"))
    end)

    it("reports not available for lua filetype", function()
      local src = cmp_source.new()
      assert.is_false(src:is_available("lua"))
    end)
  end)

  -- Panel #8: Snippets should be wired to attribute completions
  describe("snippet expansion in completions", function()
    it("attribute completions include insertText with snippet body", function()
      local ctx = { kind = "ATTRIBUTE_NAME", partial = "on" }
      local items = completion.resolve(ctx)
      local on_item = nil
      for _, item in ipairs(items) do
        if item.label == "data-on" then
          on_item = item
          break
        end
      end
      assert.is_not_nil(on_item, "should have data-on completion")
      assert.is_not_nil(on_item.insertText, "data-on should have insertText")
      assert.are_equal(2, on_item.insertTextFormat, "should be snippet format")
      assert.is_truthy(on_item.insertText:find("%$%{"), "should have snippet placeholder")
    end)

    it("data-show snippet includes expression placeholder", function()
      local ctx = { kind = "ATTRIBUTE_NAME", partial = "show" }
      local items = completion.resolve(ctx)
      assert.is_true(#items > 0)
      local show_item = items[1]
      assert.is_not_nil(show_item.insertText)
      assert.is_truthy(show_item.insertText:find("expression"), "should mention expression")
    end)
  end)

  -- Panel #9: fetch_options should appear in action docs
  describe("fetch_options in action documentation", function()
    it("@get documentation includes fetch options", function()
      local ctx = { kind = "VALUE", plugin = "on", partial = "@ge" }
      local items = completion.resolve(ctx)
      local get_item = nil
      for _, item in ipairs(items) do
        if item.label == "@get" then
          get_item = item
          break
        end
      end
      assert.is_not_nil(get_item, "should have @get")
      local doc = get_item.documentation
      assert.is_not_nil(doc)
      local doc_text = type(doc) == "table" and doc.value or doc
      assert.is_truthy(doc_text:find("contentType"), "should mention contentType option")
      assert.is_truthy(doc_text:find("headers"), "should mention headers option")
    end)
  end)

  -- Panel #4: $signal buffer scanning
  describe("signal scanning", function()
    it("scan_signals extracts signal names from data-signals:key form", function()
      local lines = {
        '<div data-signals:name="\'Will\'">',
        '<input data-bind:email />',
        '<span data-ref:mySpan></span>',
        '<div data-computed:fullName="$first + $last">',
        '<div data-indicator:loading></div>',
      }
      local signals = completion.scan_signals(lines)
      local signal_set = {}
      for _, s in ipairs(signals) do signal_set[s] = true end
      assert.is_true(signal_set["name"], "should find name from data-signals")
      assert.is_true(signal_set["email"], "should find email from data-bind")
      assert.is_true(signal_set["mySpan"], "should find mySpan from data-ref")
      assert.is_true(signal_set["fullName"], "should find fullName from data-computed")
      assert.is_true(signal_set["loading"], "should find loading from data-indicator")
    end)

    it("scan_signals extracts from object-form data-signals", function()
      local lines = {
        '  <div data-signals="{count: 0, name: \'Will\'}">',
      }
      local signals = completion.scan_signals(lines)
      local signal_set = {}
      for _, s in ipairs(signals) do signal_set[s] = true end
      assert.is_true(signal_set["count"], "should find count from JSON object")
      assert.is_true(signal_set["name"], "should find name from JSON object")
    end)

    it("resolve returns signal completions with $ prefix", function()
      local ctx = {
        kind = "VALUE",
        plugin = "show",
        partial = "$",
        signals = { "name", "count", "loading" },
      }
      local items = completion.resolve(ctx)
      local labels = {}
      for _, item in ipairs(items) do labels[item.label] = true end
      assert.is_true(labels["$name"], "should suggest $name")
      assert.is_true(labels["$count"], "should suggest $count")
      assert.is_true(labels["$loading"], "should suggest $loading")
    end)

    it("resolve filters signals by partial", function()
      local ctx = {
        kind = "VALUE",
        plugin = "show",
        partial = "$na",
        signals = { "name", "count", "loading" },
      }
      local items = completion.resolve(ctx)
      assert.is_true(#items >= 1)
      for _, item in ipairs(items) do
        assert.is_truthy(item.label:find("na", 1, true), "should match partial: " .. item.label)
      end
    end)
  end)

  -- Panel #7: omnifunc should use base param for filtering
  describe("omnifunc_items filtering with base", function()
    it("filters attribute completions by base text", function()
      local items = completion.omnifunc_items("  data-", 7, "sig")
      assert.is_true(#items > 0)
      for _, item in ipairs(items) do
        assert.is_truthy(
          item.word:lower():find("sig", 1, true),
          "should match base 'sig': " .. item.word
        )
      end
    end)

    it("returns all items when base is empty", function()
      local all = completion.omnifunc_items("  data-", 7)
      local filtered = completion.omnifunc_items("  data-", 7, "")
      assert.are_equal(#all, #filtered)
    end)
  end)

  -- Panel #11: _configured guard should not prevent re-configuration
  -- (This is tested via the actual Neovim API, not unit-testable here)
  -- We verify the module structure instead
  describe("module structure", function()
    it("data.filetypes_set exists for O(1) lookup", function()
      assert.is_table(data.filetypes_set)
      assert.is_true(data.filetypes_set["html"])
      assert.is_nil(data.filetypes_set["python"])
    end)
  end)
end)
