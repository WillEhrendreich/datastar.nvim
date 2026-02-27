# Datastar Hover Documentation Demo
Output demo/hover.gif
Set Shell bash
Set FontSize 16
Set Width 900
Set Height 600
Set Padding 10
Set Theme "Kanagawa"

Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 2s

# Go to data-on:click line
Type ":31"
Enter
Sleep 500ms

# Position on data-on
Type "fdata-on"
Sleep 300ms
Type "0f-"
Sleep 300ms
Type "b"
Sleep 500ms

# Press K for hover
Type "K"
Sleep 3s

# Close hover
Escape
Sleep 1s

# Move to data-signals
Type ":11"
Enter
Sleep 500ms
Type "fd"
Sleep 300ms

# Hover on signals
Type "K"
Sleep 3s
