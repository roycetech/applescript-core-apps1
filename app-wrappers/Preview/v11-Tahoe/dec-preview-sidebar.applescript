(*
	@Purpose:
		Provide handlers for manipulating the Preview window sidebar.

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Preview/v11-Tahoe/dec-preview-sidebar

	@Created: Wed, Apr 08, 2026 at 03:34:26 PM
	@Last Modified: Wed, Apr 08, 2026 at 03:34:26 PM
	
	@Change Logs:
*)
use unic : script "core/unicodes"

use loggerFactory : script "core/logger-factory"

property logger : missing value

if {"Script Editor", "Script Debugger"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		Main
		Manual: Sidebar - Hide
		Manual: Sidebar - Show
		Manual: Sidebar - Toggle
	")
	
	set spotScript to script "core/spot-test"
	set spotClass to spotScript's new()
	set spot to spotClass's new(me, cases)
	set {caseIndex, caseDesc} to spot's start()
	if caseIndex is 0 then
		logger's finish()
		return
	end if
	
	-- activate application ""
	set sutLib to script "core/preview"
	set sut to sutLib's new()
	set sut to decorate(sut)
	
	logger's infof("Is sidebar visible: {}", sut's isSidebarVisible())
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		sut's hideSidebar()
		
	else if caseIndex is 3 then
		set sutViewType to "unicorn"
		set sutViewType to "Thumbnails"
		-- set sutViewType to "Table of Contents"
		logger's debugf("sutViewType: {}", sutViewType)
		
		sut's switchViewType(sutViewType)
		
	else if caseIndex is 4 then
		sut's toggleSidebar()
		
	else
		
	end if
	
	activate
	
	spot's finish()
	logger's finish()
end spotCheck


(*  *)
on decorate(mainScript)
	loggerFactory's inject(me)
	
	script PreviewSidebarDecorator
		property parent : mainScript
		
		on showThumbnails()
			switchViewType("Thumbnails")
		end showThumbnails
		
		
		on toggleSidebar()
			if isSidebarVisible() then
				hideSidebar()
				return
			end if

				showThumbnails()
		end toggleSidebar
		
		(*
			Alias for showing the "Bookmarks" on the side.
			
			@viewType - View menu options Cmd+option 2-6
		*)
		on switchViewType(viewType)
			if running of application "Preview" is false then return false
			
			tell application "System Events" to tell process "Preview"
				set frontmost to true -- Inaccurate without this, looks to be delayed.
				try
					click menu item viewType of menu 1 of menu bar item "View" of menu bar 1
				end try
			end tell
		end switchViewType
		
		
		on hideSidebar()
			if not isSidebarVisible() then return
			
			tell application "System Events" to tell process "Preview"
				set frontmost to true -- Inaccurate without this, looks to be delayed.
				click menu item "Hide Sidebar" of menu 1 of menu bar item "View" of menu bar 1
			end tell
		end hideSidebar
		
		
		on isSidebarVisible()
			if running of application "Preview" is false then return false
			
			tell application "System Events" to tell process "Preview"
				set frontmost to true -- Inaccurate without this, looks to be delayed.
				menu item "Hide Sidebar" of menu 1 of menu bar item "View" of menu bar 1
				return value of attribute "AXMenuItemMarkChar" of result is not equal to unic's MENU_CHECK
			end tell
		end isSidebarVisible
	end script
end decorate
