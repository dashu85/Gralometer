//
//  UserManager.swift
//  Gralometer
//
//  Created by Marcus Benoit on 07.10.24.
//

import Foundation
import FirebaseFirestore

struct DBUser: Codable, Hashable {
    let userId: String
    let isAnonymous: Bool?
    let displayName: String?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let hasGral: Bool?
    
    // auth initializer
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.displayName = auth.displayName
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.hasGral = false
    }
    
    // regular initializer
    init(
        userId: String,
        isAnonymous: Bool? = nil,
        displayName: String? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        hasGral: Bool? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.displayName = displayName
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.hasGral = hasGral
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case displayName = "display_name"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case hasGral = "has_gral"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.hasGral = try container.decodeIfPresent(Bool.self, forKey: .hasGral)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.displayName, forKey: .displayName)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.hasGral, forKey: .hasGral)
    }
}

final class UserManager {
    static let shared = UserManager()
    private init() { }
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    private let challengeCollection: CollectionReference = Firestore.firestore().collection("challenges")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    // get the collection of "challenges_taken_part_in"
    private func userChallengesTakenPartInCollectionRef(userId: String) -> CollectionReference {
        userDocument(userId: userId).collection("challenges_taken_part_in")
    }
    
    // get the document of a certain challenge taken part in
    private func userChallengesTakenPartInDocument(userId: String, challengesTakenPartInDocumentId: String) -> DocumentReference {
        userChallengesTakenPartInCollectionRef(userId: userId).document(challengesTakenPartInDocumentId)
    }
    
    // get all myChallenges as array of MyChallenge
    func getAllMyChallenges(userId: String) async throws -> [MyChallenge] {
        let myChallenges = try await userChallengesTakenPartInCollectionRef(userId: userId)
            .getDocuments(as: MyChallenge.self)
        
        return myChallenges
    }
    
    /* Pagination Begin */
    
    func getMyChallengesPage(userId: String, limit: Int, lastDocument: DocumentSnapshot?) async throws -> ([MyChallenge], DocumentSnapshot?) {
        var query = userChallengesTakenPartInCollectionRef(userId: userId)
            .order(by: "challenge_number", descending: true)
            .limit(to: limit)
        
        // Start after the last document, if it exists
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        let snapshot = try await query.getDocuments()
        
        // Map documents to MyChallenge models
        let challenges = snapshot.documents.compactMap { document in
            try? document.data(as: MyChallenge.self)
        }
        
        // Return challenges and the last document in this page
        return (challenges, snapshot.documents.last)
    }
    
    /* Pagination End */
    
    /* Add Listener Begin */
    
    func addListenerForMyChallenges(userId: String, completion: @escaping (_ myChallenges: [MyChallenge]) -> Void) {
        userChallengesTakenPartInCollectionRef(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            let myChallenges = documents.compactMap ({ try? $0.data(as: MyChallenge.self) })
            completion(myChallenges)
        }
    }
    
    /* Add Listener End */
    
    
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    // updates has_Gral status only
    func updateGralStatus(userId: String, hasGral: Bool) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.hasGral.rawValue : hasGral
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func addChallengeToUser(userId: String, challengeId: String, challengeNumber: Int) async throws {
        let document = userChallengesTakenPartInCollectionRef(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            MyChallenge.CodingKeys.id.rawValue: documentId,
            MyChallenge.CodingKeys.challengeNumber.rawValue : challengeNumber,
            MyChallenge.CodingKeys.challengeId.rawValue : challengeId,
            MyChallenge.CodingKeys.lastUpdated.rawValue : Timestamp()
        ]
            
        try await document.setData(data, merge: false)
    }
    
    func removeChallengeFromUser(userId: String, challengesTakenPartInDocumentId: String) async throws {
        let document = userChallengesTakenPartInDocument(userId: userId, challengesTakenPartInDocumentId: challengesTakenPartInDocumentId)
        
        try await userChallengesTakenPartInDocument(userId: userId, challengesTakenPartInDocumentId: document.documentID).delete()
    }
}

struct MyChallenge: Codable, Equatable {
    let id: String
    let challengeNumber: Int
    let challengeId: String
    let lastUpdated: Date
    
    init(id: String, challengeNumber: Int, challengeId: String, lastUpdated: Date) {
        self.id = id
        self.challengeNumber = challengeNumber
        self.challengeId = challengeId
        self.lastUpdated = lastUpdated
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case challengeNumber = "challenge_number"
        case challengeId = "challenge_id"
        case lastUpdated = "last_updated"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.challengeNumber, forKey: .challengeNumber)
        try container.encode(self.challengeId, forKey: .challengeId)
        try container.encode(self.lastUpdated, forKey: .lastUpdated)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.challengeNumber = try container.decode(Int.self, forKey: .challengeNumber)
        self.challengeId = try container.decode(String.self, forKey: .challengeId)
        self.lastUpdated = try container.decode(Date.self, forKey: .lastUpdated)
    }
}
