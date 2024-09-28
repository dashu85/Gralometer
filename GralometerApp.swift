//
//  GralometerApp.swift
//  Gralometer
//
//  Created by Marcus Benoit on 15.06.24.
//

import Foundation
import SwiftData
import SwiftUI

@main
struct GralometerApp: App {
    @Environment(\.modelContext) private var modelContext
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Challenge.self, User.self])
    }
}
