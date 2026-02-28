# Datastar Hover Documentation Demo
Output demo/hover.gif
Set Shell bash
Set FontSize 15
Set Width 1000
Set Height 650
Set Padding 20
Set TypingSpeed 50ms
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set CursorBlink false
Set LoopOffset 30%

# Open the file silently
Hide
Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 3s
Show

# Go to data-on:click line and hover
Type ":31"
Enter
Sleep 500ms
Type "0w"
Sleep 500ms

# Press K for hover docs
Type "K"
Sleep 4s

Escape
Sleep 1s

# Hover on data-signals
Type ":11"
Enter
Sleep 500ms
Type "0w"
Sleep 500ms

Type "K"
Sleep 4s

Escape
Sleep 1s

# Hover on data-computed
Type ":19"
Enter
Sleep 500ms
Type "0w"
Sleep 500ms

Type "K"
Sleep 4s

Escape
Sleep 1.5s
