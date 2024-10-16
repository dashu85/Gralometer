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
    
//    func getAllChallenges() async throws {
//        self.challenges = try await ChallengeManager.shared.getAllChallenges(categoryDescending: selectedSortingOrder?.newToOld, forCategory: selectedCategory?.rawValue)
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
        
        var newToOld: Bool? {
            switch self {
            case .oldToNew: return false
            case .newToOld: return true
            }
        }
    }
    
    func sortingSelected(option: SortingOption) async throws {
//        self.challenges = try await ChallengeManager.shared.getAllChallenges(categoryDescending: selectedSortingOrder?.newToOld, forCategory: option.rawValue)
        self.selectedSortingOrder = option
        getChallenges()
    }
    
    enum CategoryOption: String, CaseIterable {
        case noFilter = "Kein Filter"
        case knowledge = "Wissen / Denken"
        case sport = "Sport"
        case games = "Geschick / Games"
        case miscellaneous = "Sonstiges"
        
        var categoryKey: String? {
            if self == .noFilter {
                return nil
            }
            
            return self.rawValue
        }
    }
    
    func filterCategory(category: CategoryOption) async throws {
        self.selectedCategory = category
        self.getChallenges()
    }
    
    func getChallenges() {
        Task {
            self.challenges = try await ChallengeManager.shared.getAllChallenges(categoryDescending: selectedSortingOrder?.newToOld, forCategory: selectedCategory?.categoryKey)
        }
    }
}
