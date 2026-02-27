-- tests/event_types_spec.lua
-- Tests for event type narrowing — evt.* completions based on event key

package.path = "./lua/?.lua;" .. package.path

describe("event type narrowing", function()
  local data, completion

  setup(function()
    data = require("datastar.data")
    completion = require("datastar.completion")
  end)

  describe("data.event_interfaces", function()
    it("maps click to MouseEvent", function()
      assert.is_not_nil(data.event_interfaces)
      assert.are_equal("MouseEvent", data.event_interfaces["click"])
    end)

    it("maps keydown to KeyboardEvent", function()
      assert.are_equal("KeyboardEvent", data.event_interfaces["keydown"])
    end)

    it("maps submit to SubmitEvent", function()
      assert.are_equal("SubmitEvent", data.event_interfaces["submit"])
    end)

    it("maps input to InputEvent", function()
      assert.are_equal("InputEvent", data.event_interfaces["input"])
    end)

    it("maps focus to FocusEvent", function()
      assert.are_equal("FocusEvent", data.event_interfaces["focus"])
    end)

    it("maps wheel to WheelEvent", function()
      assert.are_equal("WheelEvent", data.event_interfaces["wheel"])
    end)

    it("maps touchstart to TouchEvent", function()
      assert.are_equal("TouchEvent", data.event_interfaces["touchstart"])
    end)

    it("maps animationend to AnimationEvent", function()
      assert.are_equal("AnimationEvent", data.event_interfaces["animationend"])
    end)

    it("maps transitionend to TransitionEvent", function()
      assert.are_equal("TransitionEvent", data.event_interfaces["transitionend"])
    end)

    it("maps dragstart to DragEvent", function()
      assert.are_equal("DragEvent", data.event_interfaces["dragstart"])
    end)
  end)

  describe("data.event_properties", function()
    it("KeyboardEvent has key, code, ctrlKey", function()
      local props = data.event_properties["KeyboardEvent"]
      assert.is_not_nil(props)
      local set = {}
      for _, p in ipairs(props) do set[p.name] = true end
      assert.is_true(set["key"])
      assert.is_true(set["code"])
      assert.is_true(set["ctrlKey"])
    end)

    it("MouseEvent has clientX, clientY, button", function()
      local props = data.event_properties["MouseEvent"]
      assert.is_not_nil(props)
      local set = {}
      for _, p in ipairs(props) do set[p.name] = true end
      assert.is_true(set["clientX"])
      assert.is_true(set["clientY"])
      assert.is_true(set["button"])
    end)

    it("SubmitEvent has submitter", function()
      local props = data.event_properties["SubmitEvent"]
      assert.is_not_nil(props)
      local set = {}
      for _, p in ipairs(props) do set[p.name] = true end
      assert.is_true(set["submitter"])
    end)

    it("all interfaces have base Event properties", function()
      local base_props = data.event_properties["Event"]
      assert.is_not_nil(base_props)
      local set = {}
      for _, p in ipairs(base_props) do set[p.name] = true end
      assert.is_true(set["type"])
      assert.is_true(set["target"])
      assert.is_true(set["preventDefault"])
    end)
  end)

  describe("evt. completion in VALUE context", function()
    it("completes evt. properties for keydown event", function()
      local ctx = {
        kind = "VALUE",
        plugin = "on",
        partial = "evt.",
        event_key = "keydown",
      }
      local items = completion.resolve(ctx)
      local labels = {}
      for _, item in ipairs(items) do labels[item.label] = true end
      assert.is_true(labels["evt.key"], "should have evt.key for keydown")
      assert.is_true(labels["evt.code"], "should have evt.code for keydown")
      assert.is_true(labels["evt.ctrlKey"], "should have evt.ctrlKey for keydown")
      -- Should NOT have mouse-specific props
      assert.is_nil(labels["evt.clientX"])
    end)

    it("completes evt. properties for click event", function()
      local ctx = {
        kind = "VALUE",
        plugin = "on",
        partial = "evt.",
        event_key = "click",
      }
      local items = completion.resolve(ctx)
      local labels = {}
      for _, item in ipairs(items) do labels[item.label] = true end
      assert.is_true(labels["evt.clientX"], "should have evt.clientX for click")
      assert.is_true(labels["evt.button"], "should have evt.button for click")
      -- Should NOT have keyboard-specific props
      assert.is_nil(labels["evt.key"])
    end)

    it("includes base Event properties for all events", function()
      local ctx = {
        kind = "VALUE",
        plugin = "on",
        partial = "evt.",
        event_key = "click",
      }
      local items = completion.resolve(ctx)
      local labels = {}
      for _, item in ipairs(items) do labels[item.label] = true end
      assert.is_true(labels["evt.type"], "should include base Event.type")
      assert.is_true(labels["evt.target"], "should include base Event.target")
      assert.is_true(labels["evt.preventDefault"], "should include preventDefault")
    end)

    it("falls back to base Event for unknown events", function()
      local ctx = {
        kind = "VALUE",
        plugin = "on",
        partial = "evt.",
        event_key = "customevent",
      }
      local items = completion.resolve(ctx)
      local labels = {}
      for _, item in ipairs(items) do labels[item.label] = true end
      assert.is_true(labels["evt.type"], "should have base Event.type")
      assert.is_true(labels["evt.target"], "should have base Event.target")
    end)

    it("filters evt properties by partial text", function()
      local ctx = {
        kind = "VALUE",
        plugin = "on",
        partial = "evt.cl",
        event_key = "click",
      }
      local items = completion.resolve(ctx)
      assert.is_true(#items > 0)
      for _, item in ipairs(items) do
        assert.is_truthy(item.label:find("cl", 1, true), "should match partial: " .. item.label)
      end
    end)

    it("context parser extracts event_key from data-on:keydown", function()
      local line = '  data-on:keydown="evt.'
      local ctx = completion.detect_context(line, #line)
      assert.is_not_nil(ctx)
      assert.are_equal("VALUE", ctx.kind)
      assert.are_equal("on", ctx.plugin)
      assert.are_equal("keydown", ctx.event_key)
    end)

    it("context parser extracts event_key from data-on:click", function()
      local line = '  data-on:click="evt.'
      local ctx = completion.detect_context(line, #line)
      assert.is_not_nil(ctx)
      assert.are_equal("click", ctx.event_key)
    end)
  end)
end)
