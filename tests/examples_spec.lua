-- tests/examples_spec.lua
-- Tests for curated examples in hover

package.path = "./lua/?.lua;" .. package.path

describe("datastar.examples", function()
  local examples

  setup(function()
    examples = require("datastar.examples")
  end)

  describe("get_examples", function()
    it("returns examples for on plugin", function()
      local ex = examples.get_examples("on")
      assert.is_not_nil(ex)
      assert.is_true(#ex > 0)
      assert.is_string(ex[1].code)
      assert.is_string(ex[1].title)
    end)

    it("returns examples for signals plugin", function()
      local ex = examples.get_examples("signals")
      assert.is_not_nil(ex)
      assert.is_true(#ex > 0)
    end)

    it("returns examples for text plugin", function()
      local ex = examples.get_examples("text")
      assert.is_not_nil(ex)
      assert.is_true(#ex > 0)
    end)

    it("returns examples for show plugin", function()
      local ex = examples.get_examples("show")
      assert.is_not_nil(ex)
      assert.is_true(#ex > 0)
    end)

    it("returns examples for class plugin", function()
      local ex = examples.get_examples("class")
      assert.is_not_nil(ex)
      assert.is_true(#ex > 0)
    end)

    it("returns examples for ref plugin", function()
      local ex = examples.get_examples("ref")
      assert.is_not_nil(ex)
      assert.is_true(#ex > 0)
    end)

    it("returns empty table for unknown plugin", function()
      local ex = examples.get_examples("nonexistent")
      assert.is_not_nil(ex)
      assert.are_equal(0, #ex)
    end)

    it("has correct example structure", function()
      local ex = examples.get_examples("on")
      local first = ex[1]
      assert.is_string(first.title)
      assert.is_string(first.code)
      -- Code should contain data- attribute
      assert.truthy(first.code:find("data%-"))
    end)
  end)

  describe("get_modifier_example", function()
    it("returns example for debounce modifier", function()
      local ex = examples.get_modifier_example("on", "debounce")
      assert.is_not_nil(ex)
      assert.is_string(ex.code)
    end)

    it("returns example for once modifier", function()
      local ex = examples.get_modifier_example("on", "once")
      assert.is_not_nil(ex)
    end)

    it("returns nil for unknown modifier", function()
      local ex = examples.get_modifier_example("on", "nonexistent")
      assert.is_nil(ex)
    end)
  end)

  describe("format_hover_examples", function()
    it("formats examples as markdown", function()
      local md = examples.format_hover_examples("on")
      assert.is_string(md)
      assert.truthy(md:find("```html"))
      assert.truthy(md:find("Example"))
    end)

    it("returns empty string for no examples", function()
      local md = examples.format_hover_examples("nonexistent")
      assert.are_equal("", md)
    end)
  end)
end)
