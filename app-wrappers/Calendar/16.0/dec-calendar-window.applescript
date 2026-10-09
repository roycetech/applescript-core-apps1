(*
	@Purpose:
		Navigate the Calendar window to today, the previous period, or the next period.

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Calendar/16.0/dec-calendar-window

	@Created: Wed, Sep 30, 2026 at 03:59:00 PM
	@Last Modified: Wed, Sep 30, 2026 at 03:59:00 PM
*)
use loggerFactory : script "core/logger-factory"

property logger : missing value

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		NOOP
		Manual: Previous
		Manual: Next
		Manual: Today
	")
	
	set spotScript to script "core/spot-test"
	set spotClass to spotScript's new()
	set spot to spotClass's new(me, cases)
	set {caseIndex, caseDesc} to spot's start()
	if caseIndex is 0 then
		logger's finish()
		return
	end if
	
	set sutLib to script "core/calendar"
	set sut to sutLib's new()
	set sut to decorate(sut)
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		sut's previous()
		
	else if caseIndex is 3 then
		sut's next()
		
	else if caseIndex is 4 then
		sut's today()
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*
	@calendarInstance - CalendarInstance
*)
on decorate(calendarInstance)
	loggerFactory's inject(me)
	
	script CalendarWindowDecorator
		property parent : calendarInstance
		
		on previous()
			if running of application "Calendar" is false then return
			
			tell application "System Events" to tell process "Calendar"
				try
					click (first button of group 1 of splitter group 1 of front window whose description starts with "previous")
				end try
			end tell
		end previous
		
		
		on next()
			if running of application "Calendar" is false then return
			
			tell application "System Events" to tell process "Calendar"
				try
					click (first button of group 1 of splitter group 1 of front window whose description starts with "next")
				end try
			end tell
		end next
		
		
		on today()
			if running of application "Calendar" is false then return
			
			tell application "System Events" to tell process "Calendar"
				try
					click button "Today" of group 1 of splitter group 1 of front window
				end try
			end tell
		end today
	end script
end decorate
