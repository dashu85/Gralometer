//
//  EditChallengeView.swift
//  Gralometer
//
//  Created by Marcus Benoit on 01.07.24.
//

import SwiftUI
import SwiftData

struct EditChallengeView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var dateOfChallenge = Date.now
    @State private var dateStarted = Date.now
    @State private var dateCompleted = Date.now
    @State private var title = ""
    @State private var place = ""
    @State private var challengeDescription = ""
    @State private var category = Categories.ehrengral
    
    @State private var isLongterm = false
    
    @State private var animationStyle: Animation = .bouncy
    
    @Bindable var challenge: Challenge
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.yellow
                    .ignoresSafeArea()
                
                VStack {
                    GroupBox {
                        LabeledContent {
                            DatePicker("", selection: $dateOfChallenge, displayedComponents: .date)
                        } label: {
                            Text("Datum")
                        }
                        
                        if isLongterm {
                            LabeledContent {
                                DatePicker("", selection: $dateCompleted, displayedComponents: .date)
                            } label: {
                                Text("Enddatum")
                            }
                            .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        }
                        
                        VStack {
                            Toggle(isOn: $isLongterm) {
                                Text("Langzeit Challenge")
                                
                            }
                            .toggleStyle(.switch)
                        }
                    }
                    .backgroundStyle(Color.black.opacity(0.3))
                    .animation(animationStyle, value: isLongterm)
                    
                    GroupBox {
                        LabeledContent {
                            TextField("", text: $title)
                                .background(.yellow)
                                .clipShape(.rect(cornerRadius: 5))
                        } label: {
                            Text("Challenge:")
                        }
                        
                        LabeledContent {
                            TextField("", text: $place)
                                .background(.yellow)
                                .clipShape(.rect(cornerRadius: 5))
                        } label: {
                            Text("Ort:")
                        }
                        
                        LabeledContent {
                            Picker("Kategorie", selection: $category) {
                                ForEach(Categories.allCases) { category in
                                    Text(category.categ).tag(category)
                                }
                            }
                            .tint(.black)
                        } label: {
                            Text("Kategorie")
                        }
                        
                        LabeledContent {
                        } label: {
                            Text("Beschreibung:")
                        }
                        LabeledContent {
                            TextField("", text: $challengeDescription, axis: .vertical)
                                .lineLimit(5...10)
                                .background(.yellow)
                                .clipShape(.rect(cornerRadius: 5))
                        } label: {
                            Text("")
                        }
                    }
                    .backgroundStyle(Color.black.opacity(0.3))
                    .animation(animationStyle, value: isLongterm)
                    
                    HStack{

                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                        .foregroundColor(.black)
                        .buttonStyle(.bordered)
                        .background(Color.black.opacity(0.3))
                        .clipShape(.rect(cornerRadius: 5))
                        
                        Button("Save") {
                            challenge.date = dateCompleted
                            challenge.title = title
                            challenge.place = place
                            challenge.challengeDescription = challengeDescription
                            challenge.category = category
                            modelContext.insert(challenge)
                            try? modelContext.save()
                            dismiss()
                        }
                        .foregroundColor(.yellow)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .buttonStyle(.borderedProminent)
                        .tint(.black)
                        .padding(.vertical)
                    }
                    .animation(animationStyle, value: isLongterm)

                } // VStack
                .navigationTitle("Challenge Nr. \(challenge.number ?? 1909)")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    dateCompleted = challenge.date ?? Date.now
                    title = challenge.title ?? "error during unwrapping"
                    place = challenge.place ?? "error during unwrapping"
                    category = challenge.category ?? .ehrengral
                    challengeDescription = challenge.challengeDescription ?? "error during unwrapping"
                }
                .padding()
            }
        } // NavigationStack
    } // body
    
    var changed: Bool {
        dateCompleted != challenge.date
        || title != challenge.title
        || place != challenge.place
        || challengeDescription != challenge.challengeDescription
        || category != challenge.category
    }
} // EditChallengeView



#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Challenge.self, configurations: config)
        let challenge = Challenge(id: UUID(), title: "Bowling", number: 1909, date: .now, participants: [UserTest(id: UUID(), name: "Marcel", age: 39, challengesTakenPartIn: [])], place: "Brandenburg", challengeDescription: "Bowling spielen", type: "Normal", category: .geschickGames, numberOfParticipants: 2, status: .inProgress)
        
        return EditChallengeView(challenge: challenge)
            .modelContainer(container)
    } catch {
        return Text(error.localizedDescription)
    }
}
