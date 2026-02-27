# Datastar Goto Definition Demo
Output demo/goto-definition.gif
Set Shell bash
Set FontSize 16
Set Width 900
Set Height 500
Set Padding 10
Set Theme "Kanagawa"

Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 2s

# Go to $userName usage
Type ":21"
Enter
Sleep 500ms

# Position on $userName
Type "f$"
Sleep 500ms

# Press gd for goto definition
Type "gd"
Sleep 2s

# Show we jumped to the definition at line 11
Sleep 1s

# Go back and try another signal
Ctrl+o
Sleep 1s

# Go to $fullName
Type ":22"
Enter
Sleep 500ms
Type "f$"
Sleep 500ms

Type "gd"
Sleep 2s
