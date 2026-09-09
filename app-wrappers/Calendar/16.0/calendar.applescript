(*
	@Purpose:
		Calendar wrapper backed by the Calendar app.

	@Testing:
		Set IS_TEST to true and TEST_DATETIME using makeDateTime on the
		CalendarInstance returned by new(), e.g. makeDateTime(2026, 9, 7, 9, 0, 0).

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Calendar/16.0/calendar

	@Created: Mon, Sep 07, 2026 at 09:59:19 AM
	@Last Modified: July 24, 2023 10:56 AM
*)

use scripting additions

use loggerFactory : script "core/logger-factory"
use calendarEventLib : script "core/calendar-event"

property logger : missing value

if {"Script Editor", "Script Debugger", "osascript"} contains the name of current application then spotCheck()

on spotCheck()
	loggerFactory's inject(me)
	logger's start()
	
	set listUtil to script "core/list"
	set cases to listUtil's splitAndTrimParagraphs("
		NOOP:
		Get Events Today
		Get Upcoming Events Today
		Get Online Events Today
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
	
	-- set IS_TEST of sut to true  -- Comment out this line for current date.
	set TEST_DATETIME of sut to sut's makeDateTime(2026, 9, 8, 9, 0, 0)
	
	logger's infof("Computed current date: {}", sut's getCurrentDate())
	logger's infof("Is today a holiday?: {}", sut's isTodayHoliday())
	logger's infof("Has events today?: {}", sut's hasEventsToday())
	logger's infof("Has online events today?: {}", sut's hasOnlineEventsToday())
	
	if caseIndex is 2 then
		set todayEvents to sut's getEventsToday()
		logger's infof("Events today: {}", count of todayEvents)
		repeat with nextCalendarEvent in todayEvents
			logger's infof("  {} 
| Start: {}
| Ends: {} 
| allDay: {} 
| holiday: {}
| Online?: {}
| Location: {}", {nextCalendarEvent's eventName, nextCalendarEvent's startDate, nextCalendarEvent's endDate, nextCalendarEvent's isWholeDayEvent(), nextCalendarEvent's isHoliday(), nextCalendarEvent's isOnline(), nextCalendarEvent's getMeetingUrl()})
		end repeat
		
	else if caseIndex is 3 then
		set upcomingEvents to sut's getUpcomingEventsToday()
		logger's infof("Upcoming events today: {}", count of upcomingEvents)
		repeat with nextCalendarEvent in upcomingEvents
			logger's infof("  {} 
| Start: {}
| Ends: {} 
| allDay: {} 
| holiday: {}
| Online?: {}
| Location: {}", {nextCalendarEvent's eventName, nextCalendarEvent's startDate, nextCalendarEvent's endDate, nextCalendarEvent's isWholeDayEvent(), nextCalendarEvent's isHoliday(), nextCalendarEvent's isOnline(), nextCalendarEvent's getMeetingUrl()})
		end repeat
		
	else if caseIndex is 4 then
		set onlineEvents to sut's getOnlineEvents()
		logger's infof("Online events today: {}", count of onlineEvents)
		repeat with nextCalendarEvent in onlineEvents
			logger's infof("  {} 
| Start: {}
| Ends: {} 
| Meeting URL: {}", {nextCalendarEvent's eventName, nextCalendarEvent's startDate, nextCalendarEvent's endDate, nextCalendarEvent's getMeetingUrl()})
		end repeat
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


