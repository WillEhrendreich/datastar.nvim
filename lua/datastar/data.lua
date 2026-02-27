-- datastar.nvim data schema
-- Source of truth: IntelliJ web-types + VSCode data-attributes.json + Datastar library source
-- Structure: plugin_name -> { description, doc_url, has_key, key_type, value_required, value_type, modifiers, snippets }

local M = {}

-- All Datastar attribute plugins with their full metadata
M.plugins = {
  attr = {
    description = "Sets one or more attribute values using key-value pairs.",
    doc_url = "https://data-star.dev/reference/attributes#data-attributes",
    has_key = true,
    key_type = "html_attrs",
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-attr", body = 'data-attr="{${1:attributeName}: ${2:expression}}"' },
      { trigger = "data-attr:*", body = 'data-attr:${1:name}="${2:expression}"' },
    },
  },
  bind = {
    description = "Creates a signal and enables two-way binding between it and the element.",
    doc_url = "https://data-star.dev/reference/attributes#data-bind",
    has_key = true,
    key_type = "signal_name",
    value_required = false,
    value_type = "signal_name",
    modifiers = {
      { name = "case", args = { "camel", "kebab", "snake", "pascal" } },
    },
    snippets = {
      { trigger = "data-bind", body = 'data-bind="${1:signalName}"' },
      { trigger = "data-bind:*", body = "data-bind:${1:name}" },
    },
  },
  class = {
    description = "Adds or removes one or more classes from an element using key-value pairs.",
    doc_url = "https://data-star.dev/reference/attributes#data-class",
    has_key = true,
    key_type = "css_class",
    value_required = true,
    value_type = "expression",
    modifiers = {
      { name = "case", args = { "camel", "kebab", "snake", "pascal" } },
    },
    snippets = {
      { trigger = "data-class", body = 'data-class="{${1:className}: ${2:expression}}"' },
      { trigger = "data-class:*", body = 'data-class:${1:name}="${2:expression}"' },
    },
  },
  computed = {
    description = "Creates one or more signals that are computed based on expressions.",
    doc_url = "https://data-star.dev/reference/attributes#data-computed",
    has_key = true,
    key_type = "signal_name",
    value_required = true,
    value_type = "expression",
    modifiers = {
      { name = "case", args = { "camel", "kebab", "snake", "pascal" } },
    },
    snippets = {
      { trigger = "data-computed", body = 'data-computed="{${1:signalName}: ${2:expression}}"' },
      { trigger = "data-computed:*", body = 'data-computed:${1:name}="${2:expression}"' },
    },
  },
  ["custom-validity"] = {
    description = "Adds custom validity to an element using an expression.",
    doc_url = "https://data-star.dev/reference/attributes#data-custom-validity",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-custom-validity", body = 'data-custom-validity="${1:expression}"' },
    },
  },
  effect = {
    description = "Executes an expression on page load and whenever any signals in the expression change.",
    doc_url = "https://data-star.dev/reference/attributes#data-effect",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-effect", body = 'data-effect="${1:expression}"' },
    },
  },
  ignore = {
    description = "Ignores an element and its descendants from being processed.",
    doc_url = "https://data-star.dev/reference/attributes#data-ignore",
    has_key = false,
    value_required = false,
    value_type = nil,
    modifiers = {
      { name = "self" },
    },
    snippets = {
      { trigger = "data-ignore", body = "data-ignore" },
    },
  },
  ["ignore-morph"] = {
    description = "Ignores an element when patching using the morph mode.",
    doc_url = "https://data-star.dev/reference/attributes#data-ignore-morph",
    has_key = false,
    value_required = false,
    value_type = nil,
    modifiers = {},
    snippets = {
      { trigger = "data-ignore-morph", body = "data-ignore-morph" },
    },
  },
  indicator = {
    description = "Creates a signal to track in-flight backend requests.",
    doc_url = "https://data-star.dev/reference/attributes#data-indicator",
    has_key = true,
    key_type = "signal_name",
    value_required = false,
    value_type = "signal_name",
    modifiers = {
      { name = "case", args = { "camel", "kebab", "snake", "pascal" } },
    },
    snippets = {
      { trigger = "data-indicator", body = 'data-indicator="${1:signalName}"' },
      { trigger = "data-indicator:*", body = "data-indicator:${1:name}" },
    },
  },
  init = {
    description = "Runs an expression whenever the attribute is initialised.",
    doc_url = "https://data-star.dev/reference/attributes#data-init",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {
      { name = "delay", args = { "500ms", "1s", "2s", "5s" } },
      { name = "viewtransition" },
    },
    snippets = {
      { trigger = "data-init", body = 'data-init="${1:expression}"' },
    },
  },
  ["json-signals"] = {
    description = "Sets the text content of an element to a reactive JSON stringified version of signals.",
    doc_url = "https://data-star.dev/reference/attributes#data-json-signals",
    has_key = false,
    value_required = false,
    value_type = "expression",
    modifiers = {
      { name = "terse" },
    },
    snippets = {
      { trigger = "data-json-signals", body = 'data-json-signals="${1:expression}"' },
    },
  },
  on = {
    description = "Runs an expression whenever an event is triggered on an element.",
    doc_url = "https://data-star.dev/reference/attributes#data-on",
    has_key = true,
    key_required = true,
    key_type = "dom_events",
    value_required = true,
    value_type = "expression",
    modifiers = {
      { name = "once" },
      { name = "passive" },
      { name = "capture" },
      { name = "case", args = { "camel", "kebab", "snake", "pascal" } },
      { name = "delay", args = { "500ms", "1s", "2s", "5s" } },
      { name = "debounce", args = { "500ms", "1s", "2s", "leading", "notrailing" } },
      { name = "throttle", args = { "500ms", "1s", "2s", "noleading", "trailing" } },
      { name = "viewtransition" },
      { name = "window" },
      { name = "outside" },
      { name = "prevent" },
      { name = "stop" },
    },
    snippets = {
      { trigger = "data-on:*", body = 'data-on:${1:event}="${2:expression}"' },
      { trigger = "data-on:click", body = 'data-on:click="${1:expression}"' },
      { trigger = "data-on:keydown", body = 'data-on:keydown="${1:expression}"' },
    },
  },
  ["on-intersect"] = {
    description = "Runs an expression on intersection with the viewport.",
    doc_url = "https://data-star.dev/reference/attributes#data-on-intersect",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {
      { name = "once" },
      { name = "exit" },
      { name = "half" },
      { name = "full" },
      { name = "threshold", args = { "0.1", "0.25", "0.5", "0.75", "1.0" } },
      { name = "delay", args = { "500ms", "1s", "2s", "5s" } },
      { name = "debounce", args = { "500ms", "1s", "2s", "leading", "notrailing" } },
      { name = "throttle", args = { "500ms", "1s", "2s", "noleading", "trailing" } },
      { name = "viewtransition" },
    },
    snippets = {
      { trigger = "data-on-intersect", body = 'data-on-intersect="${1:expression}"' },
    },
  },
  ["on-interval"] = {
    description = "Runs an expression at a regular interval.",
    doc_url = "https://data-star.dev/reference/attributes#data-on-interval",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {
      { name = "duration", args = { "500ms", "1s", "2s", "5s", "10s" } },
      { name = "viewtransition" },
    },
    snippets = {
      { trigger = "data-on-interval", body = 'data-on-interval="${1:expression}"' },
    },
  },
  ["on-raf"] = {
    description = "Runs an expression on every requestAnimationFrame event.",
    doc_url = "https://data-star.dev/reference/attributes#data-on-raf",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-on-raf", body = 'data-on-raf="${1:expression}"' },
    },
  },
  ["on-resize"] = {
    description = "Runs an expression whenever an element's dimensions change.",
    doc_url = "https://data-star.dev/reference/attributes#data-on-resize",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-on-resize", body = 'data-on-resize="${1:expression}"' },
    },
  },
  ["on-signal-patch"] = {
    description = "Runs an expression whenever one or more signals are patched.",
    doc_url = "https://data-star.dev/reference/attributes#data-on-signal-patch",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {
      { name = "delay", args = { "500ms", "1s", "2s", "5s" } },
      { name = "debounce", args = { "500ms", "1s", "2s", "leading", "notrailing" } },
      { name = "throttle", args = { "500ms", "1s", "2s", "noleading", "trailing" } },
    },
    snippets = {
      { trigger = "data-on-signal-patch", body = 'data-on-signal-patch="${1:expression}"' },
    },
  },
  ["on-signal-patch-filter"] = {
    description = "Filters which signals to watch when using data-on-signal-patch.",
    doc_url = "https://data-star.dev/reference/attributes#data-on-signal-change",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-on-signal-patch-filter", body = 'data-on-signal-patch-filter="${1:expression}"' },
    },
  },
  persist = {
    description = "Persists signals in local storage.",
    doc_url = "https://data-star.dev/reference/attributes#data-persist",
    has_key = true,
    key_type = "signal_name",
    value_required = false,
    value_type = "expression",
    modifiers = {
      { name = "session" },
      { name = "filter" },
    },
    snippets = {
      { trigger = "data-persist", body = 'data-persist=""' },
      { trigger = "data-persist:*", body = 'data-persist:${1:name}="${2:expression}"' },
    },
  },
  ["preserve-attr"] = {
    description = "Preserves the value of an attribute when patching elements using morph mode.",
    doc_url = "https://data-star.dev/reference/attributes#data-preserve-attr",
    has_key = false,
    value_required = true,
    value_type = "attr_list",
    modifiers = {},
    snippets = {
      { trigger = "data-preserve-attr", body = 'data-preserve-attr=""' },
    },
  },
  ["query-string"] = {
    description = "Syncs query string params to signal values on page load, and syncs signal values to query string params on change.",
    doc_url = "https://data-star.dev/reference/attributes#data-query-string",
    has_key = false,
    value_required = false,
    value_type = nil,
    modifiers = {
      { name = "filter" },
    },
    snippets = {
      { trigger = "data-query-string", body = 'data-query-string=""' },
    },
  },
  ref = {
    description = "Creates a signal whose value references an element.",
    doc_url = "https://data-star.dev/reference/attributes#data-ref",
    has_key = true,
    key_type = "signal_name",
    value_required = false,
    value_type = "signal_name",
    modifiers = {
      { name = "case", args = { "camel", "kebab", "snake", "pascal" } },
    },
    snippets = {
      { trigger = "data-ref", body = 'data-ref="${1:signalName}"' },
      { trigger = "data-ref:*", body = "data-ref:${1:name}" },
    },
  },
  ["replace-url"] = {
    description = "Replaces the URL in the browser with an evaluated expression.",
    doc_url = "https://data-star.dev/reference/attributes#data-replace-url",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-replace-url", body = 'data-replace-url="${1:expression}"' },
    },
  },
  ["scroll-into-view"] = {
    description = "Scrolls the element into view.",
    doc_url = "https://data-star.dev/reference/attributes#data-scroll-into-view",
    has_key = false,
    value_required = false,
    value_type = nil,
    modifiers = {
      { name = "instant" },
      { name = "smooth" },
      { name = "auto" },
      { name = "center" },
      { name = "end" },
      { name = "start" },
      { name = "nearest" },
    },
    snippets = {
      { trigger = "data-scroll-into-view", body = "data-scroll-into-view" },
    },
  },
  show = {
    description = "Shows or hides an element based on whether an expression evaluates to true or false.",
    doc_url = "https://data-star.dev/reference/attributes#data-show",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-show", body = 'data-show="${1:expression}"' },
    },
  },
  signals = {
    description = "Merges one or more signals into the existing signals.",
    doc_url = "https://data-star.dev/reference/attributes#data-signals",
    has_key = true,
    key_type = "signal_name",
    value_required = true,
    value_type = "expression",
    modifiers = {
      { name = "case", args = { "camel", "kebab", "snake", "pascal" } },
      { name = "ifmissing" },
    },
    snippets = {
      { trigger = "data-signals", body = 'data-signals="{${1:signalName}: ${2:expression}}"' },
      { trigger = "data-signals:*", body = 'data-signals:${1:name}="${2:expression}"' },
    },
  },
  style = {
    description = "Adds or removes one or more inline CSS styles from an element using key-value pairs.",
    doc_url = "https://data-star.dev/reference/attributes#data-style",
    has_key = true,
    key_type = "css_property",
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-style", body = 'data-style="{${1:styleName}: ${2:expression}}"' },
      { trigger = "data-style:*", body = 'data-style:${1:name}="${2:expression}"' },
    },
  },
  text = {
    description = "Sets the text content of an element to the evaluated expression.",
    doc_url = "https://data-star.dev/reference/attributes#data-text",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-text", body = 'data-text="${1:expression}"' },
    },
  },
  ["view-transition"] = {
    description = "Sets the value of view-transition-name for use with the View Transition API.",
    doc_url = "https://data-star.dev/reference/attributes#data-view-transition",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-view-transition", body = 'data-view-transition="${1:expression}"' },
    },
  },
  animate = {
    description = "Animates an element using an expression.",
    doc_url = "https://data-star.dev/reference/attributes#data-animate",
    has_key = false,
    value_required = true,
    value_type = "expression",
    modifiers = {},
    snippets = {
      { trigger = "data-animate", body = 'data-animate="${1:expression}"' },
    },
  },
  rocket = {
    description = "Enables Datastar rocket mode.",
    doc_url = "https://data-star.dev/reference/rocket",
    has_key = false,
    value_required = false,
    value_type = nil,
    modifiers = {},
    snippets = {
      { trigger = "data-rocket", body = "data-rocket" },
    },
  },
}

