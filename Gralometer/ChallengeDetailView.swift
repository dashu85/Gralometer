//
//  ChallengeDetailView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 05.08.24.
//

import SwiftUI
import SwiftData

struct ChallengeDetailView: View {
    @Environment(\.modelContext) var modelContext
    var challenge: Challenge
    
    @State private var showEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text(challenge.challengeDescription ?? "no description")
                Text(challenge.place ?? "N/A")
            } // VStack
            .navigationTitle("\(challenge.number ?? 0)")
            .toolbar {
                ToolbarItem {
                    Button("Edit") {
                        showEditSheet.toggle()
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditChallengeView(challenge: challenge)
            }
        } // ScrollView
    } // body
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Challenge.self, configurations: config)
        let challenge = Challenge(id: UUID(), title: "Bowling", number: 1909, date: .distantPast, participants: [User(id: UUID(), name: "Marcel", age: 39, challengesTakenPartIn: [])], place: "Brandenburg", challengeDescription: "Bowling spielen", type: "Normal", category: "Geschicklichkeit", numberOfParticipants: 2)
        
        return ChallengeDetailView(challenge: challenge)
            .modelContainer(container)
    } catch {
        return Text(error.localizedDescription)
    }
}
