-- tests/diagnostics_spec.lua
-- Tests for modifier chain validation and expression syntax validation

package.path = "./lua/?.lua;" .. package.path

describe("datastar.diagnostics", function()
  local diagnostics

  setup(function()
    diagnostics = require("datastar.diagnostics")
  end)

  describe("validate_modifiers", function()
    it("returns empty for valid single modifier", function()
      local results = diagnostics.validate_modifiers("data-on:click__once")
      assert.are_equal(0, #results)
    end)

    it("returns empty for valid modifier chain", function()
      local results = diagnostics.validate_modifiers("data-on:click__debounce__once__capture")
      assert.are_equal(0, #results)
    end)

    it("detects duplicate modifier", function()
      local results = diagnostics.validate_modifiers("data-on:click__debounce__debounce")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("uplicate"))
    end)

    it("detects invalid modifier for plugin", function()
      local results = diagnostics.validate_modifiers("data-bind__once")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("not valid"))
    end)

    it("detects conflicting modifiers smooth+instant", function()
      local results = diagnostics.validate_modifiers("data-scroll-into-view__smooth__instant")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("onflict"))
    end)

    it("detects unknown modifier", function()
      local results = diagnostics.validate_modifiers("data-on:click__banana")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("not valid"))
    end)

    it("returns empty for attribute without modifiers", function()
      local results = diagnostics.validate_modifiers("data-on:click")
      assert.are_equal(0, #results)
    end)

    it("returns empty for non-datastar attribute", function()
      local results = diagnostics.validate_modifiers("class='foo'")
      assert.are_equal(0, #results)
    end)

    it("returns empty for unknown plugin", function()
      local results = diagnostics.validate_modifiers("data-foobar__once")
      assert.are_equal(0, #results)
    end)

    it("detects duplicate modifier arg", function()
      local results = diagnostics.validate_modifiers("data-on:click__debounce.leading.leading")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("uplicate"))
    end)

    it("allows valid modifier with args", function()
      local results = diagnostics.validate_modifiers("data-on:click__debounce.500ms.leading")
      assert.are_equal(0, #results)
    end)

    it("handles modifier with no valid modifiers defined for plugin", function()
      local results = diagnostics.validate_modifiers("data-effect__once")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("not valid"))
    end)
  end)

  describe("validate_line", function()
    it("returns diagnostics for all data- attrs on a line", function()
      local diags = diagnostics.validate_line('<div data-on:click__debounce__debounce="@get()">', 0)
      assert.is_true(#diags > 0)
      assert.is_number(diags[1].col)
      assert.is_number(diags[1].lnum)
    end)

    it("finds multiple issues on same line", function()
      local diags = diagnostics.validate_line(
        '<div data-on:click__banana data-scroll-into-view__smooth__instant>',
        0
      )
      assert.is_true(#diags >= 2)
    end)

    it("returns empty for clean line", function()
      local diags = diagnostics.validate_line('<div data-on:click__once="@get()">', 0)
      assert.are_equal(0, #diags)
    end)

    it("includes column offset for diagnostic position", function()
      local line = '  <div data-on:click__banana="@get()">'
      local diags = diagnostics.validate_line(line, 5)
      assert.is_true(#diags > 0)
      assert.are_equal(5, diags[1].lnum)
    end)
  end)
end)
