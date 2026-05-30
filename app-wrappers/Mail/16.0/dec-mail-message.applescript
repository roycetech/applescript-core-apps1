(*
	@Purpose:
		Handlers for the mail message window.

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Mail/16.0/dec-mail-message

	@Created: Fri, May 08, 2026 at 09:32:21 AM
	@Last Modified: Fri, May 08, 2026 at 09:32:21 AM
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
		Manual: Delete Message
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
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		sut's deleteMessage()

	else if caseIndex is 3 then
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*  *)
on decorate(mainScript)
	loggerFactory's inject(me)
	
	script MailMessageDecorator
		property parent : mainScript

		on deleteMessage()
			set messageWindow to getMessageWindow()
			if messageWindow is missing value then 
				logger's info("Message window was not found")
				return
			end if
			
			tell application "System Events" to tell process "Mail"
				set frontmost to true  -- Required
				try 
					click first button of group 1 of toolbar 1 of front window whose description is "Delete"
				end try
			end tell
		end deleteMessage
	end script

end decorate

