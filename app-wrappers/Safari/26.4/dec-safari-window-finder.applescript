(*
	@Purpose:
		Find Safari windows by tab group or profile name.

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Safari/26.4/dec-safari-window-finder

	@Created: Mon, Apr 27, 2026 at 12:40:26 PM
	@Last Modified: Mon, Apr 27, 2026 at 12:40:26 PM
	
	@Change Logs:
*)
use unic : script "core/unicodes"
use std : script "core/std"

use loggerFactory : script "core/logger-factory"

property logger : missing value

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		Main
		Manual: Find Window by Tab Group Name
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
	set sutLib to script "core/safari"
	set sut to sutLib's new()
	set sut to decorate(sut)
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		set sutTabGroupName to "unicorn"
		set sutTabGroupName to "Personal" -- Default tab group
		set sutTabGroupName to "Training - AI" -- User-defined tab group
		set sutTabGroupName to "Personal OWA" -- User-defined tab group
		logger's debugf("sutTabGroupName: {}", sutTabGroupName)
		
		sut's findWindowByTabGroupName(sutTabGroupName)
		assertThat of std given condition:result is not missing value, messageOnFail:"FAILED"
		logger's info("Passed")
		
	else if caseIndex is 3 then
		
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
	
	script SafariWindowFinderDecorator
		property parent : safariInstance
		
		on findWindowByTabGroupName(tabGroupName)
			if running of application "Safari" is false then return missing value
			
			tell application "System Events" to tell process "Safari"
				try
					return first window whose title starts with tabGroupName & unic's SEPARATOR
				end try
			end tell
			
			missing value
		end findWindowByTabGroupName
	end script
end decorate
