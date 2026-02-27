-- tests/depgraph_spec.lua
-- Tests for signal dependency graph

package.path = "./lua/?.lua;" .. package.path

describe("datastar.depgraph", function()
  local depgraph

  setup(function()
    depgraph = require("datastar.depgraph")
  end)

  describe("extract_signal_refs", function()
    it("extracts $signal references from expression", function()
      local refs = depgraph.extract_signal_refs("$firstName + ' ' + $lastName")
      table.sort(refs)
      assert.are_same({"firstName", "lastName"}, refs)
    end)

    it("extracts $$rawSignal references", function()
      local refs = depgraph.extract_signal_refs("$$rawData.value")
      assert.are_same({"rawData"}, refs)
    end)

    it("returns empty for no signals", function()
      local refs = depgraph.extract_signal_refs("'hello world'")
      assert.are_same({}, refs)
    end)

    it("deduplicates references", function()
      local refs = depgraph.extract_signal_refs("$x + $x + $x")
      assert.are_same({"x"}, refs)
    end)
  end)

  describe("build_graph", function()
    it("builds dependency graph from lines", function()
      local lines = {
        '<div data-signals:firstName="\'Will\'"></div>',
        '<div data-signals:lastName="\'E\'"></div>',
        '<div data-computed:fullName="$firstName + \' \' + $lastName"></div>',
      }
      local graph = depgraph.build_graph(lines)
      assert.is_not_nil(graph)
      assert.is_not_nil(graph.nodes)
      assert.is_not_nil(graph.edges)

      -- fullName depends on firstName and lastName
      local fullname_edges = graph.edges["fullName"]
      assert.is_not_nil(fullname_edges)
      table.sort(fullname_edges)
      assert.are_same({"firstName", "lastName"}, fullname_edges)
    end)

    it("identifies signal definitions", function()
      local lines = {
        '<div data-signals:count="0"></div>',
      }
      local graph = depgraph.build_graph(lines)
      assert.is_true(graph.nodes["count"])
    end)

    it("identifies computed signals", function()
      local lines = {
        '<div data-signals:x="1"></div>',
        '<div data-computed:doubled="$x * 2"></div>',
      }
      local graph = depgraph.build_graph(lines)
      assert.is_true(graph.nodes["doubled"])
      assert.are_same({"x"}, graph.edges["doubled"])
    end)

    it("handles merged signals", function()
      local lines = {
        '<div data-signals="{a: 1, b: 2}"></div>',
      }
      local graph = depgraph.build_graph(lines)
      assert.is_true(graph.nodes["a"])
      assert.is_true(graph.nodes["b"])
    end)

    it("tracks signals referenced in on expressions", function()
      local lines = {
        '<div data-signals:query="\'\'"></div>',
        '<button data-on:click="@get(\'/search?q=\' + $query)"></button>',
      }
      local graph = depgraph.build_graph(lines)
      -- query should be a known node
      assert.is_true(graph.nodes["query"])
    end)
  end)

  describe("format_graph", function()
    it("formats as readable text", function()
      local graph = {
        nodes = { x = true, doubled = true },
        edges = { doubled = { "x" } },
      }
      local text = depgraph.format_graph(graph)
      assert.is_string(text)
      assert.truthy(text:find("doubled"))
      assert.truthy(text:find("x"))
    end)

    it("formats empty graph", function()
      local graph = { nodes = {}, edges = {} }
      local text = depgraph.format_graph(graph)
      assert.is_string(text)
      assert.truthy(text:find("No signals found"))
    end)

    it("shows leaf signals (no dependencies)", function()
      local graph = {
        nodes = { x = true, y = true },
        edges = {},
      }
      local text = depgraph.format_graph(graph)
      assert.truthy(text:find("x"))
      assert.truthy(text:find("y"))
    end)
  end)

  describe("format_mermaid", function()
    it("formats as mermaid flowchart", function()
      local graph = {
        nodes = { x = true, doubled = true },
        edges = { doubled = { "x" } },
      }
      local mermaid = depgraph.format_mermaid(graph)
      assert.is_string(mermaid)
      assert.truthy(mermaid:find("graph"))
      assert.truthy(mermaid:find("x"))
      assert.truthy(mermaid:find("doubled"))
    end)
  end)
end)
