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
                        }
                        
                        if challenge == viewModel.challenges.last {
                            ProgressView()
                                .onAppear {
                                    print("new Documents fetched!")
                                    viewModel.getChallenges()
                                }
                        }
                    }
                }
                .refreshable {
                        viewModel.getChallenges()
                }
            }
            .navigationTitle("Challenges")
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
