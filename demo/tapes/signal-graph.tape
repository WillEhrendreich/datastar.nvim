# Datastar Signal Dependency Graph Demo
Output demo/signal-graph.gif
Set Shell bash
Set FontSize 15
Set Width 1000
Set Height 550
Set Padding 20
Set TypingSpeed 50ms
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set CursorBlink false
Set LoopOffset 50%

# Open the file silently
Hide
Type "nvim -u demo/tapes/init.lua test-drive.html"
Enter
Sleep 3s
Show
Sleep 500ms

# Run the signal graph command
Type@80ms ":DatastarSignalGraph"
Enter
Sleep 3s

# Let the viewer take in the dependency graph
Sleep 4s

# Close the split
Type ":close"
Enter
Sleep 1.5s
