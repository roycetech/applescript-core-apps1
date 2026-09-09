(*
	@Purpose:
		Calendar event instance backed by EventKit.

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Calendar/16.0/calendar-event

	@Created: Mon, Sep 07, 2026 at 09:48:56 AM
	@Last Modified: July 24, 2023 10:56 AM
*)

use framework "Foundation"
use framework "EventKit"
use scripting additions

use loggerFactory : script "core/logger-factory"

property logger : missing value

property US_HOLIDAYS : {Â
	"New Year's Day", Â
	"Birthday of Martin Luther King, Jr.", Â
	"Washington's Birthday", Â
	"Memorial Day", Â
	"Juneteenth National Independence Day", Â
	"Independence Day", Â
	"Labor Day", Â
	"Columbus Day", Â
	"Veterans Day", Â
	"Thanksgiving Day", Â
	"Christmas Day"}

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
	if caseIndex is 1 then

	else if caseIndex is 2 then

	else

	end if

	spot's finish()
	logger's finish()
end spotCheck


(*
	@param eventRecord - {eventName, eventStart, eventEnd, eventLink, eventNotes, allDay}
	@param calendarName - optional calendar name for holiday detection.
	@returns CalendarEventInstance
*)
on newFromCalendarRecord(eventRecord, calendarName)
	loggerFactory's inject(me)
	set libRef to me
	set holidayNames to US_HOLIDAYS
	
	script CalendarEventInstance
		property eventName : missing value
		property isAllDay : false
		property startDate : missing value
		property endDate : missing value
		property location : missing value
		property description : missing value
		property attendees : missing value
		property notes : missing value
		property recurrence : missing value
		property reminders : missing value
		property attachments : missing value
		property calendarName : missing value
		
		on isWholeDayEvent()
			isAllDay
		end isWholeDayEvent
		
		on isHoliday()
			if calendarName is not missing value then
				ignoring case
					if calendarName contains "holiday" then return true
				end ignoring
			end if
			
			if not isWholeDayEvent() then return false
			
			repeat with holidayName in holidayNames
				if eventName is holidayName then return true
				if eventName contains holidayName then return true
			end repeat
			
			false
		end isHoliday
		
		on isOnline()
			libRef's _isOnlineEvent(my location, my description)
		end isOnline
		
		on getMeetingUrl()
			libRef's _meetingUrl(my location, my description)
		end getMeetingUrl
	end script
	
	set eventLink to eventLink of eventRecord
	set eventDescription to missing value
	if eventLink is not "No link" then set eventDescription to eventLink
	
	tell CalendarEventInstance
		set its eventName to eventName of eventRecord
		set its isAllDay to allDay of eventRecord
		set its startDate to eventStart of eventRecord
		set its endDate to eventEnd of eventRecord
		set its location to missing value
		set its notes to eventNotes of eventRecord
		set its description to eventDescription
		set its attendees to missing value
		set its recurrence to missing value
		set its reminders to missing value
		set its attachments to missing value
		set its calendarName to calendarName
	end tell
	
	CalendarEventInstance
end newFromCalendarRecord