-- Datastar actions available in expressions
M.actions = {
  {
    name = "@get",
    signature = "@get(url: string, options?: FetchArgs)",
    description = "Sends a GET request to the backend using the Fetch API.",
    doc_url = "https://data-star.dev/reference/actions#get",
    snippet = "@get('${1:/endpoint}')",
  },
  {
    name = "@post",
    signature = "@post(url: string, options?: FetchArgs)",
    description = "Sends a POST request to the backend using the Fetch API.",
    doc_url = "https://data-star.dev/reference/actions#post",
    snippet = "@post('${1:/endpoint}')",
  },
  {
    name = "@put",
    signature = "@put(url: string, options?: FetchArgs)",
    description = "Sends a PUT request to the backend using the Fetch API.",
    doc_url = "https://data-star.dev/reference/actions#put",
    snippet = "@put('${1:/endpoint}')",
  },
  {
    name = "@patch",
    signature = "@patch(url: string, options?: FetchArgs)",
    description = "Sends a PATCH request to the backend using the Fetch API.",
    doc_url = "https://data-star.dev/reference/actions#patch",
    snippet = "@patch('${1:/endpoint}')",
  },
  {
    name = "@delete",
    signature = "@delete(url: string, options?: FetchArgs)",
    description = "Sends a DELETE request to the backend using the Fetch API.",
    doc_url = "https://data-star.dev/reference/actions#delete",
    snippet = "@delete('${1:/endpoint}')",
  },
  {
    name = "@peek",
    signature = "@peek(callable: () => any)",
    description = "Allows accessing signals without subscribing to their changes.",
    doc_url = "https://data-star.dev/reference/actions#peek",
    snippet = "@peek(() => ${1:expression})",
  },
  {
    name = "@setAll",
    signature = "@setAll(value: any, filter?: SignalFilterOptions)",
    description = "Sets the value of all matching signals to the expression provided.",
    doc_url = "https://data-star.dev/reference/actions#setall",
    snippet = "@setAll(${1:value})",
  },
  {
    name = "@toggleAll",
    signature = "@toggleAll(filter?: SignalFilterOptions)",
    description = "Toggles the boolean value of all matching signals.",
    doc_url = "https://data-star.dev/reference/actions#toggleall",
    snippet = "@toggleAll()",
  },
}

