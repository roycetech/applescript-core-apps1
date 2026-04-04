(*
	@Purpose:
		Manipulate the Script Editor Settings > General tab.

	@Project:
		applescript-core

	@Build:
		./scripts/build-lib.sh 'app-wrappers/Script Editor/2.11/dec-script-editor-settings-general'

	@Created: Sat, May 24, 2025 at 07:35:00 AM
	@Last Modified: Sat, May 24, 2025 at 07:35:00 AM
	@Change Logs:
*)
use loggerFactory : script "core/logger-factory"

property logger : missing value

if {"Script Editor", "Script Debugger"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		Main
		Manual: Set Show Script Menu On
		Manual: Set Show Script Menu Off
		Manual: Set Show Computer Scripts On
		Manual: Set Show Computer Scripts Off
		
