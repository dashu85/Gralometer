//
//  ChallengeManager.swift
//  Gralometer
//
//  Created by Marcus Benoit on 09.10.24.
//

import Foundation
import FirebaseFirestore

struct ChallengeArray: Codable {
    let challenges: [Challenge]
    let total, takenPartIn, skip: Int
}

struct Challenge: Identifiable, Codable {
    var id: String?
    let title: String?
    let number: Int?
    let date: Date?
//    let participants: [DBUser]?
    let place: String?
    let challengeDescription: String?
//    let winner: DBUser?
    let type: String?
    let category: String? 
    let numberOfParticipants: Int?
    
    // Custom initializer to create a Challenge instance manually
    init(id: String, title: String?, number: Int?, date: Date?, place: String?, challengeDescription: String?, type: String?, category: String?, numberOfParticipants: Int?) {
        self.id = id
        self.title = title
        self.number = number
        self.date = date
        self.place = place
        self.challengeDescription = challengeDescription
        self.type = type
        self.category = category
        self.numberOfParticipants = numberOfParticipants
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case number = "number"
        case date = "date"
        case place = "place"
        case challengeDescription = "challenge_description"
        case type = "type"
        case category = "category"
        case numberOfParticipants = "number_of_participants"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.number = try container.decodeIfPresent(Int.self, forKey: .number)
        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
        self.place = try container.decodeIfPresent(String.self, forKey: .place)
        self.challengeDescription = try container.decodeIfPresent(String.self, forKey: .challengeDescription)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.numberOfParticipants = try container.decodeIfPresent(Int.self, forKey: .numberOfParticipants)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(number, forKey: .number)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(place, forKey: .place)
        try container.encodeIfPresent(challengeDescription, forKey: .challengeDescription)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(numberOfParticipants, forKey: .numberOfParticipants)
    }
}

final class ChallengeManager {
    static let shared = ChallengeManager()
    private init() { }
    
    private let challengeCollection = Firestore.firestore().collection("challenges")
    
    private func challengeDocument(challengeId: String) -> DocumentReference {
        challengeCollection.document(challengeId)
    }
    
    func createNewChallenge(challenge: Challenge) async throws {
//        try challengeDocument(challengeId: challenge.id).setData(from: challenge, merge: false)
        
        // Create a new document reference without specifying the document ID
        let documentRef = challengeCollection.document()  // Firestore generates the ID
        
        var challengeWithID = challenge
        challengeWithID.id = documentRef.documentID  // Assign the generated ID to the challenge
        
        // Now set the data in Firestore with the new ID
        try documentRef.setData(from: challengeWithID, merge: false)
    }
    
    func getChallenge(challengeId: String) async throws -> Challenge {
        try await challengeDocument(challengeId: challengeId).getDocument(as: Challenge.self)
    }
    
    // fetch all Documents of Challenges - IMPORTANT don't use it too often, too many requests.
    private func getAllChallenges() async throws -> [Challenge] {
        try await challengeCollection.getDocuments(as: Challenge.self)
    }
    
    private func getAllChallengesSortedByNumber(descending: Bool) async throws -> [Challenge] {
        try await challengeCollection
            .order(by: Challenge.CodingKeys.number.rawValue, descending: descending)
            .getDocuments(as: Challenge.self)
    }
    
    private func getAllChallengesFilteredByCategory(category: String) async throws -> [Challenge] {
        try await challengeCollection
            .whereField(Challenge.CodingKeys.category.rawValue, isEqualTo: category)
            .getDocuments(as: Challenge.self)
    }
    
    private func getAllChallengesFilteredByCategoryAndSorted(descending: Bool, category: String) async throws -> [Challenge] {
        try await challengeCollection
            .whereField(Challenge.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Challenge.CodingKeys.number.rawValue, descending: descending)
            .getDocuments(as: Challenge.self)
    }
    
    func getAllChallenges(categoryDescending descending: Bool?, forCategory category: String?) async throws -> [Challenge] {
        if let descending, let category {
            return try await getAllChallengesFilteredByCategoryAndSorted(descending: descending, category: category)
        } else if let descending {
            return try await getAllChallengesSortedByNumber(descending: descending)
        } else if let category {
            return try await getAllChallengesFilteredByCategory(category: category)
        }
        
        return try await getAllChallenges()
    }
    
    // TODO: finish func
    func updateChallenge(challengeId: String) async throws {
       
    }
}

extension Query {
    // Generic function to fetch all documents - IMPORTANT: make sure how many documents its gonna get!
    func getDocuments<T>(as T: T.Type) async throws -> [T] where T: Decodable {
        let snapShot = try await self.getDocuments()
        
        return try snapShot.documents.map({ document in
            try document.data(as: T.self)
        })
    }
}
