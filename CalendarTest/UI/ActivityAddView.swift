//
//  AddActivityView.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/30/24.
//

import SwiftUI
import EventKit

struct ActivityAddView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	@State var title: String = ""
	@State var date: Date = Date.now
	@State var tempMinutes = 0
	@State var notes: String = ""
	@State var calendarID: EKCalendar.ID? = nil

    var body: some View {
		Form {
			Section("Add Activity") {
				TextField("Title", text: $title)
				DatePicker("Date/Time", selection: $date)
				HStack {
					Stepper("Length", value: $tempMinutes, in: 0...240, step: 10) {
						_ = Text("\($0) minutes")
					}
					Text("\(tempMinutes) minutes")
				}
				
//				CalendarPickerView(calendarID: $calendarID)
				
				TextField("Notes (meeting URL, etc", text: $notes, axis: .vertical)
					.lineLimit(2...10)
				
				HStack {
					Button("Add Activity") {
						let activity = Activity(title: title, start: date, length: TimeInterval(tempMinutes * 60), notes: notes, calendarID: calendarID)
						modelContext.insert(activity)
						dismiss()
					}
					.keyboardShortcut(.defaultAction)
					.disabled(title.isEmpty || date == Date.now || tempMinutes == 0)
					
					Button("Cancel") {
						dismiss()
					}
					.keyboardShortcut(.cancelAction)
				}
			}
		}
		.padding()
    }
}

#Preview {
    ActivityAddView()
}
