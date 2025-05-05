//
//  ChallengeDetailView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 05.08.24.
//

import PhotosUI
import SwiftUI
import SwiftData

struct ChallengeDetailView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject private var viewModel: ChallengeDetailViewModel
    
    @State private var showingEditSheet = false
    @State var isShowingImagePicker = false
    
    
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
                    
                    viewModel.photosSection
                    
                    // add Images to challenge
                    VStack {
                        PhotosPicker(selection: $viewModel.selectedItems, matching: .images, photoLibrary: .shared()) {
                            Text("Fotos hinzufügen!")
                        }
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding()
            } // ScrollView
            .navigationTitle("Challenge Details")
            .navigationBarTitleDisplayMode(.inline)
            .background(viewModel.colorSchemeManager.selectedScheme.backgroundColor)
            .onChange(of: viewModel.selectedItems) {
                Task {
                    viewModel.selectedImages.removeAll()
                    
                    for item in viewModel.selectedItems {
                        if let image = try? await item.loadTransferable(type: Image.self) {
                            viewModel.selectedImages.append(image)
                        }
                    }
                }
            }
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
