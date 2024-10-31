//
//  CalendarTestApp.swift
//  CalendarTest
//
//  Created by Eric Kampman on 10/30/24.
//

import SwiftUI
import SwiftData

@main
struct CalendarTestApp: App {
	let eventManager = EventManager()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Activity.self,
        ])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(eventManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
