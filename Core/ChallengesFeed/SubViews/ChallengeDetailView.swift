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
    @EnvironmentObject private var colorSchemeManager: ColorSchemeManager
    let challenge: Challenge
    
    @State private var showingEditSheet = false
    
    // TODO: Build it completely from scratch
    
    var body: some View {
        ZStack {
            LinearGradient(colors: colorSchemeManager.selectedScheme.viewBackgroundGradient ,startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
//            colorSchemeManager.selectedScheme.textColor.ignoresSafeArea()
            
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
            } // ScrollView
        }
    } // body
} // ChallengeDetailView

#Preview {
    ChallengeDetailView(challenge: Challenge(id: "1909", title: "Bowling", number: 2, date: Date(), place: "Berlin", challengeDescription: "Blackjack", type: "Type", category: "Kategorie", numberOfParticipants: 2))
}
