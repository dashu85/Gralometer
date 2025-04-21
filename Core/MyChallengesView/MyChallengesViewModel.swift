//
//  MyChallengesViewModel.swift
//  Gralometer
//
//  Created by Marcus Benoit on 30.10.24.
//

import FirebaseFirestore
import Foundation

@MainActor
final class MyChallengesViewModel: ObservableObject {
    @Published private(set) var myChallenges: [MyChallenge] = []
    @Published var selectedSortingOrder: SortingOption? = .newToOld
    var lastDocument: DocumentSnapshot? = nil
    
    private let pageSize = 20
    @Published private(set) var isLoading = false // Make this published so the view can react to it
    
    // Store the listener so we can remove it later
    private var challengesListener: ListenerRegistration? = nil
    
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
    
    deinit {
        // Clean up listener when view model is deallocated
        removeListenerForMyChallenges()
    }
    
    func sortingSelected(option: SortingOption) async throws {
        self.selectedSortingOrder = option
        getInitialChallenges()
    }
    
    func getInitialChallenges() {
        lastDocument = nil  // Reset pagination
        myChallenges = []   // Clear existing data
        getMyChallenges()  // Load the first page
    }
    
    func getMyChallenges() {
        // Prevent duplicate loads if already loading
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
                
                // Fetch the next page of challenges
                let (newChallenges, lastDoc) = try await UserManager.shared.getMyChallengesPage(userId: authDataResult.uid, limit: pageSize, lastDocument: lastDocument)
                
                // Sort the challenges based on the selected sorting order
                var sortedChallenges = [MyChallenge]()
                if let isNewToOld = selectedSortingOrder?.isNewToOld, isNewToOld {
                    sortedChallenges = newChallenges.sorted { $0.challengeNumber > $1.challengeNumber }
                } else {
                    sortedChallenges = newChallenges.sorted { $0.challengeNumber < $1.challengeNumber }
                }
                
                // Update the list of challenges and last document
                await MainActor.run {
                    if self.lastDocument == nil {
                        // First page: replace all challenges
                        self.myChallenges = sortedChallenges
                    } else {
                        // Subsequent pages: append new challenges
                        self.myChallenges.append(contentsOf: sortedChallenges)
                    }
                    self.lastDocument = lastDoc
                    self.isLoading = false // Reset loading flag
                }
            } catch {
                print("Error fetching challenges: \(error)")
                await MainActor.run {
                    self.isLoading = false // Reset loading flag on error
                }
            }
        }
    }
    
    func addListenerForMyChallenges() {
        // First remove any existing listener to prevent duplicates
        removeListenerForMyChallenges()
        
        // Set loading state to true
        isLoading = true
        
        Task {
            guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else {
                isLoading = false
                return
            }
            
            // Store the listener so we can remove it later
            challengesListener = UserManager.shared.addListenerForMyChallenges(userId: authDataResult.uid) { [weak self] myChallenges in
                guard let self = self else { return }
                
                // Sort the challenges based on the selected sorting order
                var sortedChallenges = [MyChallenge]()
                if let isNewToOld = self.selectedSortingOrder?.isNewToOld, isNewToOld {
                    sortedChallenges = myChallenges.sorted { $0.challengeNumber > $1.challengeNumber }
                } else {
                    sortedChallenges = myChallenges.sorted { $0.challengeNumber < $1.challengeNumber }
                }
                
                // Update on the main thread
                Task { @MainActor in
                    self.myChallenges = sortedChallenges
                    self.isLoading = false
                }
            }
        }
    }
    
    // Mark this method as nonisolated so it can be called from anywhere
    nonisolated func removeListenerForMyChallenges() {
        // We need to use MainActor.shared to modify actor-isolated properties
        Task { @MainActor in
            // Remove the listener if it exists
            challengesListener?.remove()
            challengesListener = nil
        }
    }
    
    func removeFromMyChallenges(challengesTakenPartInDocumentId: String) {
        Task {
            do {
                let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
                try await UserManager.shared.removeChallengeFromUser(userId: authDataResult.uid, challengesTakenPartInDocumentId: challengesTakenPartInDocumentId)
                getInitialChallenges()
            } catch {
                print("Error removing challenge: \(error)")
            }
        }
    }
}


