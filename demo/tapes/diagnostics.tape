# Datastar Diagnostics Demo
Output demo/diagnostics.gif
Set Shell bash
Set FontSize 15
Set Width 1000
Set Height 550
Set Padding 20
Set TypingSpeed 50ms
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set CursorBlink false
Set LoopOffset 30%

# Open the file silently and get to the diagnostics section
Hide
Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 3s
Type ":73"
Enter
Sleep 1s
Show
Sleep 1s

# Show diagnostic float for duplicate modifier
Type "]d"
Sleep 800ms
Type "gl"
Sleep 3s
Escape
Sleep 500ms

# Move to next diagnostic (conflicting modifiers)
Type "]d"
Sleep 800ms
Type "gl"
Sleep 3s
Escape
Sleep 500ms

# Next diagnostic (unbalanced expression)
Type "]d"
Sleep 800ms
Type "gl"
Sleep 3s
Escape
Sleep 500ms

# Next diagnostic (empty expression)
Type "]d"
Sleep 800ms
Type "gl"
Sleep 3s
Escape
Sleep 1.5s
