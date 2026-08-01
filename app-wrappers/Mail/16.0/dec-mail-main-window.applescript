(*
	@Purpose:
		TODO

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Mail/16.0/dec-mail-main-window

	@Created: Thu, May 14, 2026 at 11:58:56 AM
	@Last Modified: Thu, May 14, 2026 at 11:58:56 AM
	
	@Change Logs:
*)
use loggerFactory : script "core/logger-factory"

property logger : missing value

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		Main
		Manual: Toggle unread filter
		Manual: Set unread filter ON
		Manual: Set unread filter OFF
		Manual: Delete selected message
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
	set sutLib to script "core/mail"
	set sut to sutLib's new()
	set sut to decorate(sut)
	logger's infof("Is unread filtered: {}", sut's isUnreadFiltered())
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		sut's toggleUnreadFilter()
		
	else if caseIndex is 3 then
		sut's setUnreadFilterOn()
		
	else if caseIndex is 4 then
		sut's setUnreadFilterOff()
		
	else if caseIndex is 5 then
		sut's deleteSelectedMessage()
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*  *)
on decorate(mailInstance)
	loggerFactory's inject(me)
	
	script MailMainWindowDecorator
		property parent : mailInstance
		
		on deleteSelectedMessage()
			set mainWindow to getMainWindow()
			if mainWindow is missing value then 
				logger's info("Main window was not found")
				return false
			end if

			if not isMainWindowActive() then 
				logger's info("Main window is not active")
				return false
			end if
			
			tell application "System Events" to tell process "Mail"
				try
					click (first button of group 2 of toolbar 1 of mainWindow whose description is "Delete")
				end try
			end tell
		end deleteSelectedMessage


		on isUnreadFiltered()
			set mainWindow to getMainWindow()
			if mainWindow is missing value then return false
			
			tell application "System Events" to tell process "Mail"
				value of (first checkbox of toolbar 1 of window 1 whose description is "Filter") is 1
			end tell
		end isUnreadFiltered
		
		on setUnreadFilterOn()
			if isUnreadFiltered() then return
			
			toggleUnreadFilter()
		end setUnreadFilterOn
		
		
		on setUnreadFilterOff()
			if not isUnreadFiltered() then return
			
			toggleUnreadFilter()
		end setUnreadFilterOff
		
		
		on toggleUnreadFilter()
			set mainWindow to getMainWindow()
			if mainWindow is missing value then return false
			
			tell application "System Events" to tell process "Mail"
				click (first checkbox of toolbar 1 of mainWindow whose description is "Filter")
			end tell
		end toggleUnreadFilter
	end script
end decorate
