//
//  ActivityEditView.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/31/24.
//

import SwiftUI

struct ActivityEditView: View {
	@Environment(EventManager.self) private var eventManager
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	@Bindable var activity: Activity
//	@State var tempActivity: Activity
	@State var tempTitle: String
	@State var tempStart: Date
	@State var tempMinutes = Double(0)
	@State var tempNotes: String
	@State var tempCalendarID: String?
	
	init(activity: Activity) {
		self.activity = activity
		self.tempTitle = activity.title
		self.tempStart = activity.start
		self.tempMinutes = activity.length / 60.0
		self.tempNotes = activity.notes ?? ""
		self.tempCalendarID = activity.calendarID
	}
	
    var body: some View {
		Form {
			Section("Edit Activity") {
				TextField("Title", text: $tempTitle)
				DatePicker("Date/Time", selection: $tempStart)
				HStack {
					Stepper("Length", value: $tempMinutes, in: 0...240, step: 10) {_ in 
					}
					Text("\(Int(tempMinutes)) minutes")
				}
				
				CalendarPickerView(calendarID: $tempCalendarID)

				TextField("Notes (meeting URL, etc", text: $tempNotes, axis: .vertical)
					.lineLimit(2...10)
				HStack {
					Button("Save Activity") {
						activity.title = tempTitle
						activity.start = tempStart
						activity.length = tempMinutes * 60
						activity.notes = tempNotes
						activity.calendarID = tempCalendarID
						
						do { try modelContext.save() }
						catch {
							print("Error saving activity: \(error)")
						}
						
						if nil != activity.eventID {
							let success = eventManager.updateEventForActivity(activity)
							if !success {
								print("Error updating event for activity: \(activity)")
							}
						} else {
							eventManager.addActivityToCalendar(activity)
						}
						dismiss()
					}
					.keyboardShortcut(.defaultAction)
					.disabled(
							  (activity.title == tempTitle &&
							  activity.start == tempStart &&
							  activity.calendarID == tempCalendarID &&
							  activity.length == tempMinutes*60.0 &&
							  activity.notes == tempNotes) &&
							  activity.eventID != nil
					)
					
					Button("Cancel") {
						dismiss()
					}
					.keyboardShortcut(.cancelAction)
				}
			}
		}
    }
}

#Preview {
	@Previewable var activity = Activity(title: "Preview Activity", start: .now + 60, length: 120)
	ActivityEditView(activity: activity)
}
