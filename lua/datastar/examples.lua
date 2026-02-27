-- datastar.examples — curated real-world examples for hover documentation
-- Provides practical code snippets for each plugin and modifier

local M = {}

local plugin_examples = {
  on = {
    { title = "Click handler", code = [[<button data-on:click="@post('/api/submit')">Submit</button>]] },
    { title = "Debounced input", code = [[<input data-on:input__debounce.500ms="@get('/search?q=$query')" />]] },
    { title = "Keyboard shortcut", code = [[<div data-on:keydown__window="$shortcutHandler"></div>]] },
    { title = "Once-only load", code = [[<div data-on:load__once="@get('/api/init')"></div>]] },
  },
  signals = {
    { title = "Named signal", code = [[<div data-signals:count="0"></div>]] },
    { title = "Merged signals", code = [[<div data-signals="{firstName: '', lastName: '', age: 0}"></div>]] },
    { title = "Boolean signal", code = [[<div data-signals:isOpen="false"></div>]] },
  },
  text = {
    { title = "Display signal value", code = [[<span data-text="$userName"></span>]] },
    { title = "Computed text", code = [[<span data-text="$firstName + ' ' + $lastName"></span>]] },
  },
  show = {
    { title = "Conditional visibility", code = [[<div data-show="$isLoggedIn">Welcome back!</div>]] },
    { title = "Comparison", code = [[<div data-show="$count > 0">You have items</div>]] },
  },
  class = {
    { title = "Toggle CSS class", code = [[<div data-class:active="$isActive">Tab</div>]] },
    { title = "Error styling", code = [[<input data-class:error="$hasError" />]] },
  },
  ref = {
    { title = "Element reference", code = [[<canvas data-ref="myCanvas"></canvas>]] },
  },
  bind = {
    { title = "Two-way input binding", code = [[<input data-bind:value="$username" />]] },
    { title = "Checkbox binding", code = [[<input type="checkbox" data-bind:checked="$isActive" />]] },
  },
  model = {
    { title = "Model binding", code = [[<input data-model="userName" />]] },
  },
  computed = {
    { title = "Computed value", code = [[<div data-computed:fullName="$firstName + ' ' + $lastName"></div>]] },
  },
  ["scroll-into-view"] = {
    { title = "Smooth scroll", code = [[<div data-scroll-into-view__smooth>New message</div>]] },
  },
  intersects = {
    { title = "Lazy load on visible", code = [[<div data-intersects="@get('/api/more')">Loading...</div>]] },
    { title = "Once intersection", code = [[<img data-intersects__once="@get('/api/image/$id')" />]] },
  },
  teleport = {
    { title = "Move to body", code = [[<div data-teleport="#modal-container">Modal content</div>]] },
  },
  persist = {
    { title = "Local storage", code = [[<div data-persist>Persisted signals</div>]] },
    { title = "Session storage", code = [[<div data-persist__session>Session-only</div>]] },
  },
  ["replace-url"] = {
    { title = "URL state sync", code = [[<div data-replace-url>Sync URL with signals</div>]] },
  },
  indicator = {
    { title = "Loading indicator", code = [[<div data-indicator:isFetching>
  <span data-show="$isFetching">Loading...</span>
</div>]] },
  },
  attributes = {
    { title = "Dynamic attribute", code = [[<a data-attributes:href="$linkUrl">Click here</a>]] },
    { title = "Disabled state", code = [[<button data-attributes:disabled="$isSubmitting">Submit</button>]] },
  },
}

local modifier_examples = {
  on = {
    debounce = { title = "Debounce input events", code = [[<input data-on:input__debounce.500ms="@get('/search?q=$q')" />]] },
    throttle = { title = "Throttle scroll events", code = [[<div data-on:scroll__throttle.200ms="$handleScroll"></div>]] },
    once = { title = "Run handler only once", code = [[<div data-on:load__once="@get('/api/init')"></div>]] },
    capture = { title = "Capture phase listener", code = [[<div data-on:click__capture="$handleClick"></div>]] },
    passive = { title = "Passive scroll listener", code = [[<div data-on:scroll__passive="$handleScroll"></div>]] },
    window = { title = "Listen on window", code = [[<div data-on:resize__window="$handleResize"></div>]] },
    outside = { title = "Click outside", code = [[<div data-on:click__outside="$isOpen = false"></div>]] },
  },
  persist = {
    session = { title = "Session storage only", code = [[<div data-persist__session>Session data</div>]] },
  },
  ["scroll-into-view"] = {
    smooth = { title = "Smooth scroll behavior", code = [[<div data-scroll-into-view__smooth>Smooth scroll</div>]] },
    instant = { title = "Instant scroll", code = [[<div data-scroll-into-view__instant>Jump to here</div>]] },
    hstart = { title = "Horizontal start alignment", code = [[<div data-scroll-into-view__smooth__hstart>Left aligned</div>]] },
  },
  intersects = {
    once = { title = "Trigger once on intersect", code = [[<div data-intersects__once="@get('/api/load')"></div>]] },
    half = { title = "50% visibility threshold", code = [[<div data-intersects__half="$isVisible = true"></div>]] },
    full = { title = "Full visibility threshold", code = [[<div data-intersects__full="$fullyVisible = true"></div>]] },
  },
}

--- Get curated examples for a plugin.
--- @param plugin_name string
--- @return table[] examples { title, code }
function M.get_examples(plugin_name)
  return plugin_examples[plugin_name] or {}
end

--- Get example for a specific modifier.
--- @param plugin_name string
--- @param modifier_name string
--- @return table|nil { title, code }
function M.get_modifier_example(plugin_name, modifier_name)
  local plugin_mods = modifier_examples[plugin_name]
  if not plugin_mods then return nil end
  return plugin_mods[modifier_name]
end

--- Format examples as markdown for hover display.
--- @param plugin_name string
--- @return string markdown
function M.format_hover_examples(plugin_name)
  local exs = M.get_examples(plugin_name)
  if #exs == 0 then return "" end

  local parts = { "**Examples:**" }
  for i, ex in ipairs(exs) do
    parts[#parts + 1] = string.format("%d. %s\n   %s", i, ex.title, ex.code:gsub("\n", "\n   "))
  end
  return table.concat(parts, "\n")
end

return M