//import FirebaseFirestore
//import Foundation
//
//@MainActor
//final class MyChallengesViewModel: ObservableObject {
//    @Published private(set) var myChallenges: [MyChallenge] = []
//    @Published var selectedSortingOrder: SortingOption? = .newToOld
//    var lastDocument: DocumentSnapshot? = nil
//    
//    private let pageSize = 20  // Number of challenges to fetch per page / Pagination
//    private(set) var isLoading = false // Add a loading flag
//    
//    enum SortingOption: String, CaseIterable {
//        case newToOld = "Neueste zuerst"
//        case oldToNew = "Älteste zuerst"
//        
//        var isNewToOld: Bool? {
//            switch self {
//            case .newToOld: return true
//            case .oldToNew: return false
//            }
//        }
//        
//        var systemImage: String {
//            switch self {
//            case .newToOld: "soccerball"
//            case .oldToNew: "soccerball.inverse"
//            }
//        }
//    }
//    
//    func sortingSelected(option: SortingOption) async throws {
//        self.selectedSortingOrder = option
//        getInitialChallenges()
//    }
//    
////    func getMyChallenges() {
////        Task {
////            do {
////                let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
////                
////                // Fetch challenges using the UserManager method
////                let challenges = try await UserManager.shared.getAllMyChallenges(userId: authDataResult.uid)
////                
////                
////                if (selectedSortingOrder?.isNewToOld)! {
////                    self.myChallenges = challenges.sorted { $0.challengeNumber > $1.challengeNumber }
////                } else {
////                    self.myChallenges = challenges.sorted { $0.challengeNumber < $1.challengeNumber }
////                }
////            } catch {
////                print("Error fetching challenges: \(error)")
////            }
////        }
////    }
//    
//    /* Pagination Begin */
//    
//    func getInitialChallenges() {
//        lastDocument = nil  // Reset pagination
//        myChallenges = []   // Clear existing data
//        getMyChallenges()  // Load the first page
//    }
//    
//    func getMyChallenges() {
//        // Prevent duplicate loads if already loading
//        guard !isLoading else { return }
//        isLoading = true
//        
//        Task {
//            do {
//                let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//                
//                // Fetch the next page of challenges
//                let (newChallenges, lastDoc) = try await UserManager.shared.getMyChallengesPage(userId: authDataResult.uid, limit: pageSize, lastDocument: lastDocument)
//                
//                if (selectedSortingOrder?.isNewToOld)! {
//                    self.myChallenges = newChallenges.sorted { $0.challengeNumber > $1.challengeNumber }
//                } else {
//                    self.myChallenges = newChallenges.sorted { $0.challengeNumber < $1.challengeNumber }
//                }
//                
//                // Update the list of challenges and last document
//                DispatchQueue.main.async {
////                    self.myChallenges.append(contentsOf: newChallenges)
//                    self.lastDocument = lastDoc
//                    self.isLoading = false // Reset loading flag
//                }
//            } catch {
//                print("Error fetching challenges_: \(error)")
//                isLoading = false // Reset loading flag on error
//            }
//        }
//    }
//    
//    func sortingSelected(option: SortingOption) {
//        selectedSortingOrder = option
//        getInitialChallenges() // Re-fetch challenges with new sorting
//    }
//    
//    /* Pagination End */
//    
//    func addListenerForMyChallenges() {
//        Task {
//            guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
//            UserManager.shared.addListenerForMyChallenges(userId: authDataResult.uid, completion: { [weak self] myChallenges in
//                self?.myChallenges = myChallenges
//            })
//        }
//    }
//    
//    func removeFromMyChallenges(challengesTakenPartInDocumentId: String) {
//        Task {
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            try? await UserManager.shared.removeChallengeFromUser(userId: authDataResult.uid, challengesTakenPartInDocumentId: challengesTakenPartInDocumentId)
//            getInitialChallenges()
//        }
//    }
//}