on fallsOnToday(recurStr, checkDate, origStart)
	set dMonth to (month of checkDate) as integer
	set dDay to day of checkDate
	
	set wkDay to weekday of checkDate
	if wkDay is Sunday then set dIcalDay to "SU"
	if wkDay is Monday then set dIcalDay to "MO"
	if wkDay is Tuesday then set dIcalDay to "TU"
	if wkDay is Wednesday then set dIcalDay to "WE"
	if wkDay is Thursday then set dIcalDay to "TH"
	if wkDay is Friday then set dIcalDay to "FR"
	if wkDay is Saturday then set dIcalDay to "SA"
	
	set nthOccurrence to ((dDay - 1) div 7) + 1
	set matchDayStr to (nthOccurrence as text) & dIcalDay
	
	set hasMonthRule to false
	set hasDayRule to false
	set isRightMonth to false
	set isRightDay to false
	
	set AppleScript's text item delimiters to ";"
	set ruleParts to text items of recurStr
	set AppleScript's text item delimiters to ""
	
	if recurStr contains "FREQ=DAILY" then return true
	
	repeat with aPart in ruleParts
		if aPart starts with "BYMONTH=" then
			set hasMonthRule to true
			set ruleMonth to (text 9 thru -1 of aPart) as integer
			if ruleMonth is dMonth then set isRightMonth to true
		else if aPart starts with "BYDAY=" then
			set hasDayRule to true
			set ruleDays to (text 7 thru -1 of aPart)
			if ruleDays contains matchDayStr or ruleDays contains dIcalDay then set isRightDay to true
		else if aPart starts with "BYMONTHDAY=" then
			set hasDayRule to true
			set ruleMonthDay to (text 12 thru -1 of aPart) as integer
			if ruleMonthDay is dDay then set isRightDay to true
		end if
	end repeat
	
	if recurStr contains "FREQ=WEEKLY" then
		if hasDayRule then
			if isRightDay then return true
		else
			if (weekday of origStart) is wkDay then return true
		end if
	end if
	
	if recurStr contains "FREQ=YEARLY" then
		if hasMonthRule and hasDayRule then
			if isRightMonth and isRightDay then return true
		else if not hasMonthRule and not hasDayRule then
			if (month of origStart is month of checkDate) and (day of origStart is day of checkDate) then return true
		else if hasMonthRule and not hasDayRule then
			if isRightMonth and (day of origStart is dDay) then return true
		end if
	end if
	
	false
end fallsOnToday


