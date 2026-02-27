-- tests/omnifunc_spec.lua
-- Tests for omnifunc integration and cmp source adapters

package.path = "./lua/?.lua;" .. package.path

describe("datastar.omnifunc", function()
  local completion

  setup(function()
    completion = require("datastar.completion")
  end)

  describe("omnifunc_items", function()
    it("returns attribute completions for data- prefix", function()
      local items = completion.omnifunc_items("  data-", 7)
      assert.is_true(#items > 0)
    end)

    it("returns key completions for data-on:", function()
      local items = completion.omnifunc_items("  data-on:", 10)
      assert.is_true(#items > 0)
      local labels = {}
      for _, item in ipairs(items) do
        labels[item.word or item.label] = true
      end
      assert.is_true(labels["click"] or labels["data-on:click"])
    end)

    it("returns modifier completions for data-on:click__", function()
      local items = completion.omnifunc_items("  data-on:click__", 17)
      assert.is_true(#items > 0)
    end)

    it("returns action completions for value context", function()
      local items = completion.omnifunc_items('  data-on:click="@', 18)
      assert.is_true(#items > 0)
    end)

    it("returns empty for non-datastar context", function()
      local items = completion.omnifunc_items("  <div>hello</div>", 18)
      assert.are_equal(0, #items)
    end)

    it("items have vim-compatible word field", function()
      local items = completion.omnifunc_items("  data-", 7)
      for _, item in ipairs(items) do
        assert.is_string(item.word, "item missing word field")
      end
    end)

    it("items have menu and info fields", function()
      local items = completion.omnifunc_items("  data-", 7)
      for _, item in ipairs(items) do
        assert.is_string(item.menu, "item missing menu field: " .. (item.word or "?"))
      end
    end)
  end)
end)

describe("datastar.cmp_source", function()
  local cmp_source

  setup(function()
    cmp_source = require("datastar.cmp_source")
  end)

  it("has a name", function()
    local src = cmp_source.new()
    assert.are_equal("datastar", src:get_debug_name())
  end)

  it("is available for html filetype", function()
    local src = cmp_source.new()
    assert.is_true(src:is_available("html"))
  end)

  it("is not available without filetype", function()
    local src = cmp_source.new()
    assert.is_false(src:is_available())
  end)

  it("has trigger characters", function()
    local src = cmp_source.new()
    local chars = src:get_trigger_characters()
    assert.is_table(chars)
    assert.is_true(#chars > 0)
    -- Should include key triggers
    local set = {}
    for _, c in ipairs(chars) do set[c] = true end
    assert.is_true(set["-"], "should trigger on -")
    assert.is_true(set[":"], "should trigger on :")
    assert.is_true(set["@"], "should trigger on @")
    assert.is_true(set["$"], "should trigger on $")
  end)
end)
