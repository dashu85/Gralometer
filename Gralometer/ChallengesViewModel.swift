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
    
//    func getAllChallenges() async throws {
//        self.challenges = try await ChallengeManager.shared.getAllChallenges(categoryDescending: selectedSortingOrder?.isNewToOld, forCategory: selectedCategory?.rawValue)
//    }
    
    func addNewChallenge(_ challenge: Challenge) async throws {
        try await ChallengeManager.shared.createNewChallenge(challenge: challenge)
        
        // Optionally: Fetch challenges again to update the view
//        try await getAllChallenges()
        getChallenges()
    }
    
    enum SortingOption: String, CaseIterable {
        case oldToNew = "arrow.down.document"
        case newToOld = "arrow.up.document"
        
        var isNewToOld: Bool? {
            switch self {
            case .oldToNew: return false
            case .newToOld: return true
            }
        }
    }
    
    func sortingSelected(option: SortingOption) async throws {
        self.selectedSortingOrder = option
        self.challenges = []
        self.lastDocument = nil
        getChallenges()
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
    
    func getChallenges() {
        Task {
            let (newChallenges, lastDocument) = try await ChallengeManager.shared.getAllChallenges(descending: selectedSortingOrder?.isNewToOld, category: selectedCategory?.categoryKey, count: 4, lastDocument: lastDocument)
            self.challenges.append(contentsOf: newChallenges)
            if let lastDocument {
                self.lastDocument = lastDocument
            }
        }
    }
    
//    // For Pagination
//    func getChallengesByNumber() {
//        Task {
//            let (newChallenges, lastDocument) = try await ChallengeManager.shared.getAllChallengesByNumber(count: 10, lastDocument: lastDocument)
//            self.challenges.append(contentsOf: newChallenges)
//            self.lastDocument = lastDocument
//        }
//    }
}
