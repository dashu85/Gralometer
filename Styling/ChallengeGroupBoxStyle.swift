//
//  ChallengeGroupBoxStyle.swift
//  Gralometer
//
//  Created by Marcus Benoit on 15.06.24.
//

import Foundation
import SwiftUI
import SwiftData

// Custom CardView for GroupBoxStyle
struct ChallengeGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .bold()
                .foregroundStyle(.black)
            configuration.content
        }
        .padding(.horizontal)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// create custom modifier "challengeCard"
extension GroupBoxStyle where Self == ChallengeGroupBoxStyle {
    static var challengeCard: ChallengeGroupBoxStyle { .init() }
}
