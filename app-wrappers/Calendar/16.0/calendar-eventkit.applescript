(*
	@Purpose:
		Fetch calendar events for a date range via EventKit (expanded occurrences).

	@Project:
		applescript-core-apps1

	@Build:
		./scripts/build-lib.sh app-wrappers/Calendar/16.0/calendar-eventkit
*)

use scripting additions

use framework "Foundation"
use framework "EventKit"

use calendarEventLib : script "core/calendar-event"

property ekReferenceDate : missing value
property ekEventStoreSingleton : missing value
property eventKitAccessFinished : false
property eventKitAccessGranted : false


on getEkReferenceDate()
	if ekReferenceDate is missing value then set ekReferenceDate to (current application's NSDate's dateWithTimeIntervalSinceReferenceDate:0) as date
	ekReferenceDate
end getEkReferenceDate


on nsDateFromAppleScriptDate(dt)
	set interval to dt - (my getEkReferenceDate())
	current application's NSDate's dateWithTimeIntervalSinceReferenceDate:interval
end nsDateFromAppleScriptDate


on getSharedEventStore()
	if ekEventStoreSingleton is missing value then set ekEventStoreSingleton to current application's EKEventStore's alloc()'s init()
	ekEventStoreSingleton
end getSharedEventStore


on isEventKitAuthorized()
	set authStatus to current application's EKEventStore's authorizationStatusForEntityType:0
	authStatus is 3 or authStatus is 4
end isEventKitAuthorized


on eventKitAccessCompletionHandler(granted, err)
	set eventKitAccessGranted to granted as boolean
	set eventKitAccessFinished to true
end eventKitAccessCompletionHandler


on requestEventKitAccessIfNeeded(eventStore)
	if my isEventKitAuthorized() then return true
	
	set eventKitAccessFinished to false
	set eventKitAccessGranted to false
	
	try
		eventStore's |requestFullAccessToEventsWithCompletion:|(my eventKitAccessCompletionHandler)
	on error
		try
			eventStore's requestAccessToEntityType:0 |completionHandler|:(my eventKitAccessCompletionHandler)
		end try
	end try
	
	set waitDeadline to (current date) + 60
	repeat while eventKitAccessFinished is false and (current date) < waitDeadline
		delay 0.05
	end repeat
	
	eventKitAccessGranted
end requestEventKitAccessIfNeeded


(*
	@param startOfDay - AppleScript date at 00:00:00 for the day.
	@param endOfDay - AppleScript date at 23:59:59 for the day.
	@returns list of CalendarEventInstance whose start falls within [startOfDay, endOfDay].
*)
on eventsStartingBetween(startOfDay, endOfDay)
	set eventStore to my getSharedEventStore()
	if not (my requestEventKitAccessIfNeeded(eventStore)) then error "EventKit calendar access was not granted."
	
	set startNSDate to my nsDateFromAppleScriptDate(startOfDay)
	set endNSDate to my nsDateFromAppleScriptDate(endOfDay)
	set thePredicate to eventStore's predicateForEventsWithStartDate:startNSDate endDate:endNSDate calendars:missing value
	set ekEvents to eventStore's eventsMatchingPredicate:thePredicate
	
	set matchedEvents to {}
	repeat with ekEvent in ekEvents
		set eventStart to (ekEvent's startDate()) as date
		if eventStart is greater than or equal to startOfDay and eventStart is less than or equal to endOfDay then
			set end of matchedEvents to calendarEventLib's newFromEkEvent(ekEvent)
		end if
	end repeat
	
	matchedEvents
end eventsStartingBetween
