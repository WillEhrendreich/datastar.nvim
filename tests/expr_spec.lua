-- tests/expr_spec.lua
-- Tests for expression syntax validation

package.path = "./lua/?.lua;" .. package.path

describe("datastar.diagnostics expression validation", function()
  local diagnostics

  setup(function()
    diagnostics = require("datastar.diagnostics")
  end)

  describe("validate_expression", function()
    it("returns empty for valid expression", function()
      local results = diagnostics.validate_expression("$count + 1")
      assert.are_equal(0, #results)
    end)

    it("returns empty for valid action call", function()
      local results = diagnostics.validate_expression("@get('/api/users')")
      assert.are_equal(0, #results)
    end)

    it("detects unbalanced open paren", function()
      local results = diagnostics.validate_expression("@post('/api'")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("[Uu]nbalanced") or results[1].message:find("[Uu]nclosed"))
    end)

    it("detects unbalanced close paren", function()
      local results = diagnostics.validate_expression("$count)")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("[Uu]nbalanced") or results[1].message:find("[Uu]nexpected"))
    end)

    it("detects unterminated single-quoted string", function()
      local results = diagnostics.validate_expression("$name + ' is")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("[Uu]nterminated"))
    end)

    it("detects unterminated double-quoted string", function()
      local results = diagnostics.validate_expression('@get("/api')
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("[Uu]nterminated"))
    end)

    it("detects empty expression", function()
      local results = diagnostics.validate_expression("")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("[Ee]mpty"))
    end)

    it("detects whitespace-only expression", function()
      local results = diagnostics.validate_expression("   ")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("[Ee]mpty"))
    end)

    it("allows nested parens", function()
      local results = diagnostics.validate_expression("@get('/api', {headers: {'X-Custom': 'v'}})")
      assert.are_equal(0, #results)
    end)

    it("detects unbalanced brackets", function()
      local results = diagnostics.validate_expression("[1, 2, 3")
      assert.is_true(#results > 0)
    end)

    it("detects unbalanced braces", function()
      local results = diagnostics.validate_expression("{key: 'val'")
      assert.is_true(#results > 0)
    end)

    it("allows backtick template literals", function()
      local results = diagnostics.validate_expression("`hello ${$name}`")
      assert.are_equal(0, #results)
    end)

    it("detects unterminated backtick", function()
      local results = diagnostics.validate_expression("`hello ${$name}")
      assert.is_true(#results > 0)
      assert.is_truthy(results[1].message:find("[Uu]nterminated"))
    end)

    it("allows complex valid expression", function()
      local results = diagnostics.validate_expression("$count > 0 ? @get('/api') : @post('/api')")
      assert.are_equal(0, #results)
    end)

    it("allows comma-separated expressions", function()
      local results = diagnostics.validate_expression("$x = 1, $y = 2")
      assert.are_equal(0, #results)
    end)
  end)

  describe("validate_line with expressions", function()
    it("detects unbalanced paren in attribute value", function()
      local diags = diagnostics.validate_line('<div data-on:click="@post(\'/api\'">', 0)
      assert.is_true(#diags > 0)
    end)

    it("passes valid attribute value", function()
      local diags = diagnostics.validate_line('<div data-on:click="@post(\'/api\')">', 0)
      assert.are_equal(0, #diags)
    end)

    it("detects empty value on value_required attribute", function()
      local diags = diagnostics.validate_line('<div data-on:click="">', 0)
      assert.is_true(#diags > 0)
    end)

    it("allows empty value for non-value-required attribute", function()
      -- data-bind does not require a value
      local diags = diagnostics.validate_line('<div data-bind:name>', 0)
      assert.are_equal(0, #diags)
    end)
  end)
end)
