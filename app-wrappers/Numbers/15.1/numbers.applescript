(*
	@Purpose:
		TODO

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Numbers/15.1/numbers

	@Created: Tue, Jul 07, 2026 at 03:41:23 PM
	@Last Modified: July 24, 2023 10:56 AM
*)

use loggerFactory : script "core/logger-factory"

property logger : missing value

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()

	logger's finish()
end spotCheck


(*  *)
on new()
	loggerFactory's inject(me)

	script NumbersInstance
		on libHandler()

		end libHandler
	end script
end libHandler
