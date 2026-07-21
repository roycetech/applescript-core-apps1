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
		Manual: Archive Message
		Manual: Delete Message
		Manual: Move to Junk
		Dummy

		Manual: Reply to Message
		Manual: Reply to All
		Manual: Forward Message
		Dummy
		Dummy
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
		sut's archiveMessage()
		
	else if caseIndex is 3 then
		sut's deleteMessage()
		
	else if caseIndex is 4 then
		sut's junkMessage()
		
	else if caseIndex is 5 then
		sut's replyMessage()
		
	else if caseIndex is 6 then
		sut's replyAllMessage()
		
	else if caseIndex is 7 then
		sut's forwardMessage()
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*  *)
on decorate(mailInstance)
	loggerFactory's inject(me)
	
	script MailMessageDecorator
		property parent : mailInstance
		
		on replyMessage()
			set messageWindow to getMessageWindow()
			if messageWindow is missing value then
				logger's info("Message window was not found")
				return
			end if

			tell application "System Events" to tell process "Mail"
				set frontmost to true -- Required
				try
					click (first button of group 2 of toolbar 1 of front window whose description is "Reply")
				end try
			end tell			
		end replyMessage

		on replyAllMessage()
			set messageWindow to getMessageWindow()
			if messageWindow is missing value then
				logger's info("Message window was not found")
				return
			end if
			
			tell application "System Events" to tell process "Mail"
				set frontmost to true -- Required
				try
					click (first button of group 2 of toolbar 1 of front window whose description is "Reply All")
				end try
			end tell
		end replyAllMessage

		on forwardMessage()
			set messageWindow to getMessageWindow()
			if messageWindow is missing value then
				logger's info("Message window was not found")
				return
			end if

			tell application "System Events" to tell process "Mail"
				set frontmost to true -- Required
				try
					click (first button of group 2 of toolbar 1 of front window whose description is "Forward")
				end try
			end tell
		end forwardMessage
		
		on junkMessage()
			set messageWindow to getMessageWindow()
			if messageWindow is missing value then
				logger's info("Message window was not found")
				return
			end if
			
			tell application "System Events" to tell process "Mail"
				set frontmost to true -- Required
				try
					click (first button of group 1 of toolbar 1 of front window whose description is "Junk")
				end try
			end tell
		end junkMessage
		
		on archiveMessage()
			set messageWindow to getMessageWindow()
			if messageWindow is missing value then
				logger's info("Message window was not found")
				return
			end if
			
			tell application "System Events" to tell process "Mail"
				set frontmost to true -- Required
				try
					click (first button of group 1 of toolbar 1 of front window whose description is "Archive")
				end try
			end tell
		end archiveMessage
		
		on deleteMessage()
			set messageWindow to getMessageWindow()
			if messageWindow is missing value then
				logger's info("Message window was not found")
				return
			end if
			
			tell application "System Events" to tell process "Mail"
				set frontmost to true -- Required
				try
					click (first button of group 1 of toolbar 1 of front window whose description is "Delete")
				end try
			end tell
		end deleteMessage
	end script
	
end decorate

