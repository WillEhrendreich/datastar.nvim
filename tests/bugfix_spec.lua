-- Tests for bugs found during panel drive-testing
package.path = "./lua/?.lua;" .. package.path

describe("Bug fixes", function()

  -- Bug 1: scan_signals_with_locations returns 0-based lnum
  -- goto_definition must convert to 1-based for nvim_win_set_cursor
  describe("signal location lnum is 0-based", function()
    local completion = require("datastar.completion")

    it("scan_signals_with_locations returns 0-based lnum", function()
      local lines = {
        '<div data-signals:userName="John">',  -- line 1 in editor, lnum=0
        '<span>$userName</span>',               -- line 2 in editor, lnum=1
      }
      local locs = completion.scan_signals_with_locations(lines)
      assert.is_true(#locs > 0)
      -- First line should be lnum=0 (0-based indexing)
      assert.equal(0, locs[1].lnum)
    end)

    it("signal on second line has lnum=1", function()
      local lines = {
        '<div>hello</div>',
        '<div data-signals:count="0">',  -- line 2 in editor, lnum=1
      }
      local locs = completion.scan_signals_with_locations(lines)
      assert.is_true(#locs > 0)
      assert.equal(1, locs[1].lnum)
    end)
  end)

  -- Bug 2: _configured flag never set in setup()
  -- Can't test init.lua in busted (needs vim), so this is verified manually in Neovim

  -- Bug 3: Diagnostics autocmd uses pattern for TextChanged events
  -- TextChanged doesn't match on filetype patterns; it matches on buffer name globs
  -- This is a design issue that requires FileType-based wiring (tested via code review)

  -- Bug 4: Signal completions never appear because ctx.signals is never populated
  describe("signal completions in VALUE context", function()
    local completion = require("datastar.completion")

    it("_resolve_value returns signals when ctx.signals is populated", function()
      local items = completion._resolve_value({
        partial = "$",
        signals = { "userName", "count" },
      })
      assert.is_true(#items > 0)
      local labels = {}
      for _, item in ipairs(items) do labels[item.label] = true end
      assert.is_true(labels["$userName"])
      assert.is_true(labels["$count"])
    end)

    it("_resolve_value returns no signals when ctx.signals is empty", function()
      local items = completion._resolve_value({
        partial = "$",
        signals = {},
      })
      assert.equal(0, #items)
    end)

    it("_resolve_value returns no signals when ctx.signals is nil", function()
      local items = completion._resolve_value({
        partial = "$",
      })
      assert.equal(0, #items)
    end)

    it("resolve with VALUE kind includes signals when ctx has them", function()
      local items = completion.resolve({
        kind = "VALUE",
        plugin = "on",
        partial = "",
        signals = { "foo", "bar" },
      })
      local has_signal = false
      for _, item in ipairs(items) do
        if item.label == "$foo" or item.label == "$bar" then
          has_signal = true
        end
      end
      assert.is_true(has_signal)
    end)

    it("resolve with VALUE kind returns both signals and actions", function()
      local items = completion.resolve({
        kind = "VALUE",
        plugin = "on",
        partial = "",
        signals = { "mySignal" },
      })
      local has_signal = false
      local has_action = false
      for _, item in ipairs(items) do
        if item.label == "$mySignal" then has_signal = true end
        if item.label:sub(1, 1) == "@" then has_action = true end
      end
      assert.is_true(has_signal)
      assert.is_true(has_action)
    end)

    -- Test that omnifunc_items can return signal completions
    -- This requires that omnifunc_items somehow gets signals into the context
    -- We need a way to inject buffer signals into the completion pipeline
    it("omnifunc_items_with_signals returns signal items", function()
      local line = '<div data-on:click="$'
      local col = #line
      -- After fix: omnifunc_items accepts optional signals list
      local items = completion.omnifunc_items(line, col, "$", { "userName", "count" })
      local found = false
      for _, item in ipairs(items) do
        if item.word == "$userName" or item.word == "$count" then
          found = true
        end
      end
      assert.is_true(found, "Expected signal completions in omnifunc results")
    end)

    it("omnifunc_items still works without signals parameter", function()
      local line = '<div data-on:click="@'
      local col = #line
      local items = completion.omnifunc_items(line, col, "@")
      assert.is_true(#items > 0, "Expected action completions")
    end)
  end)
end)
