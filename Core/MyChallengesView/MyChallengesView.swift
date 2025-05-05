//
//  MyChallengesView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 30.10.24.
//

import SwiftUI

struct MyChallengesView: View {
    @StateObject var viewModel = MyChallengesViewModel()
    @EnvironmentObject private var colorSchemeManager: ColorSchemeManager
    
    var body: some View {
        NavigationStack{
            ZStack{
                LinearGradient(colors: colorSchemeManager.selectedScheme.viewBackgroundGradient, startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
                ScrollView {
                    ForEach(viewModel.myChallenges, id: \.id.self) { challenge in
                        ChallengeRowView(challenge: challenge, viewModel: viewModel)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .navigationTitle("Meine Challenges")
                .onAppear {
                    // Add listener when the view appears
                    viewModel.addListenerForMyChallenges()
                }
                .onDisappear {
                    // Remove listener when the view disappears
                    viewModel.removeListenerForMyChallenges()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        SortingMenu(viewModel: viewModel)
                    }
                }
            }
        }
    }
}

//struct MyChallengesView: View {
//    @StateObject var viewModel = MyChallengesViewModel()
//    
//    var body: some View {
//        ScrollView {
//            ForEach(viewModel.myChallenges, id: \.id.self) { challenge in
//                ChallengeRowView(challenge: challenge, viewModel: viewModel)
//            }
//            
//            if viewModel.isLoading {
//                ProgressView()
//            }
//        }
//        .navigationTitle("Meine Challenges")
//        .onAppear {
//            viewModel.addListenerForMyChallenges()
//        }
//        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                SortingMenu(viewModel: viewModel)
//            }
//        }
//    }
//}

struct ChallengeRowView: View {
    let challenge: MyChallenge
    @ObservedObject var viewModel: MyChallengesViewModel

    var body: some View {
        ChallengeGroupBoxViewBuilder(challengeDocumentId: challenge.challengeId)
            .contextMenu {
                Button("Remove Challenge to user") {
                    viewModel.removeFromMyChallenges(challengesTakenPartInDocumentId: challenge.id)
                }
            }
            .onAppear {
                if challenge == viewModel.myChallenges.last {
                    viewModel.getMyChallenges()
                }
            }
    }
}

struct SortingMenu: View {
    @ObservedObject var viewModel: MyChallengesViewModel

    var body: some View {
        Menu {
            ForEach(MyChallengesViewModel.SortingOption.allCases, id: \.self) { sortingOrder in
                Button(sortingOrder.rawValue) {
                    Task {
                        try? await viewModel.sortingSelected(option: sortingOrder)
                    }
                }
            }
        } label: {
            Text(viewModel.selectedSortingOrder?.rawValue ?? "FAILED TO LOAD")
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let colorSchemeManager = ColorSchemeManager()
    
    NavigationStack(path: $path) {
        MyChallengesView()
//            .environment(\.colorScheme, .dark)
            .environment(colorSchemeManager)
    }
}
