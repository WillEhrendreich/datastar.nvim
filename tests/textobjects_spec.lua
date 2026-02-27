-- tests/textobjects_spec.lua
-- Tests for Datastar treesitter-like textobjects (modifier/key selection)

package.path = "./lua/?.lua;" .. package.path

describe("datastar.textobjects", function()
  local textobjects

  setup(function()
    textobjects = require("datastar.textobjects")
  end)

  describe("find_modifier_at_col", function()
    it("finds modifier segment under cursor", function()
      local line = "data-on:click__debounce.500ms__once"
      -- cursor on "debounce" (col 18, 0-based)
      local result = textobjects.find_modifier_at_col(line, 18)
      assert.is_not_nil(result)
      assert.are_equal("debounce.500ms", result.text)
      assert.is_number(result.start_col)
      assert.is_number(result.end_col)
    end)

    it("finds last modifier in chain", function()
      local line = "data-on:click__debounce__once"
      -- cursor on "once" (col 25, 0-based)
      local result = textobjects.find_modifier_at_col(line, 25)
      assert.is_not_nil(result)
      assert.are_equal("once", result.text)
    end)

    it("returns nil when not on a modifier", function()
      local line = "data-on:click__debounce"
      -- cursor on "click" (col 11)
      local result = textobjects.find_modifier_at_col(line, 11)
      assert.is_nil(result)
    end)

    it("includes __ delimiter for outer modifier (am)", function()
      local line = "data-on:click__debounce.500ms__once"
      local result = textobjects.find_modifier_at_col(line, 18)
      assert.is_not_nil(result)
      assert.is_number(result.outer_start)
      assert.is_number(result.outer_end)
      -- outer should include leading __
      assert.is_true(result.outer_start < result.start_col)
    end)
  end)

  describe("find_key_at_col", function()
    it("finds key segment under cursor", function()
      local line = "data-on:click__debounce"
      -- cursor on "click" (col 10, 0-based)
      local result = textobjects.find_key_at_col(line, 10)
      assert.is_not_nil(result)
      assert.are_equal("click", result.text)
    end)

    it("returns nil when no key present", function()
      local line = "data-show__once"
      local result = textobjects.find_key_at_col(line, 7)
      assert.is_nil(result)
    end)

    it("finds key with colon delimiter", function()
      local line = "data-signals:userName"
      local result = textobjects.find_key_at_col(line, 16)
      assert.is_not_nil(result)
      assert.are_equal("userName", result.text)
    end)

    it("outer key includes colon delimiter", function()
      local line = "data-signals:userName"
      local result = textobjects.find_key_at_col(line, 16)
      assert.is_not_nil(result)
      assert.is_true(result.outer_start < result.start_col)
    end)
  end)

  describe("next_modifier", function()
    it("finds next modifier from cursor position", function()
      local line = "data-on:click__debounce__once__capture"
      -- cursor at start of line
      local result = textobjects.next_modifier(line, 0)
      assert.is_not_nil(result)
      assert.are_equal("debounce", result.name)
    end)

    it("finds next modifier after current one", function()
      local line = "data-on:click__debounce__once__capture"
      -- cursor on debounce
      local result = textobjects.next_modifier(line, 20)
      assert.is_not_nil(result)
      assert.are_equal("once", result.name)
    end)

    it("returns nil at end of chain", function()
      local line = "data-on:click__debounce__once"
      local result = textobjects.next_modifier(line, 26)
      assert.is_nil(result)
    end)
  end)

  describe("prev_modifier", function()
    it("finds previous modifier from cursor position", function()
      local line = "data-on:click__debounce__once__capture"
      -- cursor on capture
      local result = textobjects.prev_modifier(line, 33)
      assert.is_not_nil(result)
      assert.are_equal("once", result.name)
    end)

    it("returns nil at beginning of chain", function()
      local line = "data-on:click__debounce__once"
      local result = textobjects.prev_modifier(line, 16)
      assert.is_nil(result)
    end)
  end)

  describe("delete_modifier_text", function()
    it("removes a middle modifier from chain", function()
      local line = "data-on:click__debounce__once__capture"
      local result = textobjects.delete_modifier_text(line, 25) -- on "once"
      assert.is_not_nil(result)
      assert.are_equal("data-on:click__debounce__capture", result)
    end)

    it("removes last modifier from chain", function()
      local line = "data-on:click__debounce__once"
      local result = textobjects.delete_modifier_text(line, 25) -- on "once"
      assert.is_not_nil(result)
      assert.are_equal("data-on:click__debounce", result)
    end)

    it("removes only modifier from chain", function()
      local line = "data-on:click__once"
      local result = textobjects.delete_modifier_text(line, 16) -- on "once"
      assert.is_not_nil(result)
      assert.are_equal("data-on:click", result)
    end)
  end)
end)
