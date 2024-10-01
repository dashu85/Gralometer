//
//  GralometerApp.swift
//  Gralometer
//
//  Created by Marcus Benoit on 15.06.24.
//

import Firebase
import Foundation
import SwiftData
import SwiftUI

@main
struct GralometerApp: App {
    @Environment(\.modelContext) private var modelContext
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ChallengeScrollView()
            }
        }
        .modelContainer(for: [Challenge.self, UserTest.self])
    }
    
    // where is Backend data stored -> path where it is stored
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