-- Fetch action option keys
M.fetch_options = {
  { name = "contentType", description = "Content type: 'json' (default) or 'form'.", values = { "json", "form" } },
  { name = "filterSignals", description = "Filter object with include/exclude RegExp for signal paths." },
  { name = "selector", description = "CSS selector for form element (used with contentType: 'form')." },
  { name = "headers", description = "Object containing headers to send with the request." },
  { name = "openWhenHidden", description = "Keep connection open when page is hidden. Default: false for GET, true for others." },
  { name = "payload", description = "Override fetch payload with a custom object." },
  { name = "retry", description = "Retry behavior: 'auto', 'error', 'always', 'never'.", values = { "auto", "error", "always", "never" } },
  { name = "retryInterval", description = "Retry interval in milliseconds. Default: 1000." },
  { name = "retryScaler", description = "Multiplier for retry wait times. Default: 2." },
  { name = "retryMaxWaitMs", description = "Max wait between retries in ms. Default: 30000." },
  { name = "retryMaxCount", description = "Max retry attempts. Default: 10." },
  { name = "requestCancellation", description = "Cancellation: 'auto', 'disabled', or AbortController.", values = { "auto", "disabled" } },
}

-- Standard DOM events for data-on:* key completion
M.dom_events = {
  "abort", "afterprint", "animationend", "animationiteration", "animationstart",
  "beforeprint", "beforeunload", "blur",
  "canplay", "canplaythrough", "change", "click", "contextmenu", "copy", "cut",
  "dblclick", "drag", "dragend", "dragenter", "dragleave", "dragover", "dragstart", "drop",
  "durationchange",
  "ended", "error",
  "focus", "focusin", "focusout", "fullscreenchange", "fullscreenerror",
  "hashchange",
  "input", "invalid",
  "keydown", "keypress", "keyup",
  "load", "loadeddata", "loadedmetadata", "loadstart",
  "message", "mousedown", "mouseenter", "mouseleave", "mousemove",
  "mouseout", "mouseover", "mouseup",
  "offline", "online", "open",
  "pagehide", "pageshow", "paste", "pause", "play", "playing",
  "popstate", "progress",
  "ratechange", "resize", "reset",
  "scroll", "search", "seeked", "seeking", "select",
  "stalled", "storage", "submit", "suspend",
  "timeupdate", "toggle", "touchcancel", "touchend", "touchmove", "touchstart",
  "transitionend",
  "unload",
  "volumechange",
  "waiting", "wheel",
}

