//
//  MyChallengesView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 30.10.24.
//

import SwiftUI

struct MyChallengesView: View {
    @StateObject var viewModel = MyChallengesViewModel()
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.myChallenges, id: \.id.self) { challenge in
                ChallengeRowView(challenge: challenge, viewModel: viewModel)
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Meine Challenges")
        .onAppear {
            viewModel.addListenerForMyChallenges()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SortingMenu(viewModel: viewModel)
            }
        }
    }
}

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
            Image(systemName: "arrow.up.arrow.down")
        }
    }
}

#Preview {
    MyChallengesView()
}
