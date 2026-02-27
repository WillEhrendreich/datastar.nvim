# Datastar Completions Demo
Output demo/completions.gif
Set Shell bash
Set FontSize 16
Set Width 900
Set Height 500
Set Padding 10
Set Theme "Kanagawa"

Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 2s

# Navigate to end of file, add new line with data-
Type "Go"
Sleep 500ms
Type "i"
Sleep 300ms
Type "  <div data-"
Sleep 1s

# Trigger omnifunc completion
Ctrl+x
Sleep 200ms
Ctrl+o
Sleep 2s

# Scroll through a few items
Down
Sleep 500ms
Down
Sleep 500ms
Down
Sleep 500ms

# Select one
Enter
Sleep 1s

# Show the result
Escape
Sleep 2s
