-- 1. Define the start and end of today
set startOfDay to (current date)
set time of startOfDay to 0

set endOfDay to startOfDay + (1 * days) - 1

-- 2. Tell Calendar to grab the events
tell application "Calendar"
	set todayEvents to {}
	set allCalendars to every calendar
	
	repeat with aCalendar in allCalendars
		set calendarEvents to (every event of aCalendar whose start date ³ startOfDay and start date ² endOfDay)
		
		repeat with anEvent in calendarEvents
			set eventTitle to summary of anEvent
			log eventTitle
			
			-- Get original dates (which might be showing a past year)
			set origStart to start date of anEvent
			set origEnd to end date of anEvent
			
			-- Fix: Map the event's original time onto today's date
			set correctedStart to (current date)
			set time of correctedStart to (time of origStart)
			
			set correctedEnd to (current date)
			set time of correctedEnd to (time of origEnd)
			
			-- Check for a URL
			set rawURL to location of anEvent
			log rawURL
			if rawURL is missing value then
				set meetingLink to "No link"
			else
				set meetingLink to rawURL
			end if
			
			-- Check for Notes
			set rawNotes to description of anEvent
			if rawNotes is missing value then
				set eventNotes to ""
			else
				set eventNotes to rawNotes
			end if
			
			-- Append the corrected dates to the record
			set end of todayEvents to {eventName:eventTitle, eventStart:correctedStart, eventEnd:correctedEnd, eventLink:meetingLink, eventNotes:eventNotes}
		end repeat
	end repeat
	
end tell

return todayEvents
