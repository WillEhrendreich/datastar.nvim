# Datastar Event Type Narrowing Demo
Output demo/event-narrowing.gif
Set Shell bash
Set FontSize 15
Set Width 1000
Set Height 550
Set Padding 20
Set TypingSpeed 50ms
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set CursorBlink false
Set LoopOffset 40%

# Open the file silently and navigate to the click handler
Hide
Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 3s
Type ":31"
Enter
Sleep 500ms
Show

# Change the click handler's expression to evt. to show MouseEvent completions
# Position inside the value: f" to jump to opening quote, then ci" to change inner
Type `f"`
Sleep 500ms
Type `ci"`
Sleep 300ms
Type@50ms "evt."
Sleep 1.5s

# Trigger completion — MouseEvent properties (clientX, clientY, button, etc.)
Ctrl+x
Sleep 200ms
Ctrl+o
Sleep 2.5s

# Browse MouseEvent properties
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms

Escape
Sleep 300ms

# Undo back to original
Escape
Sleep 300ms
Type "u"
Sleep 800ms

# Now do the same on the keydown handler (line 33)
Type ":33"
Enter
Sleep 500ms

Type `f"`
Sleep 500ms
Type `ci"`
Sleep 300ms
Type@50ms "evt."
Sleep 1.5s

# Trigger completion — KeyboardEvent properties (key, code, ctrlKey, etc.)
Ctrl+x
Sleep 200ms
Ctrl+o
Sleep 2.5s

# Browse KeyboardEvent properties
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms

Escape
Sleep 300ms
Escape
Sleep 300ms
Type "u"
Sleep 2s
