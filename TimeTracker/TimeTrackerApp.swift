//
//  TimeTrackerApp.swift
//  TimeTracker
//
//  Created by Tony Chi on 17/2/21.
//

import SwiftUI

@main
struct TimeTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
