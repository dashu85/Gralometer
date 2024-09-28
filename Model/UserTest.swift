//
//  User.swift
//  Gralometer
//
//  Created by Marcus Benoit on 15.06.24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class UserTest: Identifiable, Hashable, Codable {
    var id: UUID?
    var name: String?
    var age: Int?
    var challengesTakenPartIn: [Challenge]? = []
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case age
        case challengesTakenPartIn
    }
    
    init(id: UUID? = nil, name: String? = nil, age: Int? = nil, challengesTakenPartIn: [Challenge]? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.challengesTakenPartIn = challengesTakenPartIn
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        challengesTakenPartIn = try container.decode([Challenge].self, forKey: .challengesTakenPartIn)
    }
        
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(challengesTakenPartIn, forKey: .challengesTakenPartIn)
    }
}