(*
	@param ekEvent - EKEvent from EventKit.
	@returns CalendarEventInstance
*)
on newFromEkEvent(ekEvent)
	loggerFactory's inject(me)
	set libRef to me
	set holidayNames to US_HOLIDAYS
	
	script CalendarEventInstance
		property eventName : missing value
		property isAllDay : false
		property startDate : missing value
		property endDate : missing value
		property location : missing value
		property description : missing value
		property attendees : missing value
		property notes : missing value
		property recurrence : missing value
		property reminders : missing value
		property attachments : missing value
		property calendarName : missing value
		
		on isWholeDayEvent()
			isAllDay
		end isWholeDayEvent
		
		on isHoliday()
			if calendarName is not missing value then
				ignoring case
					if calendarName contains "holiday" then return true
				end ignoring
			end if
			
			if not isWholeDayEvent() then return false
			
			repeat with holidayName in holidayNames
				if eventName is holidayName then return true
				if eventName contains holidayName then return true
			end repeat
			
			false
		end isHoliday
		
		on isOnline()
			libRef's _isOnlineEvent(my location, my description)
		end isOnline
		
		on getMeetingUrl()
			libRef's _meetingUrl(my location, my description)
		end getMeetingUrl
	end script
	
	set eventTitle to ekEvent's title()
	if eventTitle is not missing value then
		set eventTitle to eventTitle as text
	else
		set eventTitle to ""
	end if
	
	set eventIsAllDay to (ekEvent's isAllDay()) as boolean
	set eventStartDate to (ekEvent's startDate()) as date
	set eventEndDate to (ekEvent's endDate()) as date
	
	set eventLocation to missing value
	set rawLocation to ekEvent's location()
	if rawLocation is not missing value then set eventLocation to rawLocation as text
	
	set eventNotes to missing value
	set rawNotes to ekEvent's notes()
	if rawNotes is not missing value then set eventNotes to rawNotes as text
	
	set eventDescription to missing value
	set rawURL to ekEvent's |URL|()
	if rawURL is not missing value then set eventDescription to (rawURL's absoluteString()) as text
	
	set eventAttendees to missing value
	set rawAttendees to ekEvent's attendees()
	if rawAttendees is not missing value then
		set attendeeNames to {}
		repeat with nextAttendee in rawAttendees
			set attendeeName to nextAttendee's |name|()
			if attendeeName is not missing value then
				set end of attendeeNames to attendeeName as text
			end if
		end repeat
		if attendeeNames is not {} then set eventAttendees to attendeeNames
	end if
	
	set eventRecurrence to missing value
	set rawRecurrenceRules to ekEvent's recurrenceRules()
	if rawRecurrenceRules is not missing value then set eventRecurrence to rawRecurrenceRules
	
	set eventReminders to missing value
	set rawAlarms to ekEvent's alarms()
	if rawAlarms is not missing value then set eventReminders to rawAlarms
	
	set eventAttachments to missing value
	try
		set rawAttachments to ekEvent's attachments()
		if rawAttachments is not missing value then set eventAttachments to rawAttachments
	end try
	
	set eventCalendarName to missing value
	set eventCalendar to ekEvent's calendar()
	if eventCalendar is not missing value then
		set rawCalendarTitle to eventCalendar's title()
		if rawCalendarTitle is not missing value then set eventCalendarName to rawCalendarTitle as text
	end if
	
	tell CalendarEventInstance
		set its eventName to eventTitle
		set its isAllDay to eventIsAllDay
		set its startDate to eventStartDate
		set its endDate to eventEndDate
		set its location to eventLocation
		set its notes to eventNotes
		set its description to eventDescription
		set its attendees to eventAttendees
		set its recurrence to eventRecurrence
		set its reminders to eventReminders
		set its attachments to eventAttachments
		set its calendarName to eventCalendarName
	end tell
	
	CalendarEventInstance
end newFromEkEvent


(*
	@returns boolean - true when urlText is a meeting link, not a map/geo URL.
*)
on _isMeetingUrl(urlText)
	if urlText is missing value then return false
	if urlText is "No link" then return false
	
	set isUrl to false
	ignoring case
		if urlText starts with "http://" or urlText starts with "https://" or urlText starts with "zoommtg://" then set isUrl to true
	end ignoring
	if not isUrl then return false
	
	ignoring case
		if urlText contains "maps.apple.com" then return false
		if urlText contains "maps.google.com" then return false
		if urlText contains "google.com/maps" then return false
		if urlText starts with "geo:" then return false
		if urlText starts with "maps://" then return false
	end ignoring
	
	true
end _isMeetingUrl


(*
	@param candidateLocation - event location text.
	@param candidateDescription - event URL / link text.
	@returns text or missing value - first non-map meeting URL found.
*)
on _meetingUrl(candidateLocation, candidateDescription)
	repeat with candidate in {candidateLocation, candidateDescription}
		if my _isMeetingUrl(candidate) then return candidate
	end repeat
	missing value
end _meetingUrl


(*
	@param candidateLocation - event location text.
	@param candidateDescription - event URL / link text.
	@returns boolean - true when either field holds a non-map meeting URL.
*)
on _isOnlineEvent(candidateLocation, candidateDescription)
	my _meetingUrl(candidateLocation, candidateDescription) is not missing value
end _isOnlineEvent
