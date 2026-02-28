# Datastar Goto Definition Demo
Output demo/goto-definition.gif
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

# Open the file silently
Hide
Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 3s
Show

# Go to $userName usage in data-text
Type ":21"
Enter
Sleep 800ms

# Position on $userName
Type "f$"
Sleep 800ms

# Press gd — jumps to the data-signals definition
Type "gd"
Sleep 2.5s

# Jump back
Ctrl+o
Sleep 1.5s

# Now try $fullName (computed signal)
Type ":22"
Enter
Sleep 800ms

Type "f$"
Sleep 800ms

# Jump to the computed signal definition
Type "gd"
Sleep 2.5s

# Jump back
Ctrl+o
Sleep 1.5s

# Try $count
Type ":31"
Enter
Sleep 800ms

Type "f$"
Sleep 800ms

Type "gd"
Sleep 2.5s
