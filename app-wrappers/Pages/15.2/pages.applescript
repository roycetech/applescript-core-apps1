(*
	@Purpose:
		TODO

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Pages/15.2/pages

	@Created: Wed, Apr 22, 2026 at 09:40:53 AM
	@Last Modified: July 24, 2023 10:56 AM
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
	")
	
	set spotScript to script "core/spot-test"
	set spotClass to spotScript's new()
	set spot to spotClass's new(me, cases)
	set {caseIndex, caseDesc} to spot's start()
	if caseIndex is 0 then
		logger's finish()
		return
	end if
	
	set sut to new()
	log sut's hasTabbedWindows()
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*  *)
on new()
	loggerFactory's inject(me)
	
	set appWithFileDialogLib to script "core/abstract-app-with-file-dialog"
	set appWithFileDialog to appWithFileDialogLib's new("Pages")
	
	script PagesInstance
		property parent : appWithFileDialog
		
	end script
end new