-- Standard HTML attributes for data-attr:* and data-preserve-attr key completion
M.html_attrs = {
  "accept", "accept-charset", "accesskey", "action", "align", "alt", "async",
  "autocomplete", "autofocus", "autoplay",
  "bgcolor", "border",
  "charset", "checked", "cite", "class", "color", "cols", "colspan",
  "content", "contenteditable", "controls", "coords",
  "data", "datetime", "default", "defer", "dir", "dirname", "disabled",
  "download", "draggable",
  "enctype",
  "for", "form", "formaction",
  "headers", "height", "hidden", "high", "href", "hreflang", "http-equiv",
  "id", "ismap",
  "kind",
  "label", "lang", "list", "loop", "low",
  "max", "maxlength", "media", "method", "min", "multiple", "muted",
  "name", "novalidate",
  "open", "optimum",
  "pattern", "placeholder", "poster", "preload",
  "readonly", "rel", "required", "reversed", "role", "rows", "rowspan",
  "sandbox", "scope", "selected", "shape", "size", "sizes", "span",
  "spellcheck", "src", "srcdoc", "srclang", "srcset", "start", "step",
  "style", "tabindex", "target", "title", "translate", "type",
  "usemap",
  "value",
  "width", "wrap",
}

-- Default filetypes the plugin activates on
M.filetypes = {
  "html", "htmldjango", "php", "twig", "blade", "vue", "svelte",
  "astro", "templ", "eruby", "ejs", "handlebars", "mustache",
  "liquid", "pug", "razor", "gohtml", "jsp", "edge", "nunjucks",
  "gohtmltmpl", "htmlangular",
}

-- Helper: get all plugin names as a sorted list
function M.plugin_names()
  local names = {}
  for name, _ in pairs(M.plugins) do
    names[#names + 1] = name
  end
  table.sort(names)
  return names
end

-- Helper: get modifiers for a specific plugin
function M.get_modifiers(plugin_name)
  local plugin = M.plugins[plugin_name]
  if not plugin then return {} end
  return plugin.modifiers or {}
end

-- Helper: get all snippets across all plugins, flattened
function M.all_snippets()
  local result = {}
  for plugin_name, plugin in pairs(M.plugins) do
    for _, snippet in ipairs(plugin.snippets or {}) do
      result[#result + 1] = {
        trigger = snippet.trigger,
        body = snippet.body,
        description = plugin.description,
        doc_url = plugin.doc_url,
        plugin = plugin_name,
      }
    end
  end
  table.sort(result, function(a, b) return a.trigger < b.trigger end)
  return result
end

return M