(*  *)
on new()
	loggerFactory's inject(me)
	set calendarLib to me
	
	script CalendarInstance
		property IS_TEST : false
		property TEST_DATETIME : missing value
		
		(*
			Override for testing. Set IS_TEST to true and optionally TEST_DATETIME.
			Build TEST_DATETIME with makeDateTime(year, month, day, hour, minute, second).
		*)
		on makeDateTime(y, m, d, h, min, s)
			set dt to (current date)
			set year of dt to y
			set month of dt to m
			set day of dt to d
			set hours of dt to h
			set minutes of dt to min
			set seconds of dt to s
			dt
		end makeDateTime
		
		on dateFrom(dt)
			makeDateTime(year of dt, (month of dt) as integer, day of dt, hours of dt, minutes of dt, seconds of dt)
		end dateFrom
		
		on getCurrentDate()
			if IS_TEST is false then return (current date)
			
			if TEST_DATETIME is missing value then return (current date)
			
			dateFrom(TEST_DATETIME)
		end getCurrentDate
		
		
		(*
			@returns list of CalendarEventInstance
		*)
		on getEventsToday()
			set instanceRef to me
			set todayAnchor to instanceRef's getCurrentDate()
			
			set startOfDay to instanceRef's dateFrom(todayAnchor)
			set time of startOfDay to 0
			set endOfDay to startOfDay + (1 * days) - 1
			
			set rawEvents to {}
			
			tell application "Calendar"
				set allCalendars to every calendar
				repeat with aCalendar in allCalendars
					set calName to name of aCalendar
					
					if calName contains "Holiday" then
						try
							set allHolidayProps to properties of events of aCalendar
							repeat with evtProps in allHolidayProps
								set origStart to start date of evtProps
								set recurRule to recurrence of evtProps
								
								set isHappeningToday to false
								
								if (origStart is greater than or equal to startOfDay) and (origStart is less than or equal to endOfDay) then
									set isHappeningToday to true
								end if
								
								if (origStart is less than startOfDay) and (recurRule is not missing value) then
									if calendarLib's fallsOnToday(recurRule, todayAnchor, origStart) then
										set isHappeningToday to true
									end if
								end if
								
								if isHappeningToday then
									set evtTitle to summary of evtProps
									set end of rawEvents to {calendarName:calName, eventRecord:{eventName:evtTitle, eventStart:startOfDay, eventEnd:endOfDay, eventLink:"No link", eventNotes:"", allDay:true}}
								end if
							end repeat
						end try
						
					else
						set calendarEvents to (every event of aCalendar whose start date is greater than or equal to startOfDay and start date is less than or equal to endOfDay)
						
						repeat with anEvent in calendarEvents
							set eventTitle to summary of anEvent
							set origStart to start date of anEvent
							set origEnd to end date of anEvent
							
							set isAllDay to false
							try
								set isAllDay to allday event of anEvent
							end try
							
							if isAllDay is true then
								set correctedStart to instanceRef's dateFrom(startOfDay)
								set correctedEnd to instanceRef's dateFrom(endOfDay)
							else
								set correctedStart to instanceRef's dateFrom(todayAnchor)
								set time of correctedStart to (time of origStart)
								set correctedEnd to instanceRef's dateFrom(todayAnchor)
								set time of correctedEnd to (time of origEnd)
								if correctedEnd is less than correctedStart then set correctedEnd to correctedEnd + (1 * days)
							end if
							
							set meetingLink to "No link"
							set rawURL to location of anEvent
							if rawURL is not missing value then set meetingLink to rawURL
							
							set eventNotes to ""
							set rawNotes to description of anEvent
							if rawNotes is not missing value then set eventNotes to rawNotes
							
							set end of rawEvents to {calendarName:calName, eventRecord:{eventName:eventTitle, eventStart:correctedStart, eventEnd:correctedEnd, eventLink:meetingLink, eventNotes:eventNotes, allDay:isAllDay}}
						end repeat
					end if
				end repeat
			end tell
			
			set todayEvents to {}
			repeat with rawEvent in rawEvents
				set end of todayEvents to calendarEventLib's newFromCalendarRecord(eventRecord of rawEvent, calendarName of rawEvent)
			end repeat
			
			todayEvents
		end getEventsToday
		
		(*
			@returns list of CalendarEventInstance - today's online events.
		*)
		on getOnlineEvents()
			set onlineEvents to {}
			
			repeat with nextCalendarEvent in my getEventsToday()
				if nextCalendarEvent's isOnline() then set end of onlineEvents to nextCalendarEvent
			end repeat
			
			onlineEvents
		end getOnlineEvents
		
		(*
			@returns boolean - true when today has one or more calendar events.
		*)
		on hasEventsToday()
			(count of my getEventsToday()) > 0
		end hasEventsToday
		
		(*
			@returns boolean - true when today has one or more online events.
		*)
		on hasOnlineEventsToday()
			(count of my getOnlineEvents()) > 0
		end hasOnlineEventsToday
		
		(*
			@returns list of CalendarEventInstance - today's timed events not yet started.
		*)
		on getUpcomingEventsToday()
			set rightNow to my getCurrentDate()
			set upcomingEvents to {}
			
			repeat with nextCalendarEvent in my getEventsToday()
				if (not nextCalendarEvent's isWholeDayEvent()) and (not nextCalendarEvent's isHoliday()) and (nextCalendarEvent's startDate is greater than rightNow) then
					set end of upcomingEvents to nextCalendarEvent
				end if
			end repeat
			
			upcomingEvents
		end getUpcomingEventsToday
		
		(*
			@returns boolean - true when any of today's events is a holiday.
		*)
		on isTodayHoliday()
			repeat with nextCalendarEvent in my getEventsToday()
				if nextCalendarEvent's isHoliday() then return true
			end repeat
			false
		end isTodayHoliday
	end script
	
	CalendarInstance
end new
