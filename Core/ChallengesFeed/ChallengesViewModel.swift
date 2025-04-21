//
//  ChallengesViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 09.10.24.
//

import FirebaseFirestore
import Foundation

@MainActor
final class ChallengesViewModel: ObservableObject {
    @Published private(set) var challenges: [Challenge] = []
    @Published var selectedCategory: CategoryOption? = .noFilter
    @Published var selectedSortingOrder: SortingOption? = .newToOld
    private var lastDocument: DocumentSnapshot? = nil
    @Published var numberOfChallenges: Int = 0
    private let pageSize = 50
    private(set) var isLoading = false // TODO: Add a loading flag
    
    func getNumberOfChallenges() async throws {
        numberOfChallenges = try await ChallengeManager.shared.getAllChallengesCount()
    }
    
    func addNewChallenge(_ challenge: Challenge) async throws {
        try await ChallengeManager.shared.createNewChallenge(challenge: challenge)
        
        // Optionally: Fetch challenges again to update the view
        getChallenges()
    }
    
    enum SortingOption: String, CaseIterable {
        case newToOld = "Neueste zuerst"
        case oldToNew = "Älteste zuerst"
        
        var isNewToOld: Bool? {
            switch self {
            case .newToOld: return true
            case .oldToNew: return false
            }
        }
        
        var systemImage: String {
            switch self {
            case .newToOld: "soccerball"
            case .oldToNew: "soccerball.inverse"
            }
        }
    }
    
//    func sortingSelected(option: SortingOption) async throws {
//        self.selectedSortingOrder = option
//        self.challenges = []
//        self.lastDocument = nil
//        getChallenges()
//    }

    func sortingSelected(option: SortingOption) async throws {
        // Update the UI on the main thread
        self.selectedSortingOrder = option
        
        // Important: Clear the challenges array completely
        self.challenges = []
        self.lastDocument = nil
        
        // Instead of calling getChallenges() which appends to the array,
        // directly fetch and set the challenges
        let (newChallenges, lastDoc) = try await ChallengeManager.shared.getAllChallenges(
            descending: option.isNewToOld,
            category: selectedCategory?.categoryKey,
            count: pageSize,
            lastDocument: nil
        )
        
        // Replace the array rather than appending
        self.challenges = newChallenges
        self.lastDocument = lastDoc
    }
    
    enum CategoryOption: String, CaseIterable {
        case noFilter = "Kein Filter"
        case knowledge = "Wissen / Denken"
        case sport = "Sport"
        case games = "Geschick / Games"
        case miscellaneous = "Sonstiges"
        case combination = "Kombination"
        case manager = "Tipp / Manager"
        case honorary = "Ehrengral"
        
        var categoryKey: String? {
            if self == .noFilter {
                return nil
            }
            
            return self.rawValue
        }
    }
    
    func filterCategory(category: CategoryOption) async throws {
        self.selectedCategory = category
        self.challenges = []
        self.lastDocument = nil
        self.getChallenges()
    }
    
    // used to upload all challenges to firebase, no longer needed, hopefully
    func downloadChallengesAndUploadToFirebase() {
        // Ensure the JSON file is in the main bundle
        guard let url = Bundle.main.url(forResource: "json-challenges12To244", withExtension: "json") else {
            print("Failed to locate JSON file in bundle.")
            return
        }
        
        Task {
            do {
                // Read the file data
                let data = try Data(contentsOf: url)

                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy H:mm"  // Matches "24/05/2014 0:00"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let newChallenges = try decoder.decode([Challenge].self, from: data)
                let challengesArray = newChallenges
                
                for challenge in challengesArray {
                    try? await ChallengeManager.shared.uploadChallenges(challenge: challenge)
                    print("successfully uploaded challenge: \(String(describing: challenge.number))")
                }
            } catch {
                print("Decoding error:", error)
            }
        }
    }
    
    func getChallenges() {
        // Prevent duplicate loads if already loading
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            let (newChallenges, lastDocument) = try await ChallengeManager.shared.getAllChallenges(descending: selectedSortingOrder?.isNewToOld, category: selectedCategory?.categoryKey, count: pageSize, lastDocument: lastDocument)
            self.challenges.append(contentsOf: newChallenges)
            self.isLoading = false // Reset loading flag
            
            if let lastDocument {
                self.lastDocument = lastDocument
            }
        }
    }
    
    func addChallengeToUser(challengeId: String, challengeNumber: Int) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.addChallengeToUser(userId: authDataResult.uid, challengeId: challengeId, challengeNumber: challengeNumber)
        }
    }
    
    func removeChallengeFromUser(challengeTakenPartInId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.removeChallengeFromUser(userId: authDataResult.uid, challengesTakenPartInDocumentId: challengeTakenPartInId)
        }
    }
}
