//
//  CalendarPickerView.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/31/24.
//

import SwiftUI
import EventKit

struct CalendarPickerView: View {
	@Environment(EventManager.self) private var eventManager
	@Binding var calendarID: EKCalendar.ID?
	
	var body: some View {
		if eventManager.calendars.isEmpty {
			Text("No calendars found.")
		} else {
			Picker("Calendar", selection: $calendarID) {
				Text("Default").tag(nil as EKCalendar.ID?)
				ForEach(eventManager.calendars) { calendar in
					Text(calendar.title)
						.tag(calendar.id)
				}
			}
		}
    }
}

#Preview {
	@Previewable @State var calendarID: EKCalendar.ID? = nil
    CalendarPickerView(calendarID: $calendarID)
}
	
