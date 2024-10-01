//
//  ContentView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 15.06.24.
//

import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct ChallengeScrollView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Challenge.number, order: .reverse) var challenges: [Challenge]
    
    @State private var path = [Challenge]()
    
    @State private var searchText = ""
    var filteredChallenges: [Challenge] {
        if searchText.isEmpty {
            challenges
        } else {
            challenges.filter { $0.title?.localizedStandardContains(searchText) ?? false }
        }
    }
    
    @State private var showingAddChallengeView: Bool = false
    @State private var showingSignInView: Bool = false
    
    @State private var urlAddress = "https://api.npoint.io/7f85e848cc7ba94e3eba"
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack {
                    if filteredChallenges.isEmpty {
                        ContentUnavailableView("Start a challenge.", systemImage: "trophy")
                    } else {
                        ScrollView {
                            ForEach(filteredChallenges) { challenge in
                                NavigationLink(value: challenge) {
                                    ChallengeCardView(challenge: challenge)
                                }
                            }
                            .onDelete(perform: deleteChallenge)
                        }
                        .navigationDestination(for: Challenge.self) { challenge in
                            ChallengeDetailView(challenge: challenge)
                        }
                        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
                    }
                }
                .navigationTitle("Gralometer \(AppData.version)")
                .toolbar {
                    NavigationLink("Settings") {
                        SettingsView(showSignInView: $showingSignInView)
                    }
                    
                    
                    Button("New Challenge", systemImage: "plus") {
                        showingAddChallengeView.toggle()
                    }
                    
                    Button("Delete Container", systemImage: "trash") {
                        deleteContainer()
                    }
                }
                .scrollIndicators(.hidden)
                .scrollContentBackground(.hidden)
                .background(.yellow)
                .searchable(text: $searchText)
            }
            .onAppear {
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                self.showingSignInView = authUser == nil
            }
            .fullScreenCover(isPresented: $showingSignInView) {
                NavigationStack {
                    AuthenticationView(showSignInView: $showingSignInView)
                }
            }
        }
        .sheet(isPresented: $showingAddChallengeView, content: {
            let challenge = Challenge(id: UUID(), title: "", number: 1, date: .now, participants: [], place: "", challengeDescription: "", type: "", category: .sonstiges, numberOfParticipants: 2, status: .inProgress)
            EditChallengeView(challenge: challenge)
        })
    }
    
    func deleteChallenge(at offsets: IndexSet) {
        for offset in offsets {
            let challenge = challenges[offset]
            modelContext.delete(challenge)
        }
    }
    
    func deleteContainer() {
        _ = try? modelContext.delete(model: Challenge.self)
    }
    
    func uploadJSON() async {
        guard let encoded = try? JSONEncoder().encode(challenges) else {
            print("Failed to encode records")
            return
        }
        
        let url = URL(string: urlAddress)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            print(encoded)
            let (_, _) = try await URLSession.shared.upload(for: request, from: encoded)
            // handle the result
        } catch {
            print("Failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Challenge.self, configurations: config)
        
        return ChallengeScrollView()
            .modelContainer(container)
    } catch {
        return Text(error.localizedDescription)
    }
}
