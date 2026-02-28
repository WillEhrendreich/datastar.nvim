# Datastar Completions Demo
Output demo/completions.gif
Set Shell bash
Set FontSize 15
Set Width 1000
Set Height 550
Set Padding 20
Set TypingSpeed 50ms
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set CursorBlink false
Set LoopOffset 60%

# Open the file silently and get in position
Hide
Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 3s
Type ":18"
Enter
Sleep 500ms
Show

# Type a data- attribute to trigger completions
Type "o"
Sleep 300ms
Type@50ms "    <div data-"
Sleep 1s

# Trigger omnifunc completion
Ctrl+x
Sleep 200ms
Ctrl+o
Sleep 2s

# Browse through the plugin completions
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms
Up
Sleep 500ms
Up
Sleep 500ms

# Accept with Ctrl+y
Ctrl+y
Sleep 1s

Escape
Sleep 500ms

# Now show key completion (event names after data-on:)
Type "o"
Sleep 300ms
Type@50ms "    <button data-on:"
Sleep 1s

Ctrl+x
Sleep 200ms
Ctrl+o
Sleep 2s

# Browse event names
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms

# Accept
Ctrl+y
Sleep 1.5s

Escape
Sleep 2s
