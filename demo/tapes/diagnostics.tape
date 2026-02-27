# Datastar Diagnostics Demo
Output demo/diagnostics.gif
Set Shell bash
Set FontSize 16
Set Width 900
Set Height 500
Set Padding 10
Set Theme "Kanagawa"

Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 2s

# Jump to first diagnostic (duplicate modifier)
Type ":75"
Enter
Sleep 1s

# Show diagnostic float
Type "gl"
Sleep 2s

# Move to next diagnostic
Type "]d"
Sleep 1s
Type "gl"
Sleep 2s

# Next diagnostic
Type "]d"
Sleep 1s
Type "gl"
Sleep 2s

# Next diagnostic
Type "]d"
Sleep 1s
Type "gl"
Sleep 2s
