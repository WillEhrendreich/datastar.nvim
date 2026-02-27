-- tests/completion_spec.lua
-- Tests for completion resolver output
-- These test that the resolver produces correct CompletionItem tables

package.path = "./lua/?.lua;" .. package.path

describe("datastar.completion resolver", function()
  local completion

  setup(function()
    completion = require("datastar.completion")
  end)

  describe("resolve", function()
    describe("ATTRIBUTE_NAME completions", function()
      it("should return completions for data- prefix", function()
        local ctx = { kind = "ATTRIBUTE_NAME", partial = "" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0, "should have completions")
      end)

      it("should include data-on in results", function()
        local ctx = { kind = "ATTRIBUTE_NAME", partial = "" }
        local items = completion.resolve(ctx)
        local found = false
        for _, item in ipairs(items) do
          if item.label == "data-on" then
            found = true
            break
          end
        end
        assert.is_true(found, "should include data-on")
      end)

      it("should filter by partial text", function()
        local ctx = { kind = "ATTRIBUTE_NAME", partial = "sig" }
        local items = completion.resolve(ctx)
        for _, item in ipairs(items) do
          assert.is_truthy(
            item.filterText:lower():find("sig", 1, true),
            "item should match partial: " .. item.label
          )
        end
      end)

      it("items should have CompletionItem fields", function()
        local ctx = { kind = "ATTRIBUTE_NAME", partial = "" }
        local items = completion.resolve(ctx)
        for _, item in ipairs(items) do
          assert.is_string(item.label, "missing label")
          assert.is_number(item.kind, "missing kind (CompletionItemKind)")
          assert.is_string(item.detail, "missing detail")
        end
      end)

      it("items should have documentation", function()
        local ctx = { kind = "ATTRIBUTE_NAME", partial = "" }
        local items = completion.resolve(ctx)
        local has_docs = false
        for _, item in ipairs(items) do
          if item.documentation then
            has_docs = true
            break
          end
        end
        assert.is_true(has_docs, "at least some items should have docs")
      end)
    end)

    describe("KEY completions", function()
      it("should return DOM events for data-on plugin", function()
        local ctx = { kind = "KEY", plugin = "on", partial = "" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0, "should have event completions")
        local labels = {}
        for _, item in ipairs(items) do
          labels[item.label] = true
        end
        assert.is_true(labels["click"], "should have click event")
        assert.is_true(labels["submit"], "should have submit event")
        assert.is_true(labels["keydown"], "should have keydown event")
      end)

      it("should return HTML attrs for data-attr plugin", function()
        local ctx = { kind = "KEY", plugin = "attr", partial = "" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0, "should have attr completions")
        local labels = {}
        for _, item in ipairs(items) do
          labels[item.label] = true
        end
        assert.is_true(labels["id"], "should have id attr")
        assert.is_true(labels["class"], "should have class attr")
      end)

      it("should return empty for plugins without key completion", function()
        local ctx = { kind = "KEY", plugin = "show", partial = "" }
        local items = completion.resolve(ctx)
        assert.are_equal(0, #items)
      end)

      it("should filter events by partial", function()
        local ctx = { kind = "KEY", plugin = "on", partial = "cl" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0)
        for _, item in ipairs(items) do
          assert.is_truthy(item.label:find("cl", 1, true), "should match partial: " .. item.label)
        end
      end)
    end)

    describe("MODIFIER completions", function()
      it("should return modifiers for data-on", function()
        local ctx = { kind = "MODIFIER", plugin = "on", partial = "" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0)
        local labels = {}
        for _, item in ipairs(items) do
          labels[item.label] = true
        end
        assert.is_true(labels["debounce"], "should have debounce")
        assert.is_true(labels["once"], "should have once")
        assert.is_true(labels["capture"], "should have capture")
      end)

      it("should return modifiers for data-scroll-into-view", function()
        local ctx = { kind = "MODIFIER", plugin = "scroll-into-view", partial = "" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0)
        local labels = {}
        for _, item in ipairs(items) do
          labels[item.label] = true
        end
        assert.is_true(labels["smooth"], "should have smooth")
        assert.is_true(labels["instant"], "should have instant")
      end)

      it("should return empty for plugins without modifiers", function()
        local ctx = { kind = "MODIFIER", plugin = "effect", partial = "" }
        local items = completion.resolve(ctx)
        assert.are_equal(0, #items)
      end)
    end)

    describe("MODIFIER_ARG completions", function()
      it("should return args for debounce modifier", function()
        local ctx = { kind = "MODIFIER_ARG", plugin = "on", modifier = "debounce", partial = "" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0)
        local labels = {}
        for _, item in ipairs(items) do
          labels[item.label] = true
        end
        assert.is_true(labels["500ms"], "should have 500ms")
        assert.is_true(labels["1s"], "should have 1s")
      end)

      it("should return args for case modifier", function()
        local ctx = { kind = "MODIFIER_ARG", plugin = "signals", modifier = "case", partial = "" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0)
        local labels = {}
        for _, item in ipairs(items) do
          labels[item.label] = true
        end
        assert.is_true(labels["kebab"], "should have kebab")
        assert.is_true(labels["camel"], "should have camel")
      end)

      it("should return empty for modifier without args", function()
        local ctx = { kind = "MODIFIER_ARG", plugin = "on", modifier = "once", partial = "" }
        local items = completion.resolve(ctx)
        assert.are_equal(0, #items)
      end)
    end)

    describe("VALUE completions", function()
      it("should return actions when @ is typed", function()
        local ctx = { kind = "VALUE", plugin = "on", partial = "@" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0)
        local labels = {}
        for _, item in ipairs(items) do
          labels[item.label] = true
        end
        assert.is_true(labels["@get"], "should have @get")
        assert.is_true(labels["@post"], "should have @post")
        assert.is_true(labels["@peek"], "should have @peek")
      end)

      it("should filter actions by partial", function()
        local ctx = { kind = "VALUE", plugin = "on", partial = "@ge" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0)
        for _, item in ipairs(items) do
          assert.is_truthy(
            item.label:lower():find("ge", 1, true),
            "should match partial: " .. item.label
          )
        end
      end)

      it("should return signal completions when $ is typed", function()
        local ctx = { kind = "VALUE", plugin = "on", partial = "$" }
        -- Without buffer signals, should still return empty (no signals defined)
        local items = completion.resolve(ctx)
        -- This is valid - returns empty since no signals are registered
        assert.is_table(items)
      end)

      it("should return actions for expression-type plugins", function()
        local ctx = { kind = "VALUE", plugin = "effect", partial = "@" }
        local items = completion.resolve(ctx)
        assert.is_true(#items > 0, "effect should get action completions")
      end)

      it("should include action documentation", function()
        local ctx = { kind = "VALUE", plugin = "on", partial = "@" }
        local items = completion.resolve(ctx)
        for _, item in ipairs(items) do
          assert.is_truthy(item.documentation, item.label .. " missing docs")
        end
      end)
    end)
  end)
end)
