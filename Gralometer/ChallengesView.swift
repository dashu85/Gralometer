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
    @State private var showingSignInView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: colorSchemeManager.selectedScheme.viewBackgroundGradient, startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
                ScrollView {
                    ForEach(viewModel.challenges) { challenge in
                        NavigationLink {
                            ChallengeDetailView(challenge: challenge)
                        } label: {
                            ChallengeGroupBoxView(challenge: challenge)
                        }
                    }
                }
                .refreshable {
                    Task {
                        viewModel.getChallenges()
                    }
                }
            }
            .navigationTitle("Gralometer \(AppData.version)")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("Sort", systemImage: viewModel.selectedSortingOrder?.rawValue ?? "none") {
                        ForEach(ChallengesViewModel.SortingOption.allCases, id: \.self) { sortingOrder in
                            Button(sortingOrder.rawValue) {
                                Task {
                                    try? await viewModel.sortingSelected(option: sortingOrder)
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu("\(viewModel.selectedCategory?.rawValue ?? "None")") {
                        ForEach(ChallengesViewModel.CategoryOption.allCases, id: \.self) { filterCategory in
                            Button(filterCategory.rawValue) {
                                Task {
                                    try? await viewModel.filterCategory(category: filterCategory)
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem {
                    NavigationLink {
                        ProfileView(showSignInView: $showingSignInView)
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
                
                ToolbarItem {
                    Button("Add new Challenge", systemImage: "plus") {
                        isShowingSheet.toggle()
                    }
                }
            }
        }
        .navigationDestination(for: DBUser.self) { user in
            ProfileView(showSignInView: $showingSignInView)
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showingSignInView = authUser == nil
            
            viewModel.getChallenges()
        }
        .fullScreenCover(isPresented: $showingSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showingSignInView)
            }
        }
        .sheet(isPresented: $isShowingSheet) {
            AddChallengeSheet(viewModel: viewModel)  // Pass viewModel to AddChallengeSheet
        }
    }
}

#Preview {
    NavigationStack {
        ChallengesView()
    }
}
