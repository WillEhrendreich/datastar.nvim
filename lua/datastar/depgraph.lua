-- datastar.depgraph — signal dependency graph
-- Builds and formats a DAG of signal dependencies from computed/effect expressions

local M = {}

--- Extract unique $signal references from an expression string.
--- @param expr string
--- @return string[] signal names (sorted, deduplicated)
function M.extract_signal_refs(expr)
  local seen = {}
  local refs = {}
  -- Match $name and $$name (but capture just the name part)
  for name in expr:gmatch("%$%$?([%w_]+)") do
    if not seen[name] then
      seen[name] = true
      refs[#refs + 1] = name
    end
  end
  table.sort(refs)
  return refs
end

--- Build a dependency graph from buffer lines.
--- @param lines string[] buffer lines
--- @return table { nodes = {name=true}, edges = {name={dep1,dep2}} }
function M.build_graph(lines)
  local nodes = {}
  local edges = {}

  for _, line in ipairs(lines) do
    -- data-signals:KEY="value" → definition
    for key in line:gmatch("data%-signals:([%w%-]+)") do
      nodes[key] = true
    end

    -- data-signals="{key: val, ...}" → merged definitions
    local merged = line:match('data%-signals%s*=%s*["\']({.-})["\']')
    if merged then
      for key in merged:gmatch("([%w_]+)%s*:") do
        nodes[key] = true
      end
    end

    -- data-computed:KEY="expr" → computed with dependencies
    local comp_key, comp_expr = line:match('data%-computed:([%w%-]+)%s*=%s*"(.-)"')
    if not comp_key then
      comp_key, comp_expr = line:match("data%-computed:([%w%-]+)%s*=%s*'(.-)'")
    end
    if comp_key then
      nodes[comp_key] = true
      local deps = M.extract_signal_refs(comp_expr)
      if #deps > 0 then
        edges[comp_key] = deps
      end
    end

    -- Also capture $signal refs from any data- attribute value for node tracking
    local val = line:match('data%-[%w%-]+[^=]*=%s*"(.-)"')
    if not val then
      val = line:match("data%-[%w%-]+[^=]*=%s*'(.-)'")
    end
    if val then
      for name in val:gmatch("%$%$?([%w_]+)") do
        nodes[name] = true
      end
    end
  end

  return { nodes = nodes, edges = edges }
end

--- Format a dependency graph as human-readable text.
--- @param graph table { nodes, edges }
--- @return string
function M.format_graph(graph)
  local names = {}
  for name in pairs(graph.nodes) do
    names[#names + 1] = name
  end
  table.sort(names)

  if #names == 0 then
    return "No signals found in this buffer."
  end

  local parts = { "Signal Dependency Graph", string.rep("=", 25), "" }

  -- Computed signals (have edges)
  local computed = {}
  for name in pairs(graph.edges) do
    computed[#computed + 1] = name
  end
  table.sort(computed)

  if #computed > 0 then
    parts[#parts + 1] = "Computed signals:"
    for _, name in ipairs(computed) do
      local deps = graph.edges[name]
      table.sort(deps)
      parts[#parts + 1] = string.format("  %s <- %s", name, table.concat(deps, ", "))
    end
    parts[#parts + 1] = ""
  end

  -- Leaf signals (no incoming edges)
  local leaves = {}
  local dep_targets = {}
  for _, deps in pairs(graph.edges) do
    for _, d in ipairs(deps) do dep_targets[d] = true end
  end
  for _, name in ipairs(names) do
    if not graph.edges[name] then
      leaves[#leaves + 1] = name
    end
  end

  if #leaves > 0 then
    parts[#parts + 1] = "Leaf signals (no dependencies):"
    for _, name in ipairs(leaves) do
      parts[#parts + 1] = "  " .. name
    end
  end

  return table.concat(parts, "\n")
end

--- Format a dependency graph as Mermaid flowchart.
--- @param graph table { nodes, edges }
--- @return string
function M.format_mermaid(graph)
  local parts = { "graph LR" }

  local names = {}
  for name in pairs(graph.nodes) do
    names[#names + 1] = name
  end
  table.sort(names)

  for _, name in ipairs(names) do
    parts[#parts + 1] = string.format("  %s[%s]", name, name)
  end

  local edge_names = {}
  for name in pairs(graph.edges) do
    edge_names[#edge_names + 1] = name
  end
  table.sort(edge_names)

  for _, name in ipairs(edge_names) do
    local deps = graph.edges[name]
    for _, dep in ipairs(deps) do
      parts[#parts + 1] = string.format("  %s --> %s", dep, name)
    end
  end

  return table.concat(parts, "\n")
end

return M
