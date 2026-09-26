(*
	@Purpose:
		Profile related handlers for both the safari and safari-tab scripts.

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Safari/26.6/dec-safari-profile

	@Created: Mon, Oct 27, 2025, at 07:21:42 AM
	@Last Modified: 2026-03-24 17:45:55
	
	@Change Logs:
		Fri, Sep 25, 2026 - Added isProfilesActive.
*)
use textUtil : script "core/string"

use loggerFactory : script "core/logger-factory"

use safariTabLib : script "core/safari-tab"

property logger : missing value

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		Main
		Manual: New Tab on Profile
		Manual: Close Windows With Profile
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
	
	logger's infof("Profiles active: {}", sut's isProfilesActive())
	logger's infof("Has profile Unicorn: {}", sut's hasWindowWithProfile("Unicorn"))
	logger's infof("Has profile Personal: {}", sut's hasWindowWithProfile("Personal"))
	logger's infof("Has profile Business: {}", sut's hasWindowWithProfile("Business"))
	
	set safariTab to sut's getFrontTab()
	if safariTab is not missing value then
		set sutTab to decorateTab(safariTab)
		logger's infof("Front tab profile: {}", sutTab's getProfile())
	end if
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		set sutProfileName to "Business"
		-- set sutProfileName to "Personal"
		logger's debugf("sutProfileName: {}", sutProfileName)
		
		sut's newTabOnProfile(sutProfileName, "https://www.example.com")
		
	else if caseIndex is 3 then
		set sutProfileName to "Business"
		set sutProfileName to "Personal"
		logger's debugf("sutProfileName: {}", sutProfileName)
		set closedCount to sut's closeWindowsWithProfile(sutProfileName)
		logger's infof("Closed {} window(s)", closedCount)
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck



on decorateTab(safariTabScript)
	loggerFactory's inject(me)
	
	script SafariTabProfileDecorator
		property parent : safariTabScript
		
		on getProfile()
			if running of application "Safari" is false then return missing value
			
			tell application "System Events" to tell process "Safari"
				-- menu button 1 of group 1 of toolbar 1 of front window  -- Pre-Tahoe.
				try
					menu button 1 of toolbar 1 of front window
					return textUtil's stringBetween(value of attribute "AXIdentifier" of result, "Profile=", "&")
				end try
			end tell
			
			missing value
		end getProfile
	end script
end decorateTab


(*  *)
on decorate(safariInstance)
	loggerFactory's inject(me)
	
	script SafariProfileDecorator
		property parent : safariInstance
		
		
		(*
			@returns true if Safari profiles are set up, based on the front window's toolbar button.
			Falls back to the Profiles folder check when Safari is not running or has no window.
		*)
		on isProfilesActive()
			if running of application "Safari" is false then return continue isProfilesActive()
			
			tell application "System Events" to tell process "Safari"
				if (count of windows) is 0 then return continue isProfilesActive()
				try
					return exists (first menu button of toolbar 1 of front window whose value of attribute "AXIdentifier" contains "profile=")
				end try
			end tell
			
			false
		end isProfilesActive
		
		
		(* Checks available profiles via the Safari icon in the Dock. *)
		on hasWindowWithProfile(profileName)
			if running of application "Safari" is false then
				return false
				
				(*
				launch application "Safari" -- Run the app and not show any window.
				delay 0.5
				*)
			end if
			
			tell application "System Events" to tell process "Safari"
				try
					return exists (first window whose title starts with profileName)
				end try
			end tell
			
			false
		end hasWindowWithProfile
		
		
		(*
			Closes every Safari window whose toolbar profile matches profileName.
			@returns the number of windows closed.
		*)
		on closeWindowsWithProfile(profileName)
			if running of application "Safari" is false then return 0
			
			set profileNeedle to "profile=" & profileName
			set windowNamesToClose to {}
			
			tell application "System Events" to tell process "Safari"
				try
					set windowNamesToClose to name of every window whose value of attribute "AXIdentifier" of menu button 1 of toolbar 1 contains profileNeedle
				end try
			end tell
			
			if windowNamesToClose is {} then return 0
			
			set closedCount to 0
			tell application "Safari"
				repeat with nextWindowName in windowNamesToClose
					try
						close (first window whose name is equal to nextWindowName)
						set closedCount to closedCount + 1
					on error the errorMessage
						logger's warn(errorMessage)
					end try
				end repeat
			end tell
			
			closedCount
		end closeWindowsWithProfile
		
		
		(*
			Test Cases:
				1. App not running
				2. Running without a window
				3. Running with a window using the same profile.
				4. Running with a window using a different profile.
				5. Profiles active/inactive - /ok.
				
		*)
		on newTabOnProfile(profileName, targetUrl)
			if not isProfilesActive() then return missing value
			
			if running of application "Safari" is false then
				activate application "Safari"
			end if
			
			tell application "Safari"
				try
					if (count of (windows whose visible is true)) is 0 then
						return my newWindowWithProfile(targetUrl, profileName)
					end if
				on error
					return my newWindowWithProfile(targetUrl, profileName)
				end try
			end tell
			
			-- main's focusWindowWithToolbar()
			focusWindowWithToolbar()
			
			-- logger's debugf("theUrl: {}", theUrl)
			tell application "Safari"
				try
					set appWindow to (first window whose name starts with profileName) -- Error on missing profile.
				on error the errorMessage number the errorNumber
					logger's warn(errorMessage)
					logger's fatalf("Profile {} was not found", profileName)
					return missing value
				end try
				
				tell appWindow to set current tab to (make new tab with properties {URL:targetUrl})
				set miniaturized of appWindow to false
				set tabTotal to count of tabs of appWindow
			end tell
			
			safariTabLib's new(id of appWindow, tabTotal, me)
			
		end newTabOnProfile
	end script
end decorate
