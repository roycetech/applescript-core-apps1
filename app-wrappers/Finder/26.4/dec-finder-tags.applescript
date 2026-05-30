(*
	@Purpose:
		Handlers around Finder tags

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Finder/26.4/dec-finder-tags

	@Created: Tue, Apr 28, 2026 at 08:43:51 AM
	@Last Modified: Tue, Apr 28, 2026 at 08:43:51 AM
	@Change Logs:
*)
use scripting additions

use framework "Foundation"

use fileUtil : script "core/file"
use listUtil : script "core/list"

use loggerFactory : script "core/logger-factory"

property logger : missing value

property TopLevel : me

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		Main
		Manual: POSIX Path - Tag
		Manual: POSIX Path - Untag
		Manual: POSIX Path - Clear All Tags
		Manual: Selection - Tag

		Manual: Selection - Untag		
		Manual: Selection - Clear All Tags
		Dummy
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
	set sutLib to script "core/finder"
	set sut to sutLib's new()
	set sut to decorate(sut)
	
	set sutPosixPath to "~/Desktop/test.txt"
	logger's debugf("sutPosixPath: {}", sutPosixPath)
	
	if caseIndex is 1 then
		
	else if caseIndex is 2 then
		set sutNewTag to "unicorn"
		logger's debugf("sutNewTag: {}", sutNewTag)
		
		sut's tagPosixPath(sutPosixPath, sutNewTag)
		
	else if caseIndex is 3 then
		set tagToRemove to "unicorn"
		logger's debugf("tagToRemove: {}", tagToRemove)
		
		sut's untagPosixPath(sutPosixPath, tagToRemove)
		
	else if caseIndex is 4 then
		sut's clearTagsPosixPath(sutPosixPath)
		
	else if caseIndex is 5 then
		set sutNewTag to "unicorn"
		logger's debugf("sutNewTag: {}", sutNewTag)
		sut's tagSelectedObjects(sutNewTag)
		
	else if caseIndex is 6 then
		set tagToRemove to "unicorn"
		logger's debugf("tagToRemove: {}", tagToRemove)
		sut's untagSelectedObjects(tagToRemove)
		
	else if caseIndex is 7 then
		sut's clearTagsSelectedObjects()
		
	else
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


(*  *)
on decorate(mainScript)
	loggerFactory's inject(me)
	
	script FinderTagsDecorator
		property parent : mainScript
		
		
		on tagPosixPath(posixPath, newTag)
			TopLevel's _tagPosixPath(posixPath, newTag)
		end tagPosixPath
		
		
		on untagPosixPath(posixPath, tagToRemove)
			TopLevel's _untagPosixPath(posixPath, tagToRemove)
		end untagPosixPath
		
		
		on clearTagsPosixPath(posixPath)
			TopLevel's _clearTagsPosixPath(posixPath)
		end clearTagsPosixPath
		
		
		on tagSelectedObjects(newTag)
			if newTag is missing value then return
			
			set selectionPaths to parent's getSelectionPaths()
			repeat with nextSelectedPath in selectionPaths
				TopLevel's _tagPosixPath(nextSelectedPath, newTag)
			end repeat
		end tagSelectedObjects
		
		on untagSelectedObjects(tagToRemove)
			if tagToRemove is missing value then return
			
			set selectionPaths to parent's getSelectionPaths()
			repeat with nextSelectedPath in selectionPaths
				TopLevel's _untagPosixPath(nextSelectedPath, tagToRemove)
			end repeat
		end untagSelectedObjects
		
		
		on clearTagsSelectedObjects()
			set selectionPaths to parent's getSelectionPaths()
			repeat with nextSelectedPath in selectionPaths
				TopLevel's _clearTagsPosixPath(nextSelectedPath)
			end repeat
		end clearTagsSelectedObjects
	end script
end decorate

(* NOTE: Below handlers that uses Foundation fails to work when put inside the script in a script instance, thus they are referenced instead. *)

(*
	Applies pre-created tag to a POSIX path. New tags will use default color.
*)
on _tagPosixPath(posixPath, newTag)
	if newTag is missing value then return false
	if newTag is "" then return false
	if posixPath is missing value then return false
	
	set calcPosixPath to fileUtil's expandPath(posixPath)
	-- logger's debugf("calcPosixPath: {}", calcPosixPath)
	
	-- Convert to NSURL
	set fileURL to current application's |NSURL|'s fileURLWithPath:calcPosixPath
	
	-- Get existing tags
	set {theResult, existingTags, anError} to fileURL's getResourceValue:(reference) forKey:(current application's NSURLTagNamesKey) |error|:(reference)
	
	if existingTags is missing value then
		set existingTags to {}
	else
		set existingTags to existingTags as list
	end if
	
	set newTags to existingTags & {}
	if existingTags does not contain newTag then
		-- Add a new tag
		set end of newTags to newTag
	end if
	
	-- Apply tags
	fileURL's setResourceValue:newTags forKey:(current application's NSURLTagNamesKey) |error|:(missing value)
end _tagPosixPath


on _untagPosixPath(posixPath, tagToRemove)
	if tagToRemove is missing value then return false
	if tagToRemove is "" then return false
	if posixPath is missing value then return false
	
	set calcPosixPath to fileUtil's expandPath(posixPath)
	-- Convert to NSURL
	set fileURL to current application's |NSURL|'s fileURLWithPath:calcPosixPath
	
	-- Get existing tags
	set {theResult, existingTags, anError} to fileURL's getResourceValue:(reference) forKey:(current application's NSURLTagNamesKey) |error|:(reference)
	set existingTags to existingTags as list
	
	if existingTags contains tagToRemove then
		set existingTags to existingTags & {}
		set cleanedTags to listUtil's remove(existingTags, tagToRemove)
		
		-- Apply tags
		fileURL's setResourceValue:cleanedTags forKey:(current application's NSURLTagNamesKey) |error|:(missing value)
	end if
	
	false
end _untagPosixPath


on _clearTagsPosixPath(posixPath)
	if posixPath is missing value then return false
	
	set calcPosixPath to fileUtil's expandPath(posixPath)
	-- Convert to NSURL
	set fileURL to current application's |NSURL|'s fileURLWithPath:calcPosixPath
	
	-- Get existing tags
	set {theResult, existingTags, anError} to fileURL's getResourceValue:(reference) forKey:(current application's NSURLTagNamesKey) |error|:(reference)
	set existingTags to existingTags as list
	
	if the number of items in existingTags is not 0 then
		fileURL's setResourceValue:{} forKey:(current application's NSURLTagNamesKey) |error|:(missing value)
		return true
	end if
	
	false
end _clearTagsPosixPath
