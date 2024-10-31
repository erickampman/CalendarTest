//
//  Activity.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/30/24.
//

import Foundation
import SwiftData
import EventKit

@Model
final class Activity: Identifiable {
	var title: String
	var start: Date
	// TimeInterval is in seconds
	var length: TimeInterval
	var notes: String?
	var calendarID: EKCalendar.ID?

	var id = UUID()

	var eventID = String?.none
	
	init(title: String, start: Date, length: TimeInterval, notes: String? = nil, calendarID: EKCalendar.ID? = nil, id: UUID = UUID(), eventID: String? = nil) {
		self.title = title
		self.start = start
		self.length = length
		self.notes = notes
		self.calendarID = calendarID
		self.eventID = eventID
	}
	
	init(activity: Activity) {
		self.title = activity.title
		self.start = activity.start
		self.length = activity.length
		self.notes = activity.notes
		self.calendarID = activity.calendarID
		self.eventID = activity.eventID
	}
	
	func equals(_ other: Activity) -> Bool {
		title == other.title &&
		start == other.start &&
		length == other.length &&
		notes == other.notes
	}
}

extension Activity: Equatable {
	static func == (left: Activity, right: Activity) -> Bool {
		left.equals(right)
	}
}

