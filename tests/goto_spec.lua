-- tests/goto_spec.lua
-- Tests for signal goto definition and route goto definition

package.path = "./lua/?.lua;" .. package.path

describe("signal goto definition", function()
  local completion

  setup(function()
    completion = require("datastar.completion")
  end)

  describe("scan_signals_with_locations", function()
    it("returns signal names with line numbers", function()
      local lines = {
        '<div data-signals:name="\'Will\'">',
        '<input data-bind:email />',
        '<span data-ref:mySpan></span>',
      }
      local signals = completion.scan_signals_with_locations(lines)
      assert.is_true(#signals >= 3)
      -- Check structure
      for _, sig in ipairs(signals) do
        assert.is_string(sig.name)
        assert.is_number(sig.lnum)
        assert.is_number(sig.col)
      end
    end)

    it("reports correct line numbers (0-based)", function()
      local lines = {
        '<div class="foo">',
        '<input data-bind:email />',
        '<div data-signals:count="0">',
      }
      local signals = completion.scan_signals_with_locations(lines)
      local by_name = {}
      for _, s in ipairs(signals) do by_name[s.name] = s end
      assert.is_not_nil(by_name["email"])
      assert.are_equal(1, by_name["email"].lnum)
      assert.is_not_nil(by_name["count"])
      assert.are_equal(2, by_name["count"].lnum)
    end)

    it("reports correct column (0-based, at start of data- attr)", function()
      local lines = {
        '  <input data-bind:email />',
      }
      local signals = completion.scan_signals_with_locations(lines)
      assert.is_true(#signals >= 1)
      assert.are_equal("email", signals[1].name)
      -- "data-bind:email" starts at col 9 (0-based)
      assert.are_equal(9, signals[1].col)
    end)

    it("finds object-form signals with line numbers", function()
      local lines = {
        '  <div data-signals="{count: 0, name: \'Will\'}">',
      }
      local signals = completion.scan_signals_with_locations(lines)
      assert.is_true(#signals >= 2)
      local by_name = {}
      for _, s in ipairs(signals) do by_name[s.name] = s end
      assert.is_not_nil(by_name["count"])
      assert.is_not_nil(by_name["name"])
      assert.are_equal(0, by_name["count"].lnum)
    end)

    it("deduplicates signals", function()
      local lines = {
        '<div data-signals:name="Will">',
        '<div data-signals:name="Other">',
      }
      local signals = completion.scan_signals_with_locations(lines)
      -- Should only return first occurrence
      local count = 0
      for _, s in ipairs(signals) do
        if s.name == "name" then count = count + 1 end
      end
      assert.are_equal(1, count)
      -- First occurrence wins
      assert.are_equal(0, signals[1].lnum)
    end)
  end)

  describe("find_signal_at_cursor", function()
    it("finds $signal reference under cursor", function()
      local line = 'data-show="$isVisible"'
      local result = completion.find_signal_at_cursor(line, 13) -- on 'V' of isVisible
      assert.is_not_nil(result)
      assert.are_equal("isVisible", result)
    end)

    it("finds $signal at start of dollar sign", function()
      local line = 'data-show="$isVisible"'
      local result = completion.find_signal_at_cursor(line, 11) -- on '$'
      assert.is_not_nil(result)
      assert.are_equal("isVisible", result)
    end)

    it("finds $$rawSignal reference", function()
      local line = 'data-text="$$rawVal"'
      local result = completion.find_signal_at_cursor(line, 13)
      assert.is_not_nil(result)
      assert.are_equal("rawVal", result)
    end)

    it("returns nil when not on a signal", function()
      local line = 'data-on:click="@get(\'/api\')"'
      local result = completion.find_signal_at_cursor(line, 17)
      assert.is_nil(result)
    end)

    it("handles multiple signals on same line", function()
      local line = 'data-show="$a && $b"'
      local result = completion.find_signal_at_cursor(line, 18) -- on 'b'
      assert.is_not_nil(result)
      assert.are_equal("b", result)
    end)
  end)
end)
