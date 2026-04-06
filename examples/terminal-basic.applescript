use terminalLib : script "core/terminal" 

set terminal to terminalLib's new() 
set terminalTab to terminal's getFrontTab() 
terminalTab's runShellVoid("ls")
