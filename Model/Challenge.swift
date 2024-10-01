//
//  Challenge.swift
//  Gralometer
//
//  Created by Marcus Benoit on 15.06.24.
//

import Foundation
import SwiftData

@Model
class Challenge: Identifiable, Hashable, Codable {
    @Attribute(.unique) var id: UUID?
    var title: String?
    var number: Int?
    var date: Date?
    // many to many relationship
    @Relationship(inverse: \UserTest.challengesTakenPartIn) var participants: [UserTest]?
    var place: String?
    var challengeDescription: String?
    var winner: UserTest?
    var type: String?
    var category: Categories?
    var numberOfParticipants: Int?
    var status: Status?
    
    enum CodingKeys: CodingKey {
        case id, title, number, date, participants, place, challengeDescription, winner, type, category, numberOfParticipants, status
    }
    
    init(
        id: UUID? = nil,
        title: String? = nil,
        number: Int? = nil,
        date: Date? = nil,
        participants: [UserTest]? = nil,
        place: String? = nil,
        challengeDescription: String? = nil,
        winner: UserTest? = nil,
        type: String? = nil,
        category: Categories? = nil,
        numberOfParticipants: Int? = nil,
        status: Status? = nil
    ) {
        self.id = id
        self.title = title
        self.number = number
        self.date = date
        self.participants = participants
        self.place = place
        self.challengeDescription = challengeDescription
        self.winner = winner
        self.type = type
        self.category = category
        self.numberOfParticipants = numberOfParticipants
        self.status = status
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        number = try container.decode(Int.self, forKey: .number)
        date = try container.decode(Date.self, forKey: .date)
        participants = try container.decode([UserTest].self, forKey: .participants)
        place = try container.decode(String.self, forKey: .place)
        challengeDescription = try container.decode(String.self, forKey: .challengeDescription)
        winner = try container.decode(UserTest.self, forKey: .winner)
        type = try container.decode(String.self, forKey: .type)
        category = try container.decode(Categories.self, forKey: .category)
        numberOfParticipants = try container.decode(Int.self, forKey: .numberOfParticipants)
        status = try container.decode(Status.self, forKey: .status)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(number, forKey: .number)
        try container.encode(date, forKey: .date)
        try container.encode(participants, forKey: .participants)
        try container.encode(place, forKey: .place)
        try container.encode(challengeDescription, forKey: .challengeDescription)
        try container.encode(winner, forKey: .winner)
        try container.encode(type, forKey: .type)
        try container.encode(category, forKey: .category)
        try container.encode(numberOfParticipants, forKey: .numberOfParticipants)
        try container.encode(status, forKey: .status)
    }
}

enum Status: Int, Codable, Identifiable, CaseIterable {
    case planned, inProgress, completed
    var id: Self {
        self
    }
    
    var descr: String {
        switch self {
        case .planned:
            "Geplant"
        case .inProgress:
            "Läuft gerade"
        case .completed:
            "Challenge beendet"
        }
    }
}

enum Categories: Int, Codable, Identifiable, CaseIterable {
    case ehrengral, geschickGames, glück, kombination, sport, tippManager, wissenDenken, sonstiges
    var id: Self {
        self
    }
    
    var categ: String {
        switch self {
        case .ehrengral:
            "Ehrengral"
        case .geschickGames:
            "Geschick/Games"
        case .glück:
            "Glück"
        case .kombination:
            "Kombination"
        case .sport:
            "Sport"
        case .tippManager:
            "Tipp/Manager"
        case .wissenDenken:
            "Wissen/Denken"
        case .sonstiges:
            "Sonstiges"
        }
    }
}
