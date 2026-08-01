(*
	@Purpose:
		Script to handle tab finding. Should decorate the terminal instance, NOT the "terminal-tab".

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Terminal/2.15/dec-terminal_tab-finder

	@Created: Sat, Jul 04, 2026, at 07:29:21 AM
	
	@Last Modified: 2026-06-30
*)

use winUtilLib : script "core/window"
use fileUtil : script "core/file"

use loggerFactory : script "core/logger-factory"

use terminalTabLib : script "core/terminal-tab"

property logger : missing value

property winUtil : missing value
property TopLevel : me


if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		NOOP
		Manual: Find Tab by Title
		Manual: Find Tab by Title Prefix
		Manual: Find Tab by Title Suffix
		Manual: Find Tab by Title Substring

		Manual: Find Tab by Window Name
		Manual: Find Tab by Window Name Prefix
		Manual: Find Tab by Window Name Suffix
		Manual: Find Tab by Window Name Substring
		Manual: Find First non-ssh tab

		Manual: Find First ssh tab
		Manual: Find First Tab by Process
		Manual: Find Tab by Directory Path
		Manual: Find Tab by Directory Name Prefix
	")
	
	set spotScript to script "core/spot-test"
	set spotClass to spotScript's new()
	set spot to spotClass's new(me, cases)
	set {caseIndex, caseDesc} to spot's start()
	if caseIndex is 0 then
		logger's finish()
		return
	end if
	
	set std to script "core/std"
	set unic to script "core/unicodes"
	set emoji to script "core/emoji"
	
	set sutLib to script "core/terminal"
	set sut to sutLib's new()
	set sut to decorate(sut)
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		set sutTabTitle to "Unicorn"
		-- set sutTabTitle to std's getUsername() & unic's SEPARATOR & emoji's TUBE & " PVE51" & unic's SEPARATOR & "-zsh"
		set sutTabTitle to emoji's TUBE & " PVE51"
		
		logger's debugf("sutTabTitle: {}", sutTabTitle)
		logger's infof("Handler result: {}", sut's findTabByTitle(sutTabTitle) is not missing value)
		
	else if caseIndex is 3 then
		set sutTabTitlePrefix to "Unicorn"
		set sutTabTitlePrefix to emoji's TUBE & " P"
		
		logger's debugf("sutTabTitlePrefix: {}", sutTabTitlePrefix)
		logger's infof("Handler result: {}", sut's findTabByTitlePrefix(sutTabTitlePrefix) is not missing value)
		
	else if caseIndex is 4 then
		set sutTabTitleSuffix to "Unicorn"
		-- set sutTabTitleSuffix to " PVE51"
		
		logger's debugf("sutTabTitleSuffix: {}", sutTabTitleSuffix)
		logger's infof("Handler result: {}", sut's findTabByTitleSuffix(sutTabTitleSuffix) is not missing value)
		
	else if caseIndex is 5 then
		set sutTabTitleSubstring to "Unicorn"
		set sutTabTitleSubstring to "VE5"
		
		logger's debugf("sutTabTitleSubstring: {}", sutTabTitleSubstring)
		logger's infof("Handler result: {}", sut's findTabByTitleSubstring(sutTabTitleSubstring) is not missing value)
		
	else if caseIndex is 6 then
		set sutWindowName to "Unicorn"
		set sutWindowName to std's getUsername() & unic's SEPARATOR & emoji's TUBE & " PVE51" & unic's SEPARATOR & "-zsh"
		
		logger's debugf("sutWindowName: {}", sutWindowName)
		logger's infof("Handler result: {}", sut's findTabByWindowName(sutWindowName) is not missing value)
		
	else if caseIndex is 7 then
		set sutWindowNamePrefix to "Unicorn"
		set sutWindowNamePrefix to std's getUsername() & unic's SEPARATOR & emoji's TUBE
		
		logger's debugf("sutWindowNamePrefix: {}", sutWindowNamePrefix)
		logger's infof("Handler result: {}", sut's findTabByWindowNamePrefix(sutWindowNamePrefix) is not missing value)
		
	else if caseIndex is 8 then
		set sutWindowNameSuffix to "Unicorn"
		set sutWindowNameSuffix to emoji's TUBE & " PVE51" & unic's SEPARATOR & "-zsh"
		
		logger's debugf("sutWindowNameSuffix: {}", sutWindowNameSuffix)
		logger's infof("Handler result: {}", sut's findTabByWindowNameSuffix(sutWindowNameSuffix) is not missing value)
		
	else if caseIndex is 9 then
		set sutWindowNameSubstring to "Unicorn"
		-- set sutWindowNameSubstring to emoji's TUBE & " PVE51"
		
		logger's debugf("sutWindowNameSubstring: {}", sutWindowNameSubstring)
		logger's infof("Handler result: {}", sut's findTabByWindowNameSubstring(sutWindowNameSubstring) is not missing value)
		
	else if caseIndex is 10 then
		set firstNonSshTab to sut's findFirstNonSshTab()
		if firstNonSshTab is missing value then
			logger's info("Non-ssh tab was not found")
		else
			logger's infof("Non-ssh tab was found: {}", firstNonSshTab's getTabTitle())
			firstNonSshTab's focus()
		end if
		
	else if caseIndex is 11 then
		set firstSshTab to sut's findFirstSshTab()
		if firstSshTab is missing value then
			logger's info("Ssh tab was not found.")
		else
			logger's infof("Ssh tab was found: {}", firstSshTab's getTabTitle())
			firstSshTab's focus()
		end if
		
	else if caseIndex is 12 then
		set sutProcessName to "Unicorn"
		-- set sutProcessName to "-zsh"
		logger's infof("sutProcessName: {}", sutProcessName)
		
		set firstSshTab to sut's findFirstTabByProcess(sutProcessName)
		if firstSshTab is missing value then
			logger's infof("Tab with process '{}' was not found.", sutProcessName)
		else
			logger's infof("Tab with process '{}' was found.", sutProcessName)
			firstSshTab's focus()
		end if
		
	else if caseIndex is 13 then
		set sutDirectoryPath to "Unicorn"
		set sutDirectoryPath to "~/Projects/PlexussSite/newplexuss"
		set sutDirectoryPath to "~"
		logger's infof("sutDirectoryPath: {}", sutDirectoryPath)
		
		set foundTab to sut's findTabByDirectoryPath(sutDirectoryPath)
		if foundTab is missing value then
			logger's infof("Tab in directory path '{}' was not found.", sutDirectoryPath)
		else
			logger's infof("Tab in directory path '{}' was found at {}", {sutDirectoryPath, foundTab's getPosixPath()})
			foundTab's focus()
		end if
		
	else if caseIndex is 14 then
		set sutDirectoryNamePrefix to "Unicorn"
		set sutDirectoryNamePrefix to "applescript-hub"
		logger's infof("sutDirectoryNamePrefix: {}", sutDirectoryNamePrefix)
		
		set foundTab to sut's findTabByDirectoryNamePrefix(sutDirectoryNamePrefix)
		if foundTab is missing value then
			logger's infof("Tab with directory name prefix '{}' was not found.", sutDirectoryNamePrefix)
		else
			logger's infof("Tab with directory name prefix '{}' was found at {}", {sutDirectoryNamePrefix, foundTab's getPosixPath()})
			foundTab's focus()
		end if
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


