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
        
    @State private var showingAddChallengeView: Bool = false
    
    @State private var urlAddress = "https://api.npoint.io/7f85e848cc7ba94e3eba"
    
    var body: some View {
        NavigationStack(path: $path){
            ScrollView {
                ForEach(challenges) { challenge in
                    NavigationLink(value: challenge) {
                        ChallengeCardView(challenge: challenge)
                    }
                    .listRowBackground(Color.green)
                }
                .onDelete(perform: deleteChallenge)
            }
            .navigationTitle("Gralometer \(AppData.version)")
            .navigationDestination(for: Challenge.self) { challenge in
                ChallengeDetailView(challenge: challenge)
            }
            .toolbar {
                Button("New Challenge", systemImage: "plus") {
                    showingAddChallengeView.toggle()
                }
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .background(.yellow)
        }
        .sheet(isPresented: $showingAddChallengeView, content: {
            let challenge = Challenge(id: UUID(), title: "", number: 1, date: .now, participants: [], place: "", challengeDescription: "", type: "", category: "Sonstiges", numberOfParticipants: 2)
            EditChallengeView(challenge: challenge)
        })
        
        HStack(spacing: 60) {
            Button("upload") {
                print(challenges)
            }
            
            Button("Delete Container") {
                deleteContainer()
            }
        }
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
        // let challenge = Challenge(id: UUID(), title: "Bowling", number: 1909, date: .distantPast, participants: [User(id: UUID(), name: "Marcel", age: 39, challengesTakenPartIn: [])], place: "Brandenburg", challengeDescription: "Bowling spielen", type: "Normal", category: "Geschicklichkeit", numberOfParticipants: 2)
        
        return ChallengeScrollView()
            .modelContainer(container)
    } catch {
        return Text(error.localizedDescription)
    }
}
