//
//  ActivityDeleteSureView.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/31/24.
//

import SwiftUI

struct ActivityDeleteSureView: View {
	@Environment(EventManager.self) private var eventManager
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) var dismiss
	@Bindable var activity: Activity

    var body: some View {
		VStack {
			Text("Are you sure you want to delete activity \(activity.title)?")
			Text("This will remove the activity fron a Calendar if it was registered.")
			HStack {
				Spacer()
				Button("Delete") {
					if nil != activity.eventID {
						if !eventManager.deleteEventForActivity(activity) {
							print("Failed to delete event for activity")
						}
					}
					modelContext.delete(activity)
					dismiss()
				}
				Button("Cancel") {
					dismiss()
				}
			}
		}
    }
}

//#Preview {
//    ActivityDeleteSureView()
//}
