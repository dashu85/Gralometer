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
    
//    func toggleGralStatus() -> DBUser {
//        let currentValue = hasGral ?? false
//        
//        return DBUser(
//            userId: userId,
//            isAnonymous: isAnonymous,
//            displayName: displayName,
//            email: email,
//            photoUrl: photoUrl,
//            dateCreated: dateCreated,
//            hasGral: !currentValue)
//    }
    
//    mutating func toggleGralStatus() {
//        let currentValue = hasGral ?? false
//        hasGral = !currentValue
//    }
    
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
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    }()
//    
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String: Any] = [
//            "user_id" : auth.uid,
//            "is_anonymous" : auth.isAnonymous,
//            "date_created" : Timestamp(),
//        ]
//        
//        if let displayName = auth.displayName {
//            userData["display_name"] = displayName
//        }
//        
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//        
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
//    func getUser(userId: String) async throws -> DBUser {
//        let snapShot = try await userDocument(userId: userId).getDocument()
//        
//        guard let data = snapShot.data(), let userId = data["user_id"] as? String else {
//            throw AuthenticationError.userNotFound
//        }
//        
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let dateCreated = data["date_created"] as? Date
//        let displayName = data["display_name"] as? String
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        
//        return DBUser(userId: userId, isAnonymous: isAnonymous, displayName: displayName, email: email, photoUrl: photoUrl, dateCreated: dateCreated)
//    }
    
    // updates whole user
//    func updateGralStatus(user: DBUser) async throws {
//        try userDocument(userId: user.userId).setData(from: user, merge: true)
//    }
    
    // updates has_Gral status only
    func updateGralStatus(userId: String, hasGral: Bool) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.hasGral.rawValue : hasGral
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
}
