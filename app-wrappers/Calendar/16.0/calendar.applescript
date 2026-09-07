(*
	@Purpose:
		Calendar wrapper backed by EventKit.

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

use AppleScript version "2.4"
use framework "Foundation"
use framework "EventKit"
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
	
	set IS_TEST of sut to true
	set TEST_DATETIME of sut to sut's makeDateTime(2026, 9, 7, 9, 0, 0)
	
	logger's infof("Computed current date: {}", sut's getCurrentDate()) 
	logger's infof("Is today a holiday?: {}", sut's isTodayHoliday())
	
	if caseIndex is 2 then
		set todayEvents to sut's getEventsToday()
		logger's infof("Events today: {}", count of todayEvents)
		repeat with nextCalendarEvent in todayEvents
			logger's infof("  {} | {} - {} | allDay: {} | holiday: {}", {nextCalendarEvent's eventName, nextCalendarEvent's startDate, nextCalendarEvent's endDate, nextCalendarEvent's isWholeDayEvent(), nextCalendarEvent's isHoliday()})
		end repeat
		
	else if caseIndex is 3 then
		set upcomingEvents to sut's getUpcomingEventsToday()
		logger's infof("Upcoming events today: {}", count of upcomingEvents)
		repeat with nextCalendarEvent in upcomingEvents
			logger's infof("  {} | {} - {} | allDay: {} | holiday: {}", {nextCalendarEvent's eventName, nextCalendarEvent's startDate, nextCalendarEvent's endDate, nextCalendarEvent's isWholeDayEvent(), nextCalendarEvent's isHoliday()})
		end repeat
		
	end if
	
	spot's finish()
	logger's finish()
end spotCheck


on asDateToNSDate(asDate)
	set sysCalendar to current application's NSCalendar's currentCalendar()
	set dateComps to current application's NSDateComponents's alloc()'s init()
	dateComps's setYear:(year of asDate)
	dateComps's setMonth:((month of asDate) as integer)
	dateComps's setDay:(day of asDate)
	dateComps's setHour:(hours of asDate)
	dateComps's setMinute:(minutes of asDate)
	dateComps's setSecond:(seconds of asDate)
	sysCalendar's dateFromComponents:dateComps
end asDateToNSDate


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
			set nsToday to calendarLib's asDateToNSDate(my getCurrentDate())
			
			set sysCalendar to current application's NSCalendar's currentCalendar()
			set startOfDay to sysCalendar's startOfDayForDate:nsToday
			
			set timeComps to current application's NSDateComponents's alloc()'s init()
			timeComps's setDay:1
			timeComps's setSecond:-1
			set endOfDay to sysCalendar's dateByAddingComponents:timeComps toDate:startOfDay options:0
			
			set eventStore to current application's EKEventStore's alloc()'s init()
			set searchPredicate to eventStore's predicateForEventsWithStartDate:startOfDay endDate:endOfDay calendars:(missing value)
			set theEvents to eventStore's eventsMatchingPredicate:searchPredicate
			
			set todayEvents to {}
			if theEvents is not missing value then
				repeat with anEvent in theEvents
					set end of todayEvents to calendarEventLib's newFromEkEvent(anEvent)
				end repeat
			end if
			
			todayEvents
		end getEventsToday
		
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