on normalizeDirectoryPath(aPath)
	set calcPath to fileUtil's expandPath(aPath)
	if calcPath ends with "/" and calcPath is not equal to "/" then set calcPath to text 1 thru -2 of calcPath
	calcPath
end normalizeDirectoryPath


(*  *)
on decorate(terminalInstance)
	loggerFactory's inject(me)
	set winUtil to winUtilLib's new()
	
	script TerminalTabFinderInstance
		property parent : terminalInstance
		
		on findFirstNonSshTab()
			if running of application "Terminal" is false then return false
			
			tell application "Terminal"
				repeat with nextWindow in windows
					try
						set termProcesses to processes of selected tab of nextWindow
						set hasProcess to (the number of items in termProcesses) is not 0
						if hasProcess and the last item of termProcesses is not "ssh" then return terminalTabLib's new(id of nextWindow)
					end try
				end repeat
			end tell
			missing value
		end findFirstNonSshTab
		
		
		on findFirstSshTab()
			if running of application "Terminal" is false then return false
			
			tell application "Terminal"
				repeat with nextWindow in windows
					try
						set termProcesses to processes of selected tab of nextWindow
						set hasProcess to (the number of items in termProcesses) is not 0
						if hasProcess and the last item of termProcesses is "ssh" then return terminalTabLib's new(id of nextWindow)
					end try -- Ignore error where there are "ghost" window/s
				end repeat
			end tell
			missing value
		end findFirstSshTab
		
		
		on findFirstTabByProcess(processKey)
			if running of application "Terminal" is false then return false
			
			tell application "Terminal"
				repeat with nextWindow in windows
					try
						set termProcesses to processes of selected tab of nextWindow
						set hasProcess to (the number of items in termProcesses) is not 0
						if hasProcess and the last item of termProcesses is processKey then return terminalTabLib's new(id of nextWindow)
					end try
				end repeat
			end tell
			missing value
		end findFirstTabByProcess
		
		
		on findTabByTitle(tabTitle)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			tell application "Terminal"
				try
					custom title of tabs of windows
					set appWindow to first window whose custom title of tab 1 is equal to the tabTitle
					return terminalTabLib's new(id of appWindow)
				end try
			end tell
			
			missing value
		end findTabByTitle
		
		
		on findTabByTitlePrefix(titlePrefix)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			tell application "Terminal"
				try
					set appWindow to first window whose custom title of tab 1 starts with titlePrefix
					return terminalTabLib's new(id of appWindow)
				end try
			end tell
			
			missing value
		end findTabByTitlePrefix
		
		
		on findTabByTitleSuffix(titleSuffix)
			-- findTabEndingWith(titleSuffix)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			tell application "Terminal"
				try
					set appWindow to first window whose custom title of tab 1 ends with titleSuffix
					return terminalTabLib's new(id of appWindow)
				end try
			end tell
			
			missing value
		end findTabByTitleSuffix
		
		
		on findTabByTitleSubstring(titleSubstring)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			tell application "Terminal"
				try
					set appWindow to first window whose custom title of tab 1 contains titleSubstring
					return terminalTabLib's new(id of appWindow)
				end try
			end tell
			
			missing value
		end findTabByTitleSubstring
		
		
		on findTabByWindowName(windowName)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			tell application "Terminal"
				try
					set appWindow to first window whose name is equal to the windowName
					return terminalTabLib's new(id of appWindow)
				end try
			end tell
			
			missing value
		end findTabByWindowName
		
		
		on findTabByWindowNamePrefix(windowNamePrefix)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			tell application "Terminal"
				try
					set appWindow to first window whose name starts with the windowNamePrefix
					return terminalTabLib's new(id of appWindow)
				end try
			end tell
			
			missing value
		end findTabByWindowNamePrefix
		
		
		(*
			@return  missing value of tab is not found. TabInstance
		*)
		on findTabByWindowNameSuffix(windowNameSuffix)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			tell application "Terminal"
				try
					set appWindow to first window whose name ends with windowNameSuffix
					return terminalTabLib's new(id of appWindow)
				end try
			end tell
			
			missing value
		end findTabByWindowNameSuffix
		
		
		(* @return  missing value of tab is not found. TabInstance *)
		on findTabByWindowNameSubstring(windowNameKeyword)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			tell application "Terminal"
				try
					set appWindow to first window whose name contains the windowNameKeyword
					return terminalTabLib's new(id of appWindow)
					
				end try
			end tell
			
			missing value
		end findTabByWindowNameSubstring
		
		
		-- NOTE: New handlers for directory name/path finding start ------------------------------------------------------
		(* @return missing value if tab is not found. TabInstance *)
		on findTabByDirectoryPath(directoryPath)
			_findTabByDirectoryMatch("path", directoryPath)
		end findTabByDirectoryPath
		
		
		(* @return missing value if tab is not found. TabInstance *)
		on findTabByDirectoryNamePrefix(directoryNamePrefix)
			_findTabByDirectoryMatch("namePrefix", directoryNamePrefix)
		end findTabByDirectoryNamePrefix
		
		
		on _findTabByDirectoryMatch(matchMode, searchValue)
			if winUtil's hasWindow("Terminal") is false then return missing value
			
			set normalizedPathSearch to missing value
			if matchMode is "path" then set normalizedPathSearch to TopLevel's normalizeDirectoryPath(searchValue)
			
			tell application "Terminal"
				repeat with nextWindow in windows
					set windowId to id of nextWindow
					repeat with tabIndex from 1 to (count of tabs of nextWindow)
						try
							set selected tab of nextWindow to tab tabIndex of nextWindow
							set candidateTab to terminalTabLib's new(windowId)
							if candidateTab is missing value then error "skip"
							
							if matchMode is "path" then
								set tabPath to candidateTab's getPosixPath()
								if tabPath is not missing value and TopLevel's normalizeDirectoryPath(tabPath) is equal to normalizedPathSearch then return candidateTab
								
							else if matchMode is "namePrefix" then
								set dirName to candidateTab's getDirectoryName()
								if dirName is not missing value and dirName starts with searchValue then return candidateTab
							end if
						end try
					end repeat
				end repeat
			end tell
			
			missing value
		end _findTabByDirectoryMatch
	end script
end decorate


