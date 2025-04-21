//
//  ChallengesView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 09.10.24.
//

import SwiftUI

struct ChallengesView: View {
    @StateObject private var viewModel = ChallengesViewModel()
    @EnvironmentObject private var colorSchemeManager: ColorSchemeManager
    
    @State private var isShowingSheet = false
    @Binding var showSignInView: Bool
    
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(colors: colorSchemeManager.selectedScheme.viewBackgroundGradient, startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
                ScrollView {
                    ForEach(viewModel.challenges) { challenge in
                        NavigationLink {
                            ChallengeDetailView(challenge: challenge)
                        } label: {
                            ChallengeGroupBoxView(challenge: challenge)
                                .contextMenu {
                                    Button("Add Challenge to user") {
                                        viewModel.addChallengeToUser(challengeId: challenge.id, challengeNumber: challenge.number!)
                                    }
                                }
                        }
                        .onAppear {
                            if challenge == viewModel.challenges.last {
                                viewModel.getChallenges()
                            }
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                    }
                }
                .refreshable {
                    viewModel.getChallenges()
                }
            }
            .navigationTitle("Alle Challenges")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu(viewModel.selectedSortingOrder?.rawValue ?? "none") {
                        ForEach(ChallengesViewModel.SortingOption.allCases, id: \.self) { sortingOrder in
                            Button(sortingOrder.rawValue, systemImage: sortingOrder.systemImage) {
                                Task {
                                    try? await viewModel.sortingSelected(option: sortingOrder)
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("", systemImage: "arrow.up.arrow.down") {
                        ForEach(ChallengesViewModel.CategoryOption.allCases, id: \.self) { filterCategory in
                            Button(filterCategory.rawValue) {
                                Task {
                                    try? await viewModel.filterCategory(category: filterCategory)
                                }
                            }
                        }
                    }
                }
//                ToolbarItem {
//                    Button("Add new Challenge", systemImage: "plus") {
//                        isShowingSheet.toggle()
//                    }
//                }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
            
            viewModel.getChallenges()
        }
        .sheet(isPresented: $isShowingSheet) {
            AddChallengeSheet(viewModel: viewModel)
        }
    }
}

#Preview {
    @Previewable @State var path = NavigationPath()
    let colorSchemeManager = ColorSchemeManager()
    
    NavigationStack(path: $path) {
        ChallengesView(showSignInView: .constant(false), path: $path)
            .environment(colorSchemeManager)
    }
}
