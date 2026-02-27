-- tests/workspace_spec.lua
-- Tests for cross-file signal tracking

package.path = "./lua/?.lua;" .. package.path

describe("datastar.workspace", function()
  local workspace

  setup(function()
    workspace = require("datastar.workspace")
  end)

  describe("scan_file_for_signals", function()
    it("finds signals in data-signals attributes", function()
      local content = [[
<div data-signals:userName="'John'"></div>
<div data-signals:age="25"></div>
]]
      local result = workspace.scan_file_for_signals(content, "test.html")
      assert.is_not_nil(result)
      assert.are_equal(2, #result)

      local names = {}
      for _, sig in ipairs(result) do
        names[sig.name] = true
      end
      assert.is_true(names["userName"])
      assert.is_true(names["age"])
    end)

    it("finds merged signals", function()
      local content = [[<div data-signals="{firstName: 'Will', lastName: 'E'}"></div>]]
      local result = workspace.scan_file_for_signals(content, "test.html")
      assert.is_not_nil(result)

      local names = {}
      for _, sig in ipairs(result) do
        names[sig.name] = true
      end
      assert.is_true(names["firstName"])
      assert.is_true(names["lastName"])
    end)

    it("finds signal references in expressions", function()
      local content = [[<div data-text="$userName + ' ' + $lastName"></div>]]
      local result = workspace.scan_file_for_signals(content, "test.html")
      assert.is_not_nil(result)
      assert.is_true(#result >= 2)
    end)

    it("deduplicates signal names", function()
      local content = [[
<div data-text="$x + $x + $x"></div>
]]
      local result = workspace.scan_file_for_signals(content, "test.html")
      -- Deduplicate by name
      local names = {}
      for _, sig in ipairs(result) do
        names[sig.name] = true
      end
      -- At least 1 unique name
      local count = 0
      for _ in pairs(names) do count = count + 1 end
      assert.are_equal(1, count)
    end)

    it("tracks source file in results", function()
      local content = [[<div data-signals:mySignal="true"></div>]]
      local result = workspace.scan_file_for_signals(content, "/path/to/file.html")
      assert.are_equal(1, #result)
      assert.are_equal("/path/to/file.html", result[1].file)
    end)

    it("tracks line number in results", function()
      local content = "line1\n<div data-signals:mySignal=\"true\"></div>\nline3"
      local result = workspace.scan_file_for_signals(content, "test.html")
      assert.are_equal(1, #result)
      assert.are_equal(2, result[1].lnum)
    end)

    it("finds data-computed signals as definitions", function()
      local content = [[
<div data-signals:firstName="'John'"></div>
<div data-signals:lastName="'Doe'"></div>
<div data-computed:fullName="$firstName + ' ' + $lastName"></div>
]]
      local result = workspace.scan_file_for_signals(content, "test.html")
      local by_name = {}
      for _, sig in ipairs(result) do
        by_name[sig.name] = sig
      end
      assert.is_not_nil(by_name["fullName"])
      assert.are_equal("definition", by_name["fullName"].kind)
    end)

    it("finds data-bind signals as definitions", function()
      local content = [[<input data-bind:value="$userName" />]]
      local result = workspace.scan_file_for_signals(content, "test.html")
      local by_name = {}
      for _, sig in ipairs(result) do
        by_name[sig.name] = sig
      end
      -- "value" from data-bind:value is a definition
      assert.is_not_nil(by_name["value"])
      assert.are_equal("definition", by_name["value"].kind)
    end)

    it("finds data-ref signals as definitions", function()
      local content = [[<div data-ref:myDiv></div>]]
      local result = workspace.scan_file_for_signals(content, "test.html")
      local by_name = {}
      for _, sig in ipairs(result) do
        by_name[sig.name] = sig
      end
      assert.is_not_nil(by_name["myDiv"])
      assert.are_equal("definition", by_name["myDiv"].kind)
    end)
  end)

  describe("signal_store", function()
    it("stores and retrieves signals from multiple files", function()
      local store = workspace.create_store()
      store:update_file("a.html", {
        { name = "x", file = "a.html", lnum = 1 },
        { name = "y", file = "a.html", lnum = 2 },
      })
      store:update_file("b.html", {
        { name = "y", file = "b.html", lnum = 1 },
        { name = "z", file = "b.html", lnum = 1 },
      })
      local all = store:get_all_names()
      table.sort(all)
      assert.are_same({"x", "y", "z"}, all)
    end)

    it("removes signals when file is updated", function()
      local store = workspace.create_store()
      store:update_file("a.html", {
        { name = "old", file = "a.html", lnum = 1 },
      })
      store:update_file("a.html", {
        { name = "new", file = "a.html", lnum = 1 },
      })
      local all = store:get_all_names()
      assert.are_same({"new"}, all)
    end)

    it("finds definitions for a signal name", function()
      local store = workspace.create_store()
      store:update_file("a.html", {
        { name = "x", file = "a.html", lnum = 5, col = 10, kind = "definition" },
      })
      store:update_file("b.html", {
        { name = "x", file = "b.html", lnum = 3, col = 5, kind = "definition" },
      })
      local defs = store:find_definitions("x")
      assert.are_equal(2, #defs)
    end)

    it("returns empty for unknown signal", function()
      local store = workspace.create_store()
      local defs = store:find_definitions("nonexistent")
      assert.are_equal(0, #defs)
    end)

    it("clears all data", function()
      local store = workspace.create_store()
      store:update_file("a.html", {
        { name = "x", file = "a.html", lnum = 1 },
      })
      store:clear()
      local all = store:get_all_names()
      assert.are_equal(0, #all)
    end)
  end)

  describe("supported_patterns", function()
    it("includes html extensions", function()
      local patterns = workspace.supported_patterns
      assert.is_not_nil(patterns)
      local found_html = false
      for _, p in ipairs(patterns) do
        if p:find("%.html") then found_html = true end
      end
      assert.is_true(found_html)
    end)
  end)
end)
