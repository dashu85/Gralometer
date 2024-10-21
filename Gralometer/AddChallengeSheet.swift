//
//  AddChallengeSheet.swift
//  Gralometer
//
//  Created by Marcus Benoit on 10.10.24.
//

import SwiftUI



struct AddChallengeSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChallengesViewModel
    
    @State private var id = UUID()
    @State private var title = ""
    @State private var number = 1
    @State private var date = Date.now
    @State private var place = ""
    @State private var challengeDescription = ""
    @State private var type = ""
    @State private var category = "Kein Filter"
    @State private var numberOfParticipants = 2
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.5)
            
            Form {
                TextField("Nummber", value: $number, format: .number)
                
                TextField("Titel", text: $title)
                
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                TextField("Place", text: $place)
                
                TextField ("Description", text: $challengeDescription)
                
                TextField("Typ", text: $type)
                
                Picker("Kategorie", selection: $category) {
                    ForEach(ChallengesViewModel.CategoryOption.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category.rawValue)
                    }
                }
                
                Picker ("Anzahl Teilnehmer", selection: $numberOfParticipants) {
                    ForEach (0..<11) { number in
                        Text("\(number)").tag (number)
                    }
                }
                .pickerStyle(.wheel)
                
                HStack {
                    Button("Dismiss") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Add Challenge") {
                        Task {
                            await saveChallenge()  // Call the async function to save the challenge
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            .onAppear {
                number = viewModel.challenges.count + 1
            }
            .padding()
        }
        .ignoresSafeArea()
    }
    
    private func saveChallenge() async {
        let newChallenge = Challenge(
            id: id.uuidString,
            title: title,
            number: number,
            date: date,
            place: place,
            challengeDescription: challengeDescription,
            type: type,
            category: category,
            numberOfParticipants: numberOfParticipants
        )
        
        do {
            try await viewModel.addNewChallenge(newChallenge)
            dismiss()  // Dismiss the sheet once the challenge is saved
        } catch {
            print("Failed to save challenge: \(error.localizedDescription)")
        }
    }
}

#Preview {
    @ObservedObject var viewModel = ChallengesViewModel()
    
    AddChallengeSheet(viewModel: viewModel)
}
