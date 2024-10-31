//
//  ActivityLineView.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/30/24.
//

import SwiftUI
import SwiftData
import EventKit

struct ActivityLineView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(EventManager.self) private var eventManager
	@Bindable var activity: Activity
	@State var showDeleteSure: Bool = false
	@State var showEditActivity: Bool = false
	
    var body: some View {
		HStack {
			Button {
				showEditActivity.toggle()
			} label: {
				Text(activity.title)
			}
			.buttonStyle(.borderless)

			Spacer()
			
			Button {
				addActivity()
			} label: {
				Image(systemName: "calendar.badge.plus")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 32)
			}
			.disabled(activity.eventID != nil)
			.buttonStyle(.borderless)
			.padding(3)

			Button {
				showDeleteSure.toggle()
			} label: {
				Image(systemName: activity.isDeleted ? "trash" : "trash.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 24)
			}
			.buttonStyle(.borderless)
			.padding(3)

		}
		.sheet(isPresented: $showEditActivity) {
			ActivityEditView(activity: activity)
		}
		.sheet(isPresented: $showDeleteSure) {
			ActivityDeleteSureView(activity: activity)
		}
    }
	
	func addActivity() {
		eventManager.addActivityToCalendar(activity)
	}
	
	func delete() {
		modelContext.delete(activity)
	}
}

#Preview {
	@Previewable var activity = Activity(title: "Test Activity", start: Date.now, length: 60 * 60, notes: "ZOOM?")
	ActivityLineView(activity: activity)
		.environment(EventManager())
}
