//
//  Challenge.swift
//  Gralometer
//
//  Created by Marcus Benoit on 15.06.24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Challenge: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID?
    var title: String?
    var number: Int?
    var date: Date?
    // many to many relationship
    @Relationship(inverse: \User.challengesTakenPartIn) var participants: [User]?
    var place: String?
    var challengeDescription: String?
    var winner: User?
    var type: String?
    var category: String?
    var numberOfParticipants: Int?
    
    init(id: UUID? = nil, title: String? = nil, number: Int? = nil, date: Date? = nil, participants: [User]? = nil, place: String? = nil, challengeDescription: String? = nil, winner: User? = nil, type: String? = nil, category: String? = nil, numberOfParticipants: Int? = nil) {
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
    }
}

