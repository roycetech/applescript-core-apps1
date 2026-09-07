(*
	@Purpose:
		Handlers for Safari window chrome and layout state
		(fullscreen, toolbar, compact, address bar focus).

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Safari/26.5/dec-safari-window-state

	@Created: Sun, Aug 09, 2026, at 09:25:59 AM
	@Last Modified: 2026-08-09 09:25:59

	@Notes:
		Wired after dec-safari-ui-noncompact so #isAddressBarFocused can reach
		#_getAddressBarGroup via the parent chain. #getFirstZoomableWindow and
		#focusWindowWithToolbar stay on the Safari core because other core
		handlers (and earlier decorators) call them.
*)
use loggerFactory : script "core/logger-factory"

property logger : missing value

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		INFO
	")
	
	set spotScript to script "core/spot-test"
	set spotClass to spotScript's new()
	set spot to spotClass's new(me, cases)
	set {caseIndex, caseDesc} to spot's start()
	if caseIndex is 0 then
		logger's finish()
		return
	end if
	
	set sutLib to script "core/safari"
	set sut to sutLib's new()
	set sut to decorate(sut)
	
	logger's infof("Is compact: {}", sut's isCompact())
	logger's infof("Is fullscreen: {}", sut's isFullscreen())
	logger's infof("Is media fullscreen: {}", sut's isMediaFullScreen())
	logger's infof("Has toolbar: {}", sut's hasToolBar())
	logger's infof("Zoomable window present: {}", sut's getFirstZoomableWindow() is not missing value)
	logger's infof("Address bar focused: {}", sut's isAddressBarFocused())
	
	if caseIndex is 1 then
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*
	@safariInstance - SafariInstance
*)
on decorate(safariInstance)
	loggerFactory's inject(me)
	
	script SafariWindowStateDecorator
		property parent : safariInstance
		
		on hideOtherWindows()
			tell application "System Events" to tell process "Safari"
				set nonMatchedWindows to windows whose title does not contain my getTitle()
				repeat with nextUnmatched in nonMatchedWindows
					click (first button of nextUnmatched whose description is "minimize button")
				end repeat
			end tell
		end hideOtherWindows
		
		(*
			TOFIX: False positive detected when a dialog was detected.  The
			Developer settings window is not a dialog btw.
		*)
		on isMediaFullScreen()
			if running of application "Safari" is false then return false
			
			tell application "System Events" to tell process "Safari"
				exists (first window whose description is "dialog")
			end tell
		end isMediaFullScreen
		
		on isFullscreen()
			if running of application "Safari" is false then return false
			
			tell application "System Events" to tell process "Safari"
				value of attribute "AXFullScreen" of front window
			end tell
		end isFullscreen
		
		
		on hasToolBar()
			if running of application "Safari" is false then return false
			
			tell application "System Events" to tell process "Safari"
				try
					return exists toolbar 1 of front window
				end try
			end tell
			
			false
		end hasToolBar
		
		(* WARNING: Slow operation, 3s. *)
		on isAddressBarFocused()
			set mainWindow to getFirstZoomableWindow()
			if mainWindow is missing value then return false
			
			if isCompact() then -- Compact is no longer available on 26.2 must've been removed earlier.
				tell application "System Events" to tell process "Safari"
					-- return value of attribute "AXSelectedText" of text field 1 of (first radio button of UI element 1 of last group of toolbar 1 of front window whose value of attribute "AXValue" is true) is not missing value
					
					-- Removed reference to the selected tab (radio button)
					first radio button of UI element 1 of last group of toolbar 1 of front window whose value is true
					return focused of text field 1 of result
					
				end tell
			end if
			
			tell application "System Events" to tell process "Safari"
				value of attribute "AXSelectedText" of text field 1 of (my _getAddressBarGroup()) is not missing value
			end tell
		end isAddressBarFocused
		
		(*
			As of 26.4.
		*)
		on isCompact()
			set mainWindow to getFirstZoomableWindow()
			if mainWindow is missing value then return false
			
			tell application "System Events" to tell process "Safari"
				return not (exists (first UI element of mainWindow whose role description is "tab group"))
				
			end tell
			
			tell application "System Events" to tell process "Safari"
				-- UI element 1 of group 2 of toolbar 1 of mainWindow
				UI element 1 of group 1 of toolbar 1 of mainWindow -- Can't believe this changed from group 2 in a single day.
				try
					return get value of attribute "AXIdentifier" of result is equal to "TabBar?isSeparate=false"
				end try
			end tell
			
			false
		end isCompact
	end script
end decorate
