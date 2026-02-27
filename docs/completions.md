# Completions

datastar.nvim provides context-aware completions that understand exactly where your cursor is in a Datastar attribute.

## The Datastar Attribute Syntax

```
data-[plugin]:[key]__[modifier].[arg]="expression"
│              │         │       │        │
│              │         │       │        └─ VALUE context
│              │         │       └─ MODIFIER_ARG context
│              │         └─ MODIFIER context
│              └─ KEY context
└─ ATTRIBUTE_NAME context
```

The plugin detects which part you're editing and offers the right completions.

## Context 1: Attribute Names

**Trigger**: Type `data-` inside an HTML tag

Completes all 31 Datastar plugin names:

| Attribute | Description |
|-----------|-------------|
| `data-signals` | Define reactive signals |
| `data-on` | Event handlers |
| `data-bind` | Two-way input binding |
| `data-text` | Set text content |
| `data-show` | Toggle visibility |
| `data-class` | Toggle CSS classes |
| `data-attr` | Set HTML attributes |
| `data-computed` | Derived signals |
| `data-ref` | Element references |
| `data-indicator` | Loading indicators |
| ... | and 21 more |

## Context 2: Keys

**Trigger**: Type `:` after a plugin name (e.g., `data-on:`)

Completions depend on the plugin:

- **`data-on:`** → DOM events (`click`, `submit`, `keydown`, `input`, ...)
- **`data-class:`** → common CSS class names
- **`data-attr:`** → HTML attribute names (`disabled`, `href`, `src`, ...)
- **`data-bind:`** → `value`, `checked`, etc.

## Context 3: Modifiers

**Trigger**: Type `__` after a key (e.g., `data-on:click__`)

Modifiers are plugin-specific:

- **`data-on`**: `__once`, `__passive`, `__capture`, `__debounce`, `__throttle`, `__delay`, `__prevent`, `__stop`
- **`data-signals`**: `__ifmissing`
- **`data-scroll-into-view`**: `__smooth`, `__instant`, `__auto`, `__hstart`, `__hcenter`, `__hend`, `__hnearest`, `__vstart`, `__vcenter`, `__vend`, `__vnearest`
- **`data-persist`**: `__session`, `__local`

## Context 4: Modifier Arguments

**Trigger**: Type `.` after a modifier (e.g., `data-on:click__debounce.`)

Argument completions:
- `__debounce.` → `500ms`, `1s`, `2s`, `leading`
- `__throttle.` → `500ms`, `1s`, `2s`, `noleading`, `notrailing`
- `__delay.` → `500ms`, `1s`, `2s`, `5s`

## Context 5: Values (Expressions)

**Trigger**: Type inside `="..."` of a Datastar attribute

Three kinds of value completions:

### Signal References (`$`)
Type `$` to see all signals defined in the current buffer:
```html
<div data-signals:userName="'Will'"></div>
<div data-signals:count="0"></div>

<!-- Inside any expression, type $ to get: -->
<span data-text="$">  <!-- completes: $userName, $count -->
```

### Action Calls (`@`)
Type `@` for Datastar backend actions:
```html
<button data-on:click="@get('/api')">     <!-- @get, @post, @put, @patch, @delete -->
```

### Event Properties (`evt.`)
Inside `data-on` handlers, type `evt.` for event-specific properties:
```html
<input data-on:keydown="evt.">  <!-- key, code, altKey, ctrlKey, ... -->
<div data-on:click="evt.">     <!-- clientX, clientY, button, ... -->
```

This is **event type narrowing** — the completions change based on whether the event is a `click` (MouseEvent), `keydown` (KeyboardEvent), `input` (InputEvent), etc.

## Triggering Completions

### With omnifunc (built-in)
Press `<C-x><C-o>` in insert mode to trigger completions.

### With nvim-cmp
Completions appear automatically as you type. See [Integrations](integrations.md).

### With blink.cmp
Completions appear automatically. See [Integrations](integrations.md).
