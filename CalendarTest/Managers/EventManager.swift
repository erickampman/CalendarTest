//
//  ActivityManager.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/30/24.
//

import Foundation
import EventKit

@Observable
class EventManager {
	var store: EKEventStore
	
	enum AuthorizationStatus {
		case fullAccess
//		case writeAccess
		case denied
		case notDetermined
	}
	var authStatus: AuthorizationStatus = .notDetermined
	
	init() {
		self.store = EKEventStore()
	}
	
	/*
		Not bothering with WriteOnly access since this app handles update and delete too.
	 */
	var hasEventFullAccess: Bool {
		return authStatus == .fullAccess
	}
	
	func authStatusAsync() async -> AuthorizationStatus {
		switch authStatus {
		case .fullAccess:
			return .fullAccess
		case .denied:
			fallthrough // Maybe we can this time???
		case .notDetermined:
				do {
					let success = try await store.requestFullAccessToEvents()
					print("ActivityManager : requestFullAccessToEvents result \(success)")
					let access = EKEventStore.authorizationStatus(for: .event)
					print("ActivityManager : requestFullAccessToEvents access \(access)")
					if access == .fullAccess {
						authStatus = .fullAccess
					}
				}
				catch {
					print("ActivityManager : Full access request error \(error)")
				}
		}
		return authStatus
	}
	
	func addActivityToCalendar(_ activity: Activity) {
		Task {
			let status = await authStatusAsync()
			switch status {
			case .fullAccess:
				if !createEventForActivity(activity) {
					print("ActivityManager : Failed to create event")
				}
			default :
				print("ActivityManager : No access to calendar")
			}
		}
	}
	
	// Note that if the model configuration was not isStoredInMemoryOnly, then I would need to add
	// something like updateActivityToCalendar and deleteActivityFromCalendar, so that
	// authStatusAsync would get called before trying to set up the calendar event.
	// As it is, when you restart the app, the old events go away.
	
	
	// returns false if fails. Need to have registered for ability to write events, for instance.
	// this routine is not async.
	func createEventForActivity(_ activity: Activity) -> Bool {
		if hasEventFullAccess {
			let event = EKEvent(eventStore: store)
			event.title = activity.title
			event.startDate = activity.start
			event.endDate = activity.start.addingTimeInterval(activity.length)
			event.notes = activity.notes
			event.calendar = EKCalendar.calendarFromID(activity.calendarID, store: store)
			
			do {
				try store.save(event, span: .thisEvent)
				activity.eventID = event.eventIdentifier
				print("ActivityManager : eventIdentifier: \(event.eventIdentifier!)")
				return true
			} catch {
				print("ActivityManager : Error saving event: \(error)")
				return false
			}
		}
		return false
	}
	
	func updateEventForActivity(_ activity: Activity) -> Bool {
		var ret = false
		if hasEventFullAccess {
			if let eventID = activity.eventID {
				if let event = store.event(withIdentifier: eventID) {
					event.title = activity.title
					event.startDate = activity.start
					event.endDate = activity.start.addingTimeInterval(activity.length)
					event.notes = activity.notes
					event.calendar = EKCalendar.calendarFromID(activity.calendarID, store: store)

					do {
						try store.save(event, span: .futureEvents)
						print("ActivityManager : eventIdentifier: \(event.eventIdentifier!)")
						ret = true
					}
					catch {
						print("ActivityManager : Error changing event: \(error)")
					}
				}
			}
		}
		return ret
	}
	
	func deleteEventForActivity(_ activity: Activity) -> Bool {
		var ret = false
		if hasEventFullAccess {
			if let eventID = activity.eventID {
				if let event = store.event(withIdentifier: eventID) {
					do {
						try store.remove(event, span: .futureEvents)
						ret = true
					}
					catch {
						print("ActivityManager : Error deleting event: \(error)")
					}
				}
			}
		}
		return ret
	}
	
	var calendars: [EKCalendar] {
		return store.calendars(for: .event)
	}
	
}


/* From the documentation:
A full sync with the calendar will lose this identifier. You should have a plan for dealing with a calendar whose identifier is no longer fetch-able by caching its other properties.
*/
extension EKCalendar: @retroactive Identifiable {
	public var id: String {
		self.calendarIdentifier
	}
	
	public static func calendarFromID(_ id: EKCalendar.ID?, store: EKEventStore) -> EKCalendar? {
		if nil == id { return store.defaultCalendarForNewEvents }
		for calendar in store.calendars(for: .event) {
			if calendar.calendarIdentifier == id { return calendar }
		}
		return nil
	}
}
