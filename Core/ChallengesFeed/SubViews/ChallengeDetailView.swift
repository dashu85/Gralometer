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
    @StateObject private var viewModel: ChallengeDetailViewModel
    
    @State private var showingEditSheet = false
    
    init(challenge: Challenge) {
            _viewModel = StateObject(wrappedValue: ChallengeDetailViewModel(challenge: challenge))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: viewModel.colorSchemeManager.selectedScheme.viewBackgroundGradient ,startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            //            colorSchemeManager.selectedScheme.textColor.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Header Section
                    viewModel.headerSection
                    
                    // Main Image
                    viewModel.imageSection
                    
                    // Challenge Info Section
                    viewModel.infoSection
                    
                    // Description Section
                    viewModel.descriptionSection
                    
                    // Participants Section
                    viewModel.participantsSection
                    
                    Spacer(minLength: 30)
                }
                .padding()
            } // ScrollView
            .navigationTitle("Challenge Details")
            .navigationBarTitleDisplayMode(.inline)
            .background(viewModel.colorSchemeManager.selectedScheme.backgroundColor)
        } // ZStack
    } // body
} // ChallengeDetailView

#Preview {
    @Previewable @State var path = NavigationPath()
    let colorSchemeManager = ColorSchemeManager()
    
    NavigationStack(path: $path) {
        ChallengeDetailView(challenge: Challenge(id: "1909", title: "Bowling", number: 2, date: Date(), place: "Berlin", challengeDescription: "Blackjack", type: "Type", category: "Kategorie", numberOfParticipants: 2))
            .environmentObject(colorSchemeManager)
    }
}
