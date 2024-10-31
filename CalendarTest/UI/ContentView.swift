//
//  ContentView.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/30/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(EventManager.self) private var eventManager
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [Activity]
	@State private var showAddActivity = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(activities) { activity in
					ActivityLineView(activity: activity)
					
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
                }
#if os(iOS)
				.onDelete(perform: delete)
#endif
            }

			.sheet(isPresented: $showAddActivity) {
				ActivityAddView()
			}
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
//#if os(iOS)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//#endif
                ToolbarItem {
					Button {
						showAddActivity.toggle()
					} label: {
						Image(systemName: "plus")
					}
                }
            }
			.onAppear {
				seedData()
			}
        } detail: {
			VStack {
				Text("The detail section is irrelevant for this demo code.")
				Text("Click on the Calender/Plus icon to add to the calendar.")
				Text("Click on the activity name to edit. If you save the activity it will automatically be added to the calendar.")
				Text("Click on the '+' button to add a new activity.")
				Text("Click on the garbage can to delete an activity. This will also delete the item from the calendar.")
			}
        }
    }

    private func addActivity() {
        withAnimation {
			let activity = Activity(title: "New Activity", start: .now, length: 60 * 60)
            modelContext.insert(activity)
        }
    }
	
	func delete(at offsets: IndexSet) {
		guard let idx = offsets.first else { return }
		let activity = activities[idx]
		if nil != activity.eventID {
			if !eventManager.deleteEventForActivity(activity) {
				print("Failed to delete event for activity \(activity)")
			}
		}
		modelContext.delete(activity)
	}
	
	func seedData() {
		let activity = Activity(title: "Foobar", start: Date(timeIntervalSinceNow: 60 * 60), length: 60 * 60, notes: "", calendarID: nil)
		modelContext.insert(activity)
	}
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
