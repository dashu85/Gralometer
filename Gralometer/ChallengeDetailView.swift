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
    
    @State private var showingEditSheet = false
    
    // TODO: Build it completely from scratch
    
    var body: some View {
        ScrollView {
            VStack {
                Text(challenge.challengeDescription ?? "no description")
                Text(challenge.place ?? "N/A")
                Button("print") {
                    print((challenge))
                }
            } // VStack
            .navigationTitle("\(challenge.number ?? 0)")
            .toolbar {
                ToolbarItem {
                    Button("Edit") {
                        showingEditSheet.toggle()
                    } // Button
                } // ToolbarItem
            } // toolbar
            .sheet(isPresented: $showingEditSheet) {
                EditChallengeView(challenge: challenge)
            } // sheet
        } // ScrollView
    } // body
} // ChallengeDetailView

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Challenge.self, configurations: config)
        let challenge = Challenge(id: UUID(), title: "Bowling", number: 1909, date: .now, participants: [UserTest(id: UUID(), name: "Marcel", age: 39, challengesTakenPartIn: [])], place: "Brandenburg", challengeDescription: "Bowling spielen", type: "Normal", category: .geschickGames, numberOfParticipants: 2, status: .inProgress)
        
        return ChallengeDetailView(challenge: challenge)
            .modelContainer(container)
    } catch {
        return Text(error.localizedDescription)
    }
}
