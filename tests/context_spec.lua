-- tests/context_spec.lua
-- Tests for cursor context detection in Datastar attributes
-- This MUST fail until completion.lua is implemented (RED phase)

package.path = "./lua/?.lua;" .. package.path

describe("datastar.completion context parser", function()
  local completion

  setup(function()
    completion = require("datastar.completion")
  end)

  describe("detect_context", function()
    -- ATTRIBUTE_NAME: cursor is typing the attribute name after data-
    describe("ATTRIBUTE_NAME context", function()
      it("detects data- prefix", function()
        local ctx = completion.detect_context('  data-', 7)
        assert.are_equal("ATTRIBUTE_NAME", ctx.kind)
      end)

      it("detects partial attribute name", function()
        local ctx = completion.detect_context('  data-on', 9)
        assert.are_equal("ATTRIBUTE_NAME", ctx.kind)
      end)

      it("detects partial with hyphen", function()
        local ctx = completion.detect_context('  data-on-int', 13)
        assert.are_equal("ATTRIBUTE_NAME", ctx.kind)
      end)

      it("detects after space in tag", function()
        local ctx = completion.detect_context('<div class="foo" data-s', 23)
        assert.are_equal("ATTRIBUTE_NAME", ctx.kind)
      end)

      it("returns the partial text typed so far", function()
        local ctx = completion.detect_context('  data-sig', 10)
        assert.are_equal("ATTRIBUTE_NAME", ctx.kind)
        assert.are_equal("sig", ctx.partial)
      end)

      it("returns empty partial for just data-", function()
        local ctx = completion.detect_context('  data-', 7)
        assert.are_equal("", ctx.partial)
      end)
    end)

    -- KEY: cursor is after data-plugin: typing the key
    describe("KEY context", function()
      it("detects key position for data-on:", function()
        local ctx = completion.detect_context('  data-on:', 10)
        assert.are_equal("KEY", ctx.kind)
        assert.are_equal("on", ctx.plugin)
      end)

      it("detects partial key", function()
        local ctx = completion.detect_context('  data-on:cli', 13)
        assert.are_equal("KEY", ctx.kind)
        assert.are_equal("on", ctx.plugin)
        assert.are_equal("cli", ctx.partial)
      end)

      it("detects key for data-attr:", function()
        local ctx = completion.detect_context('  data-attr:', 12)
        assert.are_equal("KEY", ctx.kind)
        assert.are_equal("attr", ctx.plugin)
      end)

      it("detects key for data-signals:", function()
        local ctx = completion.detect_context('  data-signals:', 15)
        assert.are_equal("KEY", ctx.kind)
        assert.are_equal("signals", ctx.plugin)
      end)

      it("detects key for data-class:", function()
        local ctx = completion.detect_context('  data-class:fon', 16)
        assert.are_equal("KEY", ctx.kind)
        assert.are_equal("class", ctx.plugin)
        assert.are_equal("fon", ctx.partial)
      end)

      it("detects nested key with colons", function()
        local ctx = completion.detect_context('  data-signals:user:', 20)
        assert.are_equal("KEY", ctx.kind)
        assert.are_equal("signals", ctx.plugin)
      end)
    end)

    -- MODIFIER: cursor is after __ typing a modifier
    describe("MODIFIER context", function()
      it("detects modifier position after __", function()
        local ctx = completion.detect_context('  data-on:click__', 17)
        assert.are_equal("MODIFIER", ctx.kind)
        assert.are_equal("on", ctx.plugin)
      end)

      it("detects partial modifier", function()
        local ctx = completion.detect_context('  data-on:click__deb', 20)
        assert.are_equal("MODIFIER", ctx.kind)
        assert.are_equal("on", ctx.plugin)
        assert.are_equal("deb", ctx.partial)
      end)

      it("detects second modifier after first", function()
        local ctx = completion.detect_context('  data-on:click__debounce.500ms__', 33)
        assert.are_equal("MODIFIER", ctx.kind)
        assert.are_equal("on", ctx.plugin)
      end)

      it("detects modifier for no-key plugin", function()
        local ctx = completion.detect_context('  data-init__', 13)
        assert.are_equal("MODIFIER", ctx.kind)
        assert.are_equal("init", ctx.plugin)
      end)

      it("detects modifier for scroll-into-view", function()
        local ctx = completion.detect_context('  data-scroll-into-view__', 25)
        assert.are_equal("MODIFIER", ctx.kind)
        assert.are_equal("scroll-into-view", ctx.plugin)
      end)
    end)

    -- MODIFIER_ARG: cursor is after __modifier. typing an argument
    describe("MODIFIER_ARG context", function()
      it("detects modifier arg position", function()
        local ctx = completion.detect_context('  data-on:click__debounce.', 26)
        assert.are_equal("MODIFIER_ARG", ctx.kind)
        assert.are_equal("on", ctx.plugin)
        assert.are_equal("debounce", ctx.modifier)
      end)

      it("detects partial modifier arg", function()
        local ctx = completion.detect_context('  data-on:click__debounce.500', 29)
        assert.are_equal("MODIFIER_ARG", ctx.kind)
        assert.are_equal("debounce", ctx.modifier)
        assert.are_equal("500", ctx.partial)
      end)

      it("detects case modifier arg", function()
        local ctx = completion.detect_context('  data-signals:foo__case.', 25)
        assert.are_equal("MODIFIER_ARG", ctx.kind)
        assert.are_equal("signals", ctx.plugin)
        assert.are_equal("case", ctx.modifier)
      end)
    end)

    -- VALUE: cursor is inside attribute value quotes
    describe("VALUE context", function()
      it("detects value position inside double quotes", function()
        local ctx = completion.detect_context('  data-on:click="', 17)
        assert.are_equal("VALUE", ctx.kind)
        assert.are_equal("on", ctx.plugin)
      end)

      it("detects value with partial content", function()
        local ctx = completion.detect_context('  data-on:click="@g', 19)
        assert.are_equal("VALUE", ctx.kind)
        assert.are_equal("on", ctx.plugin)
        assert.are_equal("@g", ctx.partial)
      end)

      it("detects value for data-show", function()
        local ctx = completion.detect_context('  data-show="$', 14)
        assert.are_equal("VALUE", ctx.kind)
        assert.are_equal("show", ctx.plugin)
        assert.are_equal("$", ctx.partial)
      end)

      it("detects value position inside single quotes", function()
        local ctx = completion.detect_context("  data-on:click='@g", 19)
        assert.are_equal("VALUE", ctx.kind)
      end)

      it("does NOT detect value when quotes are closed", function()
        local ctx = completion.detect_context('  data-on:click="@get()" ', 25)
        assert.is_nil(ctx)
      end)
    end)

    -- NIL: cursor is not in any Datastar context
    describe("no context", function()
      it("returns nil for plain text", function()
        local ctx = completion.detect_context('  <div class="foo">', 19)
        assert.is_nil(ctx)
      end)

      it("returns nil for empty line", function()
        local ctx = completion.detect_context('', 0)
        assert.is_nil(ctx)
      end)

      it("returns nil inside non-data attribute value", function()
        local ctx = completion.detect_context('  class="foo', 12)
        assert.is_nil(ctx)
      end)
    end)
  end)
end)
