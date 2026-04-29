(*
	@Purpose:
		Serves as base class for all application wrapper scripts.

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh base-app
		

	@Created: Sat, Feb 28, 2026 at 07:17:25 PM
	@Last Modified: 2026-03-24 17:31:28
*)
if {"Script Editor", "Script Debugger"} contains the name of current application then spotCheck() 

property logger : missing value

on spotCheck()
	-- NOTE: Must compile this script for the change to take effect during spot check. Changes to the spotCheck handler alone doesn't require recompile.
	
	set loggerFactory to script "core/logger-factory"
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		NOOP
		Manual: Calendar
		Manual: Safari
		Manual: Pages
		Manual: Switch Window Tab a=Pages
		
		Manual: Mail
	")
	
	set spotScript to script "core/spot-test"
	set spotClass to spotScript's new()
	set spot to spotClass's new(me, cases)
	set {caseIndex, caseDesc} to spot's start()
	if caseIndex is 0 then
		logger's finish()
		return
	end if
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		set calendarLib to script "core/calendar"
		set calendar to calendarLib's new()
		logger's infof("Has file access: {}", calendar's hasFileAccess())
		
	else if caseIndex is 3 then
		
		set safariLib to script "core/safari"
		set safari to safariLib's new()
		
		(* 
		-- For debugging
		set decoratorLib to script "core/decorator"
		set decorator to decoratorLib's new(safari)
		decorator's printHierarchy()
		*)
		
		logger's infof("Has tabbed windows: {}", safari's hasTabbedWindows())
		set hasFileAccessResult to safari's hasFileAccess()
		logger's infof("Has file access: {}", hasFileAccessResult)
		if hasFileAccessResult then
			logger's infof("Has dialog window: {}", safari's hasFileDialogWindow())
			
		end if
		
	else if caseIndex is 4 then
		set pagesLib to script "core/pages"
		set pages to pagesLib's new()
		logger's infof("Has tabbed windows: {}", pages's hasTabbedWindows())
		
	else if caseIndex is 5 then
		set pagesLib to script "core/pages"
		set pages to pagesLib's new()
		logger's infof("Has tabbed windows: {}", pages's hasTabbedWindows())
		
		set sutWindowTabIndex to 1
		set sutWindowTabIndex to 2
		logger's debugf("sutWindowTabIndex: {}", sutWindowTabIndex)
		
		pages's switchTabWindowByIndex(sutWindowTabIndex)
		
	else if caseIndex is 6 then
		set mailLib to script "core/mail"
		set mail to mailLib's new()
		logger's infof("Has tabbed windows: {}", mail's hasTabbedWindows())
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*  *)
on new(pProcessName)
	script BaseAppInstance
		property processName : pProcessName
		
		on hasFileAccess()
			false
		end hasFileAccess
		
		(*
			Cases:
				Safari - to tab group
		*)
		on hasTabbedWindows()
			tell application "System Events" to tell process (my processName)
				if my processName is "Safari" then
					return exists (first UI element of window 1 whose role description is "tab group")
				end if
				
				if not (exists (tab group 1 of front window)) then return false
				
				(count of radio buttons of tab group 1 of window 1) is not 0
			end tell
		end hasTabbedWindows
		
		
		on switchTabWindowByIndex(targetIndex)
			-- Ignore Safari for now.
			if targetIndex is less than 1 then return
			tell application "System Events" to tell process (my processName)
				try
					click radio button targetIndex of tab group 1 of front window
				end try
			end tell
		end switchTabWindowByIndex
	end script
end new
