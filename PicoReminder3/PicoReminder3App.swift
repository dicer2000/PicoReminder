//
//  PicoReminder3App.swift
//  PicoReminder3
//
//  Created by Brett Huffman on 10/18/20.
//

import SwiftUI

@main
struct PicoReminder3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
