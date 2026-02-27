# Datastar Event Type Narrowing Demo
Output demo/event-narrowing.gif
Set Shell bash
Set FontSize 16
Set Width 900
Set Height 500
Set Padding 10
Set Theme "Kanagawa"

Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 2s

# Go to the data-on:keydown line
Type ":33"
Enter
Sleep 500ms

# Go to end of line, open new line below with a similar handler
Type "o"
Sleep 300ms
Type "  <div data-on:click=\"evt."
Sleep 1s

# Trigger completion for MouseEvent properties
Ctrl+x
Sleep 200ms
Ctrl+o
Sleep 2s

# Scroll through items
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms

Escape
Sleep 1s

# Now show keydown narrowing
Type "cc"
Sleep 300ms
Type "  <div data-on:keydown=\"evt."
Sleep 1s

Ctrl+x
Sleep 200ms
Ctrl+o
Sleep 2s

# Scroll through KeyboardEvent items
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms

Escape
Sleep 2s
