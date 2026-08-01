(*
	Update the following quite obvious if you read through the template code.:
	spotCheck()
		thisCaseId
		base library instantiation

		logger constructor parameter inside init handler

	decorate()
		instance name
		handler name
*)
use listUtil : script "core/list"

use safariTechPreviewLib : script "core/safari-technology-preview"

use loggerFactory : script "core/logger-factory"


property logger : missing value
property safariTechPreview : missing value

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set cases to listUtil's splitAndTrimParagraphs("
		Basic
	")
	
	set spotScript to script "core/spot-test"
	set spotClass to spotScript's new()
	set spot to spotClass's new(me, cases)
	set {caseIndex, caseDesc} to spot's start()
	if caseIndex is 0 then
		logger's finish()
		return
	end if
	
	activate application "Safari Technology Preview"
	set frontTab to safariTechPreview's getFrontTab()
	if name of frontTab is not "ScriptSafariTechnologyPreviewJavaScript" then set frontTab to decorate(frontTab)
	
	if caseIndex is 1 then
		frontTab's runScriptPlain("alert('spot')")
		
	else if caseIndex is 2 then
		
	else if caseIndex is 3 then
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*  *)
on decorate(mainScript)
	loggerFactory's inject(me)
	set safariTechPreview to safariTechPreviewLib's new()
	logger's debug("decorating...")
	
	script ScriptSafariTechnologyPreviewJavaScript
		property parent : mainScript
		
		(*
			Cross-browser JavaScript execution contract:
			executeJavaScript          - side effects, errors swallowed
			evaluateJavaScript         - returns result to AppleScript
			executeJavaScriptUnchecked - raw passthrough, no error handling
			runScript* names are legacy aliases.
		*)
		(*
			@Deprecation, use executeJavaScriptUnchecked().
		*)
		on runScriptPlain(scriptText)
			executeJavaScriptUnchecked(scriptText)
		end runScriptPlain

		on executeJavaScript(javascriptSource)
			set theTab to _getTab()
			tell application "Safari Technology Preview" to do JavaScript ("
				try {
					" & javascriptSource & "
				} catch(e) {
					e.message;
				}
			") in theTab
		end executeJavaScript

		on evaluateJavaScript(javascriptSource)
			if javascriptSource does not end with ";" then set javascriptSource to javascriptSource & ";"
			set theTab to _getTab()
			tell application "Safari Technology Preview" to return do JavaScript ("try {" & javascriptSource & "} catch(e) { e.message; }") in theTab
		end evaluateJavaScript

		on executeJavaScriptUnchecked(javascriptSource)
			set theTab to _getTab()
			tell application "Safari Technology Preview" to do JavaScript javascriptSource in theTab
		end executeJavaScriptUnchecked
	end script
end decorate
